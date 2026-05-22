import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/package.dart';
import '../theme/ais_theme.dart';
import '../providers/cart_provider.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';
import 'package:intl/intl.dart';

final _currencyFmt = NumberFormat('#,##0', 'th_TH');

class PackageCard extends StatefulWidget {
  final AISPackage package;
  final bool compact;

  const PackageCard({
    super.key,
    required this.package,
    this.compact = false,
  });

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final cart = context.watch<CartProvider>();
    final useNewCard = ldService.getBool(FlagKeys.newPackageCard);
    final discountPct = ldService.getNumber(FlagKeys.discountPercentage);
    final ctaText = ldService.getString(FlagKeys.ctaButtonText, defaultValue: 'สมัครเลย');
    final buttonColor = ldService.getString(FlagKeys.checkoutButtonColor, defaultValue: 'green');

    final inCart = cart.contains(widget.package.id);

    if (useNewCard) {
      return _NewStyleCard(
        package: widget.package,
        discountPct: discountPct,
        ctaText: ctaText,
        inCart: inCart,
        buttonColor: buttonColor,
        compact: widget.compact,
      );
    }

    return _ClassicCard(
      package: widget.package,
      discountPct: discountPct,
      ctaText: ctaText,
      inCart: inCart,
      buttonColor: buttonColor,
      compact: widget.compact,
    );
  }
}

class _ClassicCard extends StatelessWidget {
  final AISPackage package;
  final double discountPct;
  final String ctaText;
  final bool inCart;
  final String buttonColor;
  final bool compact;

  const _ClassicCard({
    required this.package,
    required this.discountPct,
    required this.ctaText,
    required this.inCart,
    required this.buttonColor,
    required this.compact,
  });

  Color get _buttonColor {
    switch (buttonColor) {
      case 'orange':
        return const Color(0xFFFF7628);
      case 'blue':
        return const Color(0xFF2196F3);
      case 'red':
        return const Color(0xFFE53935);
      default:
        return AISColors.limeGreen;
    }
  }

  double get discountedPrice =>
      discountPct > 0 ? package.price * (1 - discountPct / 100) : package.price;

  @override
  Widget build(BuildContext context) {
    final headerColor = package.colorHex != null
        ? Color(int.parse(package.colorHex!.replaceFirst('#', '0xFF')))
        : AISColors.primaryGreen;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/packages/${package.id}'),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: headerColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            package.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (package.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AISColors.limeGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              package.badge!,
                              style: const TextStyle(
                                color: AISColors.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (discountPct > 0) ...[
                          Text(
                            '${_currencyFmt.format(package.price)} บาท',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _currencyFmt.format(discountedPrice),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          package.priceUnit,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (discountPct > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ลด ${discountPct.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Network badge
              if (package.networkType != null)
                Container(
                  color: headerColor.withOpacity(0.15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AIS ${package.networkType}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Features
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: package.features
                        .take(compact ? 3 : 4)
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AISColors.limeGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    f,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              // CTA Button
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (inCart) {
                        context.go('/cart');
                      } else {
                        context
                            .read<CartProvider>()
                            .addItem(package);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${package.name} เพิ่มในตะกร้าแล้ว'),
                            backgroundColor: AISColors.successGreen,
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'ดูตะกร้า',
                              textColor: AISColors.limeGreen,
                              onPressed: () => context.go('/cart'),
                            ),
                          ),
                        );
                        // Track experiment
                        context.read<LDService>().track(
                          'package-added-to-cart',
                          metricValue: package.price,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          inCart ? AISColors.primaryGreen : _buttonColor,
                      foregroundColor:
                          inCart ? Colors.white : AISColors.primaryGreen,
                    ),
                    child: Text(inCart ? 'ดูตะกร้า' : ctaText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewStyleCard extends StatelessWidget {
  final AISPackage package;
  final double discountPct;
  final String ctaText;
  final bool inCart;
  final String buttonColor;
  final bool compact;

  const _NewStyleCard({
    required this.package,
    required this.discountPct,
    required this.ctaText,
    required this.inCart,
    required this.buttonColor,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = package.colorHex != null
        ? Color(int.parse(package.colorHex!.replaceFirst('#', '0xFF')))
        : AISColors.primaryGreen;
    final discountedPrice =
        discountPct > 0 ? package.price * (1 - discountPct / 100) : package.price;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: headerColor.withOpacity(0.3), width: 1),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gradient header
              Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [headerColor, AISColors.limeGreen],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AISColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AISColors.textMedium,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: headerColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _currencyFmt.format(discountedPrice),
                            style: TextStyle(
                              color: headerColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            package.priceUnit,
                            style: const TextStyle(
                              color: AISColors.textMedium,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...package.features.take(3).map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: headerColor, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(f,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!inCart) {
                            context.read<CartProvider>().addItem(package);
                          }
                          context.go('/cart');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: headerColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(inCart ? 'ดูตะกร้า' : ctaText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (package.badge != null)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AISColors.limeGreen, Color(0xFF8DC63F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  package.badge!,
                  style: const TextStyle(
                    color: AISColors.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (discountPct > 0)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${discountPct.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
