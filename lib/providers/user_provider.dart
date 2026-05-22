import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ld_service.dart';

class UserProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  String _userKey = 'demo-user-001';
  String _name = 'Demo User';
  String _email = 'demo@example.com';
  String _role = 'user';
  String _plan = 'free';
  String _country = 'TH';
  bool _betaTester = false;
  bool _isLoggedIn = false;

  String get userKey => _userKey;
  String get name => _name;
  String get email => _email;
  String get role => _role;
  String get plan => _plan;
  String get country => _country;
  bool get betaTester => _betaTester;
  bool get isLoggedIn => _isLoggedIn;

  bool get isAISStaff =>
      _email.endsWith('@ais.th') || _email.endsWith('@ais.co.th');
  bool get isVIP =>
      _email.contains('vip') || _role == 'vip' || _role == 'premium';
  bool get isCorporate => _role == 'corporate' || _role == 'enterprise';

  String get avatarInitial =>
      _name.isNotEmpty ? _name[0].toUpperCase() : 'U';

  UserProvider(this._prefs) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    _userKey = _prefs.getString('user_key') ?? 'demo-user-001';
    _name = _prefs.getString('user_name') ?? 'Demo User';
    _email = _prefs.getString('user_email') ?? 'demo@example.com';
    _role = _prefs.getString('user_role') ?? 'user';
    _plan = _prefs.getString('user_plan') ?? 'free';
    _country = _prefs.getString('user_country') ?? 'TH';
    _betaTester = _prefs.getBool('user_beta_tester') ?? false;
    _isLoggedIn = _prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> login({
    required String name,
    required String email,
    String role = 'user',
    String plan = 'free',
    String country = 'TH',
    bool betaTester = false,
  }) async {
    _name = name;
    _email = email;
    _role = role;
    _plan = plan;
    _country = country;
    _betaTester = betaTester;
    _userKey = 'user-${email.replaceAll('@', '-').replaceAll('.', '-')}';
    _isLoggedIn = true;

    await Future.wait([
      _prefs.setString('user_key', _userKey),
      _prefs.setString('user_name', _name),
      _prefs.setString('user_email', _email),
      _prefs.setString('user_role', _role),
      _prefs.setString('user_plan', _plan),
      _prefs.setString('user_country', _country),
      _prefs.setBool('user_beta_tester', _betaTester),
      _prefs.setBool('is_logged_in', true),
    ]);

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs.setBool('is_logged_in', false);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? role,
    String? plan,
    String? country,
    bool? betaTester,
  }) async {
    if (name != null) {
      _name = name;
      await _prefs.setString('user_name', name);
    }
    if (email != null) {
      _email = email;
      await _prefs.setString('user_email', email);
    }
    if (role != null) {
      _role = role;
      await _prefs.setString('user_role', role);
    }
    if (plan != null) {
      _plan = plan;
      await _prefs.setString('user_plan', plan);
    }
    if (country != null) {
      _country = country;
      await _prefs.setString('user_country', country);
    }
    if (betaTester != null) {
      _betaTester = betaTester;
      await _prefs.setBool('user_beta_tester', betaTester);
    }
    notifyListeners();
  }

  // Applies a persona from LDContextFactory directly — updates all fields at once
  Future<void> applyPersona(LDUserContext ctx) async {
    _userKey = ctx.key;
    _name = ctx.name ?? _name;
    _email = ctx.email ?? _email;
    _role = ctx.role ?? 'user';
    _plan = ctx.plan;
    _country = ctx.country;
    _betaTester = ctx.betaTester;
    _isLoggedIn = true;

    await Future.wait([
      _prefs.setString('user_key', _userKey),
      _prefs.setString('user_name', _name),
      _prefs.setString('user_email', _email),
      _prefs.setString('user_role', _role),
      _prefs.setString('user_plan', _plan),
      _prefs.setString('user_country', _country),
      _prefs.setBool('user_beta_tester', _betaTester),
      _prefs.setBool('is_logged_in', true),
    ]);

    notifyListeners();
  }

  LDUserContext toLDContext() => LDUserContext(
        key: _userKey,
        name: _name,
        email: _email,
        role: _role,
        plan: _plan,
        country: _country,
        betaTester: _betaTester,
        attributes: {
          'isVIP': isVIP,
          'isCorporate': isCorporate,
          'isAISStaff': isAISStaff,
        },
      );
}
