import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/ais_theme.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';

class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final variant = ldService.getString(FlagKeys.heroBannerVariant, defaultValue: 'variant_a');
    final showPromo = ldService.getBool(FlagKeys.showPromoBanner);
    final discountPct = ldService.getNumber(FlagKeys.discountPercentage);
    final freeData = ldService.getNumber(FlagKeys.freeDataGb);

    return Column(
      children: [
        _buildBannerForVariant(context, variant, discountPct, freeData),
        if (showPromo)
          _PromoBannerStrip(discountPct: discountPct, freeData: freeData),
      ],
    );
  }

  Widget _buildBannerForVariant(
    BuildContext context,
    String variant,
    double discountPct,
    double freeData,
  ) {
    switch (variant) {
      case 'variant_b':
        return _BannerVariantB(discountPct: discountPct, freeData: freeData);
      case 'variant_c':
        return _BannerVariantC(discountPct: discountPct, freeData: freeData);
      default:
        return _BannerVariantA(discountPct: discountPct, freeData: freeData);
    }
  }
}

class _BannerVariantA extends StatelessWidget {
  final double discountPct;
  final double freeData;
  const _BannerVariantA({required this.discountPct, required this.freeData});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AISColors.navGreen, AISColors.primaryGreen, Color(0xFF1E5128)],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(painter: _WavePainter()),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 60 : 24,
              vertical: 40,
            ),
            child: isWide
                ? Row(
                    children: [
                      Expanded(flex: 3, child: _BannerTextContent(
                        variant: 'A',
                        discountPct: discountPct,
                        freeData: freeData,
                      )),
                      Expanded(flex: 2, child: _BannerPhoneIllustration()),
                    ],
                  )
                : _BannerTextContent(
                    variant: 'A',
                    discountPct: discountPct,
                    freeData: freeData,
                  ),
          ),
        ],
      ),
    );
  }
}

class _BannerVariantB extends StatelessWidget {
  final double discountPct;
  final double freeData;
  const _BannerVariantB({required this.discountPct, required this.freeData});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF1B5E20),
            AISColors.limeGreen.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 60 : 24,
              vertical: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AISColors.limeGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('🎉 AIS 5G พร้อมให้คุณแล้ว',
                      style: TextStyle(
                          color: AISColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
                const SizedBox(height: 16),
                Text(
                  discountPct > 0
                      ? 'ประหยัดทันที ${discountPct.toInt()}%'
                      : 'เชื่อมต่อโลกด้วย 5G',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'แพ็กเกจเริ่มต้น 199 บาท/เดือน${freeData > 0 ? '\nฟรีเน็ตโบนัส ${freeData.toInt()} GB' : ''}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go('/packages'),
                      child: const Text('ดูแพ็กเกจ'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/packages'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      child: const Text('เรียนรู้เพิ่มเติม'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerVariantC extends StatelessWidget {
  final double discountPct;
  final double freeData;
  const _BannerVariantC({required this.discountPct, required this.freeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 440),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              color: AISColors.navGreen,
            ),
          ),
          // Grid pattern
          CustomPaint(painter: _GridPainter()),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AISColors.limeGreen, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('NEW',
                                style: TextStyle(
                                    color: AISColors.limeGreen,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          const Text('AIS 5G Network',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'สัมผัสประสบการณ์\n5G เต็มสปีด',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (discountPct > 0)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFEE0979)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ลด ${discountPct.toInt()}% ทันที',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/packages'),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('เลือกแพ็กเกจ 5G'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AISColors.limeGreen,
                          foregroundColor: AISColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                const _BannerPhoneIllustration(),
              ],
            ),
          ),
          // Variant label
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AISColors.ldBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Variant C',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerTextContent extends StatelessWidget {
  final String variant;
  final double discountPct;
  final double freeData;
  const _BannerTextContent({
    required this.variant,
    required this.discountPct,
    required this.freeData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AISColors.limeGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AISColors.limeGreen.withOpacity(0.5)),
          ),
          child: Text(
            '🎯 Hero Banner — Variant $variant',
            style: const TextStyle(
              color: AISColors.limeGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          discountPct > 0
              ? 'เน็ต 5G ไม่อั้น\nลดทันที ${discountPct.toInt()}%'
              : 'เน็ต 5G ไม่อั้น\nเริ่มต้น 299 บาท',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'โทรฟรีทุกเครือข่าย ไม่จำกัด${freeData > 0 ? '\n+ เน็ตโบนัสฟรี ${freeData.toInt()} GB' : ''}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/packages'),
              child: const Text('สมัครเลย'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => context.go('/packages'),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Row(
                children: [
                  Text('ดูแพ็กเกจทั้งหมด'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BannerPhoneIllustration extends StatelessWidget {
  const _BannerPhoneIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160,
              height: 280,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: AISColors.limeGreen.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AISColors.limeGreen.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi, color: AISColors.limeGreen, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    '5G',
                    style: TextStyle(
                      color: AISColors.limeGreen,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'ความเร็วสูงสุด',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AISColors.limeGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '1 Gbps',
                      style: TextStyle(
                          color: AISColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerStrip extends StatelessWidget {
  final double discountPct;
  final double freeData;
  const _PromoBannerStrip({required this.discountPct, required this.freeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AISColors.limeGreen, Color(0xFF8DC63F)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_offer, color: AISColors.primaryGreen, size: 18),
          const SizedBox(width: 8),
          Text(
            discountPct > 0
                ? '🔥 โปรพิเศษ! ลด ${discountPct.toInt()}% ทุกแพ็กเกจ${freeData > 0 ? ' + ฟรีเน็ต ${freeData.toInt()} GB' : ''}'
                : freeData > 0
                    ? '🎁 สมัครวันนี้ รับเน็ตฟรี ${freeData.toInt()} GB ทันที!'
                    : '📱 AIS 5G ครอบคลุมทั่วประเทศ — สมัครเลยไม่มีสัญญาผูกมัด',
            style: const TextStyle(
              color: AISColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.go('/packages'),
            style: TextButton.styleFrom(
              foregroundColor: AISColors.primaryGreen,
              padding: EdgeInsets.zero,
            ),
            child: const Row(
              children: [
                Text('ดูโปรโมชั่น',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painters
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(0, size.height * (0.3 + i * 0.15));
      path.quadraticBezierTo(
        size.width * 0.3,
        size.height * (0.1 + i * 0.15),
        size.width * 0.6,
        size.height * (0.4 + i * 0.1),
      );
      path.quadraticBezierTo(
        size.width * 0.8,
        size.height * (0.6 + i * 0.05),
        size.width,
        size.height * (0.3 + i * 0.12),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
