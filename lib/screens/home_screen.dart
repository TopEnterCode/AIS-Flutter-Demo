import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/package_card.dart';
import '../services/ld_service.dart';
import '../data/packages_data.dart';
import '../models/package.dart';
import '../constants/flag_keys.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isMaintenance = ldService.getBool(FlagKeys.maintenanceMode);

    if (isMaintenance) {
      return const _MaintenanceScreen();
    }

    return Scaffold(
      appBar: const AISNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeroBanner(),
            const _QuickActions(),
            const _FeaturedPackages(),
            const _CategoryCards(),
            const _PromoSection(),
            const _AppDownloadSection(),
            const _Footer(),
          ],
        ),
      ),
      floatingActionButton:
          context.watch<LDService>().getBool(FlagKeys.enableAiAssistant)
              ? const _AIAssistantFAB()
              : null,
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.phone_android, 'แพ็กเกจมือถือ', '/packages?category=postpaid'),
      (Icons.wifi, 'AIS Fibre', '/packages?category=fiber'),
      (Icons.flight, 'โรมมิ่ง', '/packages?category=international'),
      (Icons.home, 'สมาร์ทโฮม', '/packages?category=bundle'),
      (Icons.shopping_cart, 'ตะกร้า', '/cart'),
      (Icons.person, 'โปรไฟล์', '/profile'),
      (Icons.toggle_on, 'LD Demo', '/ld-demo'),
      (Icons.payments_outlined, 'mPAY Demo', '/launchdarkly-mpay-demo'),
      (Icons.store, 'ทั้งหมด', '/packages'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            childAspectRatio: 1.2,
            children: actions.map((action) {
              final isLD = action.$1 == Icons.toggle_on;
              return GestureDetector(
                onTap: () => context.go(action.$3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isLD
                            ? AISColors.ldBlue.withOpacity(0.1)
                            : AISColors.lightGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        action.$1,
                        color: isLD ? AISColors.ldBlue : AISColors.primaryGreen,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.$2,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AISColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeaturedPackages extends StatelessWidget {
  const _FeaturedPackages();

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final config = ldService.getJson(FlagKeys.featuredPackagesConfig);
    final layout = config['layout'] as String? ?? 'grid';
    final count = (config['count'] as num?)?.toInt() ?? 4;
    final isWide = MediaQuery.of(context).size.width > 900;

    final packages = PackagesData.featured().take(count).toList();

    return Container(
      color: AISColors.background,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'แพ็กเกจแนะนำ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AISColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AISColors.ldBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AISColors.ldBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: AISColors.ldBlue),
                    const SizedBox(width: 4),
                    Text(
                      'JSON Config: layout=$layout, count=$count',
                      style: TextStyle(fontSize: 10, color: AISColors.ldBlue),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/packages'),
                child: const Text('ดูทั้งหมด →'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (layout == 'grid' || layout == 'carousel')
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isWide ? 0.62 : 0.7,
              ),
              itemCount: packages.length,
              itemBuilder: (ctx, i) => PackageCard(
                package: packages[i],
                compact: true,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => SizedBox(
                height: 200,
                child: PackageCard(package: packages[i], compact: true),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryCards extends StatelessWidget {
  const _CategoryCards();

  @override
  Widget build(BuildContext context) {
    final categories = [
      (
        PackageCategory.postpaid,
        '📱',
        'มือถือรายเดือน',
        'แพ็กเกจ Postpaid 5G ไม่อั้น'
      ),
      (PackageCategory.prepaid, '💳', 'เติมเงิน', 'แพ็กเกจ Prepaid คุ้มค่า'),
      (PackageCategory.fiber, '🌐', 'AIS Fibre', 'อินเทอร์เน็ตบ้านความเร็วสูง'),
      (
        PackageCategory.bundle,
        '📦',
        'บันเดิลพิเศษ',
        'มือถือ + ไฟเบอร์ ราคาประหยัด'
      ),
      (
        PackageCategory.international,
        '✈️',
        'โรมมิ่งต่างประเทศ',
        'ใช้งานได้ใน 100+ ประเทศ'
      ),
    ];

    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เลือกตามประเภท',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AISColors.textDark),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 5 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isWide ? 1.2 : 2.0,
            children: categories.map((cat) {
              return GestureDetector(
                onTap: () => context.go('/packages?category=${cat.$1.name}'),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AISColors.primaryGreen,
                        AISColors.mediumGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.$2, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(
                        cat.$3,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.$4,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PromoSection extends StatelessWidget {
  const _PromoSection();

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final showSeasonal = ldService.getBool(FlagKeys.seasonalPromo);
    final discountPct = ldService.getNumber(FlagKeys.discountPercentage);
    final freeData = ldService.getNumber(FlagKeys.freeDataGb);

    if (!showSeasonal && discountPct == 0 && freeData == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AISColors.background,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎉 ', style: TextStyle(fontSize: 22)),
              const Text(
                'โปรโมชั่นพิเศษ',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AISColors.textDark),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AISColors.ldYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: AISColors.ldYellow.withOpacity(0.5)),
                ),
                child: const Text(
                  'Scheduled Changes',
                  style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFB07D00),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (discountPct > 0)
                Expanded(
                  child: _PromoCard(
                    icon: '🏷️',
                    title: 'ลด ${discountPct.toInt()}% ทุกแพ็กเกจ',
                    subtitle: 'จำกัดเวลา สมัครเลยก่อนหมดโปรโมชั่น',
                    color: Colors.red,
                  ),
                ),
              if (discountPct > 0 && freeData > 0) const SizedBox(width: 12),
              if (freeData > 0)
                Expanded(
                  child: _PromoCard(
                    icon: '📶',
                    title: 'ฟรีเน็ต ${freeData.toInt()} GB',
                    subtitle: 'รับโบนัสเน็ตฟรีทันทีเมื่อสมัคร',
                    color: AISColors.primaryGreen,
                  ),
                ),
              if (showSeasonal && discountPct == 0 && freeData == 0)
                Expanded(
                  child: _PromoCard(
                    icon: '🎊',
                    title: 'โปรโมชั่นตามฤดูกาล',
                    subtitle: 'ข้อเสนอพิเศษเฉพาะช่วงเวลานี้',
                    color: AISColors.primaryGreen,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  const _PromoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDownloadSection extends StatelessWidget {
  const _AppDownloadSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AISColors.primaryGreen,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_iphone, color: Colors.white, size: 48),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ดาวน์โหลด myAIS App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'จัดการแพ็กเกจ เติมเงิน และดูบิลได้ทุกที่',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StoreButton(
                    icon: Icons.apple,
                    label: 'App Store',
                    sub: 'ดาวน์โหลดสำหรับ iOS',
                  ),
                  const SizedBox(width: 12),
                  _StoreButton(
                    icon: Icons.android,
                    label: 'Google Play',
                    sub: 'ดาวน์โหลดสำหรับ Android',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _StoreButton(
      {required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sub,
                  style: const TextStyle(color: Colors.white60, fontSize: 10)),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AISColors.navGreen,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('© 2025 AIS (Advanced Info Service PLC)',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AISColors.ldBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Powered by LaunchDarkly Feature Flags',
                  style: TextStyle(color: AISColors.ldBlue, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AIAssistantFAB extends StatefulWidget {
  const _AIAssistantFAB();

  @override
  State<_AIAssistantFAB> createState() => _AIAssistantFABState();
}

class _AIAssistantFABState extends State<_AIAssistantFAB> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final aiConfig = context.watch<LDService>().getJson(FlagKeys.aiModelConfig);
    final model = aiConfig['model'] as String? ?? 'claude-sonnet-4-6';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          Container(
            width: 280,
            height: 320,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AISColors.primaryGreen, AISColors.mediumGreen],
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.smart_toy,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('AIS AI Assistant',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AISColors.ldBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          model.split('-').take(2).join('-'),
                          style: const TextStyle(
                              color: AISColors.ldBlue, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            color: AISColors.lightGreen, size: 40),
                        SizedBox(height: 8),
                        Text('สวัสดีครับ! ผมคือ AIS Assistant',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('ต้องการความช่วยเหลือด้านแพ็กเกจ?',
                            style: TextStyle(
                                color: AISColors.textMedium, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'พิมพ์คำถาม...',
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AISColors.limeGreen,
                        child: const Icon(Icons.send,
                            color: AISColors.primaryGreen, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        FloatingActionButton.extended(
          onPressed: () => setState(() => _open = !_open),
          backgroundColor: AISColors.primaryGreen,
          icon: Icon(_open ? Icons.close : Icons.chat, color: Colors.white),
          label: Text(
            _open ? 'ปิด' : 'AI Assistant',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _MaintenanceScreen extends StatelessWidget {
  const _MaintenanceScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AISColors.navGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle_outlined,
                color: AISColors.limeGreen, size: 80),
            const SizedBox(height: 24),
            const Text(
              'ระบบกำลังปรับปรุง',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'ขออภัยในความไม่สะดวก\nกรุณากลับมาใหม่ในภายหลัง',
              style:
                  TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '🚨 Kill Switch Active — Maintenance Mode ON',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/ld-demo'),
              icon: const Icon(Icons.toggle_off),
              label: const Text('ไปที่ LaunchDarkly Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
