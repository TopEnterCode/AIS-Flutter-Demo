import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:launchdarkly_flutter_client_sdk/launchdarkly_flutter_client_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/flag_keys.dart';

export 'package:launchdarkly_flutter_client_sdk/launchdarkly_flutter_client_sdk.dart'
    show LDValue, LDValueType;

enum LDFlagType { boolean, string, number, json }

enum LDConnectionStatus { disconnected, connecting, connected, error }

// ============================================================
//  LDUserContext — app-layer DTO; decouples screens from SDK
// ============================================================
class LDUserContext {
  final String key;
  final String? name;
  final String? email;
  final String? role;
  final String plan;
  final String country;
  final bool betaTester;
  final String? organizationKey;
  final String? organizationName;
  final String? organizationPlan;
  final Map<String, dynamic> attributes;

  const LDUserContext({
    required this.key,
    this.name,
    this.email,
    this.role,
    this.plan = 'free',
    this.country = 'TH',
    this.betaTester = false,
    this.organizationKey,
    this.organizationName,
    this.organizationPlan,
    this.attributes = const {},
  });

  LDUserContext copyWith({
    String? key,
    String? name,
    String? email,
    String? role,
    String? plan,
    String? country,
    bool? betaTester,
    String? organizationKey,
    String? organizationName,
    String? organizationPlan,
    Map<String, dynamic>? attributes,
  }) =>
      LDUserContext(
        key: key ?? this.key,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        plan: plan ?? this.plan,
        country: country ?? this.country,
        betaTester: betaTester ?? this.betaTester,
        organizationKey: organizationKey ?? this.organizationKey,
        organizationName: organizationName ?? this.organizationName,
        organizationPlan: organizationPlan ?? this.organizationPlan,
        attributes: attributes ?? this.attributes,
      );
}

// ============================================================
//  LDFlagInfo — metadata + current value for each flag
// ============================================================
class LDFlagInfo {
  final String key;
  final String name;
  final String description;
  final LDFlagType type;
  dynamic value;
  final dynamic defaultValue;
  final List<dynamic> possibleValues;
  final String demoHint;
  final String flagCategory;

  LDFlagInfo({
    required this.key,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.defaultValue,
    this.possibleValues = const [],
    this.demoHint = '',
    this.flagCategory = '',
  });

  LDFlagInfo copyWithValue(dynamic newValue) => LDFlagInfo(
        key: key,
        name: name,
        description: description,
        type: type,
        value: newValue,
        defaultValue: defaultValue,
        possibleValues: possibleValues,
        demoHint: demoHint,
        flagCategory: flagCategory,
      );
}

// ============================================================
//  LDService — wraps LaunchDarkly Flutter SDK v4.x
//    • LDClient is instance-based in v4.x
//    • Variations are synchronous (no await needed)
//    • flagChanges emits FlagsChangedEvent via Stream
//    • Web uses Client-side ID; Mobile uses Mobile key
// ============================================================
class LDService extends ChangeNotifier {
  LDService._({required LDUserContext initialContext}) {
    _userContext = initialContext;
    _initDefaultFlags();
  }

  // ── Real LD client (null in mock/demo mode) ──────────────
  LDClient? _client;
  StreamSubscription<FlagsChangedEvent>? _flagSub;

  // ── State ────────────────────────────────────────────────
  LDConnectionStatus _status = LDConnectionStatus.disconnected;
  String? _sdkKey;
  late LDUserContext _userContext;
  final Map<String, LDFlagInfo> _flags = {};

  LDConnectionStatus get status => _status;
  bool get isConnected => _status == LDConnectionStatus.connected;
  bool get isMockMode => _client == null;
  LDUserContext get userContext => _userContext;
  String? get sdkKey => _sdkKey;
  List<LDFlagInfo> get allFlags => _flags.values.toList();
  LDFlagInfo? getFlag(String key) => _flags[key];

