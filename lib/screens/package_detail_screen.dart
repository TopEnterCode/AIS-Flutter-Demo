import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';
import '../widgets/package_card.dart';
import '../data/packages_data.dart';
import '../models/package.dart';
import '../providers/cart_provider.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';

final _fmt = NumberFormat('#,##0', 'th_TH');

class PackageDetailScreen extends StatelessWidget {
  final String packageId;
  const PackageDetailScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    final pkg = PackagesData.byId(packageId);
    if (pkg == null) {
      return Scaffold(
        appBar: const AISNavBar(),
        body: const Center(child: Text('ไม่พบแพ็กเกจ')),
      );
    }
    return _DetailContent(package: pkg);
  }
}

class _DetailContent extends StatelessWidget {
  final AISPackage package;
  const _DetailContent({required this.package});

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final cart = context.watch<CartProvider>();
    final discountPct = ldService.getNumber(FlagKeys.discountPercentage);
    final freeData = ldService.getNumber(FlagKeys.freeDataGb);
    final ctaText = ldService.getString(FlagKeys.ctaButtonText, defaultValue: 'สมัครเลย');
    final showVip = ldService.getBool(FlagKeys.showVipBenefits);
    final inCart = cart.contains(package.id);

    final headerColor = package.colorHex != null
        ? Color(int.parse(package.colorHex!.replaceFirst('#', '0xFF')))
        : AISColors.primaryGreen;

    final discountedPrice =
        discountPct > 0 ? package.price * (1 - discountPct / 100) : package.price;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: const AISNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [headerColor, headerColor.withOpacity(0.7)],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: 40,
              ),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: _HeroText(
                          package: package,
                          discountedPrice: discountedPrice,
                          discountPct: discountPct,
                          freeData: freeData,
                        )),
                        Expanded(
                            flex: 2,
                            child: _PackageVisual(package: package)),
                      ],
                    )
                  : _HeroText(
                      package: package,
                      discountedPrice: discountedPrice,
                      discountPct: discountPct,
                      freeData: freeData,
                    ),
            ),

            // Body
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: 32,
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _FeaturesList(package: package)),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 2,
                          child: _OrderCard(
                            package: package,
                            discountedPrice: discountedPrice,
                            discountPct: discountPct,
                            freeData: freeData,
                            ctaText: ctaText,
                            inCart: inCart,
                            showVip: showVip,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _FeaturesList(package: package),
                        const SizedBox(height: 24),
                        _OrderCard(
                          package: package,
                          discountedPrice: discountedPrice,
                          discountPct: discountPct,
                          freeData: freeData,
                          ctaText: ctaText,
                          inCart: inCart,
                          showVip: showVip,
                        ),
                      ],
                    ),
            ),

            // Related packages
            _RelatedPackages(category: package.category, currentId: package.id),
          ],
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final AISPackage package;
  final double discountedPrice;
  final double discountPct;
  final double freeData;
  const _HeroText({
    required this.package,
    required this.discountedPrice,
    required this.discountPct,
    required this.freeData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (package.badge != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AISColors.limeGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              package.badge!,
              style: const TextStyle(
                color: AISColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          package.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          package.description,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (discountPct > 0) ...[
              Text(
                '${_fmt.format(package.price)} บาท',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              _fmt.format(discountedPrice),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              package.priceUnit,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        if (discountPct > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ประหยัด ${_fmt.format(package.price - discountedPrice)} บาท/เดือน',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        if (freeData > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '🎁 ฟรีเน็ตโบนัส ${freeData.toInt()} GB',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
      ],
    );
  }
}

class _PackageVisual extends StatelessWidget {
  final AISPackage package;
  const _PackageVisual({required this.package});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(package.category.icon, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              package.networkType ?? package.category.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (package.unlimitedData)
              const Text('ไม่จำกัด',
                  style: TextStyle(color: Colors.white70, fontSize: 14))
            else if (package.dataGb != null)
              Text('${package.dataGb} GB',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  final AISPackage package;
  const _FeaturesList({required this.package});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายละเอียดแพ็กเกจ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AISColors.textDark),
            ),
            const SizedBox(height: 16),
            ...package.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AISColors.limeGreen, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(f,
                          style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
            if (package.speedMbps != null) ...[
              const Divider(height: 24),
              _SpecRow('ความเร็ว',
                  '${_fmt.format(package.speedMbps)} Mbps'),
            ],
            if (package.voiceMinutes != null) ...[
              _SpecRow(
                  'โทรฟรี',
                  package.voiceMinutes == -1
                      ? 'ไม่จำกัด'
                      : '${package.voiceMinutes} นาที/เดือน'),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AISColors.textMedium, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AISPackage package;
  final double discountedPrice;
  final double discountPct;
  final double freeData;
  final String ctaText;
  final bool inCart;
  final bool showVip;

  const _OrderCard({
    required this.package,
    required this.discountedPrice,
    required this.discountPct,
    required this.freeData,
    required this.ctaText,
    required this.inCart,
    required this.showVip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('สรุปคำสั่งซื้อ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AISColors.textDark)),
            const SizedBox(height: 16),
            _OrderRow('ราคา', '${_fmt.format(package.price)} บาท'),
            if (discountPct > 0) ...[
              _OrderRow('ส่วนลด ${discountPct.toInt()}%',
                  '-${_fmt.format(package.price - discountedPrice)} บาท',
                  valueColor: Colors.red),
            ],
            if (freeData > 0)
              _OrderRow('โบนัสเน็ต', '+${freeData.toInt()} GB',
                  valueColor: AISColors.successGreen),
            const Divider(height: 20),
            _OrderRow(
              'รวมทั้งสิ้น',
              '${_fmt.format(discountedPrice)} ${package.priceUnit}',
              bold: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!inCart) {
                  context.read<CartProvider>().addItem(package);
                }
                context.go('/cart');
                context.read<LDService>().track(
                  'package-detail-cta-clicked',
                  metricValue: discountedPrice,
                  data: {'packageId': package.id, 'variant': 'detail'},
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(inCart ? 'ดูตะกร้าสินค้า' : ctaText,
                  style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/packages'),
              child: const Text('เปรียบเทียบแพ็กเกจ'),
            ),
            if (showVip) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AISColors.gold.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Text('👑', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'VIP: ฟรีสมัครรายปี เพิ่มอีก 2 เดือน',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB07D00),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _OrderRow(this.label, this.value,
      {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: AISColors.textMedium,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? AISColors.textDark)),
        ],
      ),
    );
  }
}

class _RelatedPackages extends StatelessWidget {
  final PackageCategory category;
  final String currentId;
  const _RelatedPackages({required this.category, required this.currentId});

  @override
  Widget build(BuildContext context) {
    final related = PackagesData.byCategory(category)
        .where((p) => p.id != currentId)
        .take(3)
        .toList();
    if (related.isEmpty) return const SizedBox.shrink();

    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: AISColors.background,
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'แพ็กเกจที่เกี่ยวข้อง',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AISColors.textDark),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isWide ? 0.65 : 2.0,
            ),
            itemCount: related.length,
            itemBuilder: (ctx, i) => PackageCard(
              package: related[i],
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}
