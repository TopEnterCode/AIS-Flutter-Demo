import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';
import '../providers/cart_provider.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';

final _fmt = NumberFormat('#,##0', 'th_TH');

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final ldService = context.watch<LDService>();
    final discountPct = ldService.getNumber(FlagKeys.discountPercentage);
    cart.setDiscount(discountPct);

    return Scaffold(
      appBar: const AISNavBar(),
      body: cart.items.isEmpty ? const _EmptyCart() : _CartContent(cart: cart),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: AISColors.textLight),
          const SizedBox(height: 16),
          const Text('ตะกร้าของคุณยังว่างอยู่',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AISColors.textDark)),
          const SizedBox(height: 8),
          const Text('เลือกแพ็กเกจที่ต้องการเพื่อเพิ่มลงในตะกร้า',
              style: TextStyle(color: AISColors.textMedium)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/packages'),
            icon: const Icon(Icons.explore),
            label: const Text('เลือกแพ็กเกจ'),
          ),
        ],
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final CartProvider cart;
  const _CartContent({required this.cart});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 16,
          vertical: 24,
        ),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _ItemsList(cart: cart)),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _OrderSummary(cart: cart)),
                ],
              )
            : Column(
                children: [
                  _ItemsList(cart: cart),
                  const SizedBox(height: 24),
                  _OrderSummary(cart: cart),
                ],
              ),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final CartProvider cart;
  const _ItemsList({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('ตะกร้าสินค้า',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AISColors.textDark)),
                const Spacer(),
                Text('${cart.itemCount} รายการ',
                    style: const TextStyle(
                        color: AISColors.textMedium, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            ...cart.items.map((item) => _CartItemRow(
                  item: item,
                  onRemove: () =>
                      context.read<CartProvider>().removeItem(item.package.id),
                  onDecrement: () =>
                      context.read<CartProvider>().decrementItem(item.package.id),
                  onIncrement: () =>
                      context.read<CartProvider>().addItem(item.package),
                )),
          ],
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartItemRow({
    required this.item,
    required this.onRemove,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = item.package;
    final headerColor = pkg.colorHex != null
        ? Color(int.parse(pkg.colorHex!.replaceFirst('#', '0xFF')))
        : AISColors.primaryGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AISColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AISColors.divider),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(pkg.category.icon,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(pkg.priceUnit,
                    style: const TextStyle(
                        color: AISColors.textMedium, fontSize: 12)),
              ],
            ),
          ),

          // Quantity
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: onDecrement,
                color: AISColors.primaryGreen,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AISColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.quantity.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: onIncrement,
                color: AISColors.primaryGreen,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_fmt.format(item.totalPrice)} บาท',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AISColors.primaryGreen),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Text(
                  'ลบ',
                  style: TextStyle(
                      color: AISColors.errorRed,
                      fontSize: 12,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final discountPct = ldService.getNumber(FlagKeys.discountPercentage);
    final freeData = ldService.getNumber(FlagKeys.freeDataGb);
    final paymentConfig = ldService.getJson(FlagKeys.paymentMethodsConfig);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('สรุปคำสั่งซื้อ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AISColors.textDark)),
            const SizedBox(height: 16),
            _SummaryRow('ราคารวม', '${_fmt.format(cart.subtotal)} บาท'),
            if (discountPct > 0)
              _SummaryRow(
                  'ส่วนลด ${discountPct.toInt()}%',
                  '-${_fmt.format(cart.discount)} บาท',
                  valueColor: Colors.red),
            if (freeData > 0)
              _SummaryRow('โบนัสเน็ต', '+${freeData.toInt()} GB',
                  valueColor: AISColors.successGreen),
            const Divider(height: 24),
            _SummaryRow(
              'รวมทั้งสิ้น',
              '${_fmt.format(cart.total)} บาท',
              bold: true,
              fontSize: 18,
            ),
            const SizedBox(height: 8),
            Text(
              '${cart.items.length} แพ็กเกจ / เดือน',
              style:
                  const TextStyle(color: AISColors.textMedium, fontSize: 12),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 20),

            // Payment methods
            const Text('ช่องทางชำระเงิน',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AISColors.textMedium)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (paymentConfig['creditCard'] == true)
                  _PayChip('💳 บัตรเครดิต'),
                if (paymentConfig['promptpay'] == true)
                  _PayChip('📱 PromptPay'),
                if (paymentConfig['truemoney'] == true)
                  _PayChip('💚 TrueMoney'),
                if (paymentConfig['linepay'] == true)
                  _PayChip('🟢 LINE Pay'),
                if (paymentConfig['installment'] == true)
                  _PayChip('📅 ผ่อน 0%'),
                if (paymentConfig['crypto'] == true)
                  _PayChip('₿ Crypto'),
              ],
            ),
            const SizedBox(height: 8),
            if (paymentConfig.values.any((v) => v != true))
              Row(
                children: [
                  const Icon(Icons.toggle_on,
                      size: 12, color: AISColors.ldBlue),
                  const SizedBox(width: 4),
                  Text(
                    'ช่องทางชำระเงินจาก JSON Flag',
                    style:
                        const TextStyle(fontSize: 10, color: AISColors.ldBlue),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.go('/checkout'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('ดำเนินการชำระเงิน',
                  style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.go('/packages'),
              child: const Text('เลือกแพ็กเกจเพิ่มเติม'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  final double fontSize;
  const _SummaryRow(this.label, this.value,
      {this.bold = false, this.valueColor, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  color: bold ? AISColors.textDark : AISColors.textMedium,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? AISColors.textDark)),
        ],
      ),
    );
  }
}

class _PayChip extends StatelessWidget {
  final String label;
  const _PayChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AISColors.lightGreen,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AISColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: AISColors.primaryGreen)),
    );
  }
}