  // ── Factory — call in main(), await before runApp() ─────
  static Future<LDService> create({
    String? sdkKey,
    LDUserContext? initialContext,
  }) async {
    final ctx = initialContext ??
        const LDUserContext(
          key: 'demo-user-001',
          name: 'Demo User',
          email: 'demo@example.com',
          role: 'user',
          plan: 'free',
          country: 'TH',
        );
    final service = LDService._(initialContext: ctx);
    final normalizedSdkKey = sdkKey?.trim();
    if (normalizedSdkKey != null && normalizedSdkKey.isNotEmpty) {
      await service._connectReal(normalizedSdkKey, ctx);
    }
    return service;
  }

  // ── Real LD connection ───────────────────────────────────
  Future<void> _connectReal(String sdkKey, LDUserContext ctx) async {
    _sdkKey = sdkKey;
    _status = LDConnectionStatus.connecting;
    notifyListeners();
    try {
      // v4.x: LDConfig(credential, AutoEnvAttributes.enabled)
      // Web build → credential = Client-side ID
      // Mobile build → credential = Mobile key
      final config = LDConfig(sdkKey, AutoEnvAttributes.enabled);
      final ldCtx = _toLDContext(ctx);
      _client = LDClient(config, ldCtx);

      // Listen before start so the initial flag payload (including cached
      // values) cannot be missed.
      _flagSub = _client!.flagChanges.listen((_) {
        _syncFlagsFromLD();
        notifyListeners();
      });

      var startTimedOut = false;
      final started = await _client!.start().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // The SDK may still finish initialization in the background;
          // the flagChanges listener above will apply its values later.
          startTimedOut = true;
          return false;
        },
      );
      if (!started && !startTimedOut) {
        throw StateError('LaunchDarkly SDK failed to initialize');
      }
      _syncFlagsFromLD();
      _status = LDConnectionStatus.connected;
    } catch (e) {
      debugPrint('[LDService] connection error: $e');
      await _flagSub?.cancel();
      await _client?.close();
      _flagSub = null;
      _client = null;
      _status = LDConnectionStatus.error;
    }
    notifyListeners();
  }

  // ── Public: connect after app start (from Profile screen) ─
  Future<void> connectToLaunchDarkly({
    required String sdkKey,
    LDUserContext? context,
  }) async {
    final normalizedSdkKey = sdkKey.trim();
    if (normalizedSdkKey.isEmpty) return;
    final ctx = context ?? _userContext;
    if (_client != null) {
      await _client!.close();
      await _flagSub?.cancel();
      _client = null;
    }
    await _connectReal(normalizedSdkKey, ctx);

    // Keep the connection across browser reloads. Only save a key after the
    // client was created successfully; invalid credentials remain unsaved.
    if (_client != null && _status == LDConnectionStatus.connected) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ld_sdk_key', normalizedSdkKey);
    }
  }

  void disconnect() {
    _flagSub?.cancel();
    _client?.close();
    _client = null;
    _sdkKey = null;
    _status = LDConnectionStatus.disconnected;
    unawaited(SharedPreferences.getInstance().then((prefs) {
      return prefs.remove('ld_sdk_key');
    }));
    notifyListeners();
  }

  // ── Identify / switch user context ──────────────────────
  Future<void> identifyUser(LDUserContext context) async {
    _userContext = context;
    if (_client != null) {
      await _client!.identify(_toLDContext(context));
      _syncFlagsFromLD();
    } else {
      _applyMockTargeting(context);
    }
    notifyListeners();
  }

  // ── Flag readers ─────────────────────────────────────────
  bool getBool(String key, {bool defaultValue = false}) {
    if (_client != null) return _client!.boolVariation(key, defaultValue);
    final flag = _flags[key];
    return flag?.value as bool? ?? defaultValue;
  }

  String getString(String key, {String defaultValue = ''}) {
    if (_client != null) return _client!.stringVariation(key, defaultValue);
    final flag = _flags[key];
    return flag?.value as String? ?? defaultValue;
  }

  double getNumber(String key, {double defaultValue = 0.0}) {
    if (_client != null) return _client!.doubleVariation(key, defaultValue);
    final flag = _flags[key];
    final v = flag?.value;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return defaultValue;
  }

  Map<String, dynamic> getJson(String key,
      {Map<String, dynamic> defaultValue = const {}}) {
    if (_client != null) {
      final ldVal = _client!.jsonVariation(key, LDValue.ofNull());
      final parsed = _ldValueToDart(ldVal);
      return (parsed is Map<String, dynamic>) ? parsed : defaultValue;
    }
    final flag = _flags[key];
    final v = flag?.value;
    if (v is Map<String, dynamic>) return v;
    return defaultValue;
  }

  // ── Mock control (for demo mode) ─────────────────────────
  void setMockFlag(String key, dynamic value) {
    if (_flags.containsKey(key)) {
      _flags[key] = _flags[key]!.copyWithValue(value);
      notifyListeners();
    }
  }

  // ── Event tracking ───────────────────────────────────────
  void track(String eventName,
      {double? metricValue, Map<String, dynamic>? data}) {
    debugPrint('[LD Track] $eventName value=$metricValue');
    _client?.track(eventName, metricValue: metricValue);
  }

  // ── Internals ────────────────────────────────────────────

  // Converts our DTO to a real LDContext (single-kind or multi-kind)
  LDContext _toLDContext(LDUserContext ctx) {
    final builder = LDContextBuilder();

    final user = builder.kind('user', ctx.key);
    if (ctx.name != null) user.name(ctx.name!);
    if (ctx.email != null) user.setString('email', ctx.email!);
    if (ctx.role != null) user.setString('role', ctx.role!);
    user.setString('plan', ctx.plan);
    user.setString('country', ctx.country);
    user.setBool('betaTester', ctx.betaTester);
    for (final e in ctx.attributes.entries) {
      if (e.value is bool) {
        user.setBool(e.key, e.value as bool);
      } else if (e.value is num) {
        user.setNum(e.key, e.value as num);
      } else {
        user.setString(e.key, e.value.toString());
      }
    }

    // Add organization context → multi-context targeting
    if (ctx.organizationKey != null) {
      final org = builder.kind('organization', ctx.organizationKey!);
      if (ctx.organizationName != null) org.name(ctx.organizationName!);
      if (ctx.organizationPlan != null) {
        org.setString('plan', ctx.organizationPlan!);
      }
    }

    return builder.build();
  }

  // Pulls all flag values from real LDClient into _flags cache
  void _syncFlagsFromLD() {
    if (_client == null) return;
    for (final flag in _flags.values) {
      switch (flag.type) {
        case LDFlagType.boolean:
          _flags[flag.key] = flag.copyWithValue(
            _client!.boolVariation(flag.key, flag.defaultValue as bool),
          );
        case LDFlagType.string:
          _flags[flag.key] = flag.copyWithValue(
            _client!.stringVariation(flag.key, flag.defaultValue as String),
          );
        case LDFlagType.number:
          _flags[flag.key] = flag.copyWithValue(
            _client!.doubleVariation(
                flag.key, (flag.defaultValue as num).toDouble()),
          );
        case LDFlagType.json:
          final raw = _client!.jsonVariation(flag.key, LDValue.ofNull());
          final parsed = _ldValueToDart(raw);
          _flags[flag.key] = flag.copyWithValue(
            (parsed is Map<String, dynamic>) ? parsed : flag.defaultValue,
          );
      }
    }
  }

  // Simulates targeting rules in mock/demo mode
  void _applyMockTargeting(LDUserContext ctx) {
    final email = ctx.email ?? '';
    final role = ctx.role ?? 'user';
    final isAISStaff =
        email.endsWith('@ais.th') || email.endsWith('@ais.co.th');
    final isCorporate = role == 'corporate' || role == 'enterprise';
    final isVIP = email.contains('vip') || role == 'vip' || role == 'premium';

    setMockFlag(FlagKeys.showVipBenefits, isAISStaff || isVIP);
    setMockFlag(FlagKeys.showCorporatePackages, isCorporate || isAISStaff);

    if (isAISStaff) {
      setMockFlag(FlagKeys.enableAiAssistant, true);
      setMockFlag(FlagKeys.discountPercentage, 30.0);
    }

    if (ctx.country != 'TH') {
      setMockFlag(FlagKeys.heroBannerVariant, 'variant_b');
    }

    if (ctx.betaTester) {
      setMockFlag(FlagKeys.newCheckoutFlow, true);
      setMockFlag(FlagKeys.newPackageCard, true);
    }
  }

  // Converts LDValue → Dart native types for JSON flags
  dynamic _ldValueToDart(LDValue value) {
    switch (value.type) {
      case LDValueType.object:
        final map = <String, dynamic>{};
        for (final key in value.keys) {
          map[key] = _ldValueToDart(value.getFor(key));
        }
        return map;
      case LDValueType.array:
        final list = <dynamic>[];
        for (int i = 0; i < value.length; i++) {
          list.add(_ldValueToDart(value.get(i)));
        }
        return list;
      case LDValueType.string:
        return value.stringValue();
      case LDValueType.number:
        return value.doubleValue();
      case LDValueType.boolean:
        return value.booleanValue();
      default:
        return null;
    }
  }

  void _initDefaultFlags() {
    final defaults = [
      // 1. BOOLEAN FLAGS
      LDFlagInfo(
        key: FlagKeys.showPromoBanner,
        name: 'แสดง Promo Banner',
        description: 'เปิด/ปิดแบนเนอร์โปรโมชั่นบนหน้าหลัก',
        type: LDFlagType.boolean,
        value: true,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'ลองกด Toggle เพื่อซ่อน/แสดง Banner โปรโมชั่นบนหน้า Home',
        flagCategory: 'Boolean Flag',
      ),
      LDFlagInfo(
        key: FlagKeys.enableAiAssistant,
        name: 'เปิดใช้ AI Assistant',
        description: 'แสดง/ซ่อน AI Chat Assistant ในแอป',
        type: LDFlagType.boolean,
        value: false,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'เปิดเพื่อแสดง AI Assistant ปุ่มลอยที่มุมขวาล่าง',
        flagCategory: 'Boolean Flag',
      ),
      LDFlagInfo(
        key: FlagKeys.showNewNavbar,
        name: 'Navbar แบบใหม่',
        description: 'ทดสอบ Navigation Bar รูปแบบใหม่',
        type: LDFlagType.boolean,
        value: false,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'สลับระหว่าง Navbar แบบเดิมกับแบบใหม่ที่มี icon ใหญ่ขึ้น',
        flagCategory: 'Boolean Flag',
      ),

      // 2. MULTIVARIATE - STRING
      LDFlagInfo(
        key: FlagKeys.heroBannerVariant,
        name: 'Hero Banner Variant',
        description: 'เลือกดีไซน์ Hero Banner บนหน้าหลัก (A/B/C)',
        type: LDFlagType.string,
        value: 'variant_a',
        defaultValue: 'variant_a',
        possibleValues: ['variant_a', 'variant_b', 'variant_c'],
        demoHint: 'เปลี่ยน variant เพื่อดูการออกแบบ Banner ที่ต่างกัน 3 แบบ',
        flagCategory: 'Multivariate (String)',
      ),
      LDFlagInfo(
        key: FlagKeys.ctaButtonText,
        name: 'CTA Button Text',
        description: 'ข้อความปุ่มสมัครแพ็กเกจ (A/B Testing)',
        type: LDFlagType.string,
        value: 'สมัครเลย',
        defaultValue: 'สมัครเลย',
        possibleValues: [
          'สมัครเลย',
          'เลือกแพ็กเกจ',
          'ใช้งานได้ทันที',
          'รับสิทธิ์ทันที'
        ],
        demoHint:
            'เปลี่ยนข้อความปุ่มเพื่อทดสอบว่า CTA ไหนให้ Conversion ดีกว่า',
        flagCategory: 'Multivariate (String)',
      ),

      // 3. MULTIVARIATE - NUMBER
      LDFlagInfo(
        key: FlagKeys.discountPercentage,
        name: 'ส่วนลด (%)',
        description: 'เปอร์เซ็นต์ส่วนลดสำหรับแพ็กเกจ',
        type: LDFlagType.number,
        value: 0.0,
        defaultValue: 0.0,
        possibleValues: [0.0, 10.0, 20.0, 30.0],
        demoHint: 'ปรับส่วนลดแบบ Real-time โดยไม่ต้อง Deploy โค้ดใหม่',
        flagCategory: 'Multivariate (Number)',
      ),
      LDFlagInfo(
        key: FlagKeys.freeDataGb,
        name: 'โบนัสเน็ตฟรี (GB)',
        description: 'จำนวน GB โบนัสที่ได้รับเมื่อสมัครแพ็กเกจ',
        type: LDFlagType.number,
        value: 0.0,
        defaultValue: 0.0,
        possibleValues: [0.0, 5.0, 10.0, 20.0],
        demoHint: 'แจกเน็ตฟรีในช่วงโปรโมชั่น โดยเปลี่ยนค่าจาก Dashboard',
        flagCategory: 'Multivariate (Number)',
      ),

      // 4. MULTIVARIATE - JSON
      LDFlagInfo(
        key: FlagKeys.featuredPackagesConfig,
        name: 'Featured Packages Config',
        description: 'กำหนดแพ็กเกจแนะนำและรูปแบบการแสดงผล',
        type: LDFlagType.json,
        value: {
          'layout': 'grid',
          'count': 4,
          'highlight': 'surf_5g_299',
          'showPriceFirst': true,
        },
        defaultValue: {
          'layout': 'grid',
          'count': 4,
          'highlight': 'surf_5g_299',
          'showPriceFirst': true,
        },
        possibleValues: [
          {
            'layout': 'grid',
            'count': 4,
            'highlight': 'surf_5g_299',
            'showPriceFirst': true,
          },
          {
            'layout': 'list',
            'count': 6,
            'highlight': 'bundle_599',
            'showPriceFirst': false,
          },
          {
            'layout': 'carousel',
            'count': 8,
            'highlight': 'privilege_899',
            'showPriceFirst': true,
          },
        ],
        demoHint:
            'เปลี่ยน JSON Config เพื่อปรับ Layout, จำนวนและลำดับแพ็กเกจแนะนำ',
        flagCategory: 'Multivariate (JSON)',
      ),
      LDFlagInfo(
        key: FlagKeys.paymentMethodsConfig,
        name: 'Payment Methods Config',
        description: 'กำหนดช่องทางการชำระเงินที่แสดงในหน้า Checkout',
        type: LDFlagType.json,
        value: {
          'creditCard': true,
          'promptpay': true,
          'truemoney': false,
          'linepay': false,
          'installment': false,
          'crypto': false,
        },
        defaultValue: {
          'creditCard': true,
          'promptpay': true,
          'truemoney': false,
          'linepay': false,
          'installment': false,
          'crypto': false,
        },
        possibleValues: [],
        demoHint: 'เปิด/ปิดช่องทางชำระเงินแบบ Dynamic ไม่ต้อง Deploy ใหม่',
        flagCategory: 'Multivariate (JSON)',
      ),

      // 5. USER TARGETING
      LDFlagInfo(
        key: FlagKeys.showVipBenefits,
        name: 'แสดงสิทธิ์ VIP',
        description: 'แสดงแพ็กเกจและสิทธิพิเศษสำหรับลูกค้า VIP',
        type: LDFlagType.boolean,
        value: false,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'เปลี่ยน Email เป็น @ais.th เพื่อดูว่า VIP ได้รับอะไรพิเศษ',
        flagCategory: 'User Targeting',
      ),
      LDFlagInfo(
        key: FlagKeys.showCorporatePackages,
        name: 'แสดงแพ็กเกจองค์กร',
        description: 'แสดงแพ็กเกจ Corporate สำหรับลูกค้าธุรกิจ',
        type: LDFlagType.boolean,
        value: false,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'ตั้ง role เป็น "corporate" เพื่อเปิดดูแพ็กเกจองค์กร',
        flagCategory: 'User Targeting',
      ),

      // 6. PERCENTAGE ROLLOUT
      LDFlagInfo(
        key: FlagKeys.newCheckoutFlow,
        name: 'Checkout Flow ใหม่',
        description: 'ทยอยปล่อย Checkout Flow ใหม่แบบ Percentage Rollout',
        type: LDFlagType.boolean,
        value: false,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'จำลอง Rollout 0% → 50% → 100% เพื่อเห็น New Checkout',
        flagCategory: 'Percentage Rollout',
      ),
      LDFlagInfo(
        key: FlagKeys.newPackageCard,
        name: 'Package Card แบบใหม่',
        description: 'ทยอยปล่อย Package Card Design ใหม่',
        type: LDFlagType.boolean,
        value: false,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'ดูการออกแบบ Card แบบใหม่ที่ทยอยปล่อยให้ผู้ใช้',
        flagCategory: 'Percentage Rollout',
      ),

      // 7. KILL SWITCH
      LDFlagInfo(
        key: FlagKeys.maintenanceMode,
        name: '🚨 Kill Switch (Maintenance)',
        description: 'ปิดระบบฉุกเฉินทันทีเมื่อพบปัญหา',
        type: LDFlagType.boolean,
        value: false,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint: 'กด Toggle เพื่อดูหน้า Maintenance ที่แสดงแทนทันที (< 200ms)',
        flagCategory: 'Kill Switch',
      ),

      // 8. SCHEDULED CHANGES
      LDFlagInfo(
        key: FlagKeys.seasonalPromo,
        name: 'โปรโมชั่นตามฤดูกาล',
        description: 'เปิด/ปิดโปรโมชั่นตามเวลาที่ตั้งไว้อัตโนมัติ',
        type: LDFlagType.boolean,
        value: true,
        defaultValue: false,
        possibleValues: [true, false],
        demoHint:
            'ใน LD Dashboard ตั้งเวลาเปิด 00:00 น. และปิด 23:59 น. อัตโนมัติ',
        flagCategory: 'Scheduled Changes',
      ),

      // 9. EXPERIMENTATION
      LDFlagInfo(
        key: FlagKeys.checkoutButtonColor,
        name: 'Checkout Button Color (A/B)',
        description: 'ทดสอบสีปุ่ม Checkout ว่าสีไหน Conversion ดีกว่า',
        type: LDFlagType.string,
        value: 'green',
        defaultValue: 'green',
        possibleValues: ['green', 'orange', 'blue', 'red'],
        demoHint:
            'วัดผลคลิก Checkout ตามสีปุ่ม — เชื่อมกับ Metric ใน Experiments',
        flagCategory: 'Experimentation (A/B)',
      ),

      // 10. AI CONFIG
      LDFlagInfo(
        key: FlagKeys.aiModelConfig,
        name: 'AI Model Config',
        description: 'ปรับ Model และ Prompt ของ AI Assistant แบบ Real-time',
        type: LDFlagType.json,
        value: {
          'model': 'claude-sonnet-4-6',
          'temperature': 0.7,
          'maxTokens': 1000,
          'systemPrompt':
              'คุณคือ AIS Assistant ผู้ช่วยอัจฉริยะของ AIS ช่วยแนะนำแพ็กเกจที่เหมาะสมสำหรับลูกค้า ตอบเป็นภาษาไทยและเป็นกันเอง',
          'fallbackModel': 'claude-haiku-4-5',
        },
        defaultValue: {
          'model': 'claude-sonnet-4-6',
          'temperature': 0.7,
          'maxTokens': 1000,
          'systemPrompt': 'คุณคือ AIS Assistant ผู้ช่วยอัจฉริยะของ AIS',
          'fallbackModel': 'claude-haiku-4-5',
        },
        possibleValues: [],
        demoHint:
            'เปลี่ยน Model หรือ System Prompt ของ AI โดยไม่ต้อง Deploy ใหม่',
        flagCategory: 'AI Config',
      ),
    ];

    for (final flag in defaults) {
      _flags[flag.key] = flag;
    }
  }

  @override
  void dispose() {
    _flagSub?.cancel();
    _client?.close();
    super.dispose();
  }
}
