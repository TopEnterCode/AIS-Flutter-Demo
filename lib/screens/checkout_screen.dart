import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';

final _fmt = NumberFormat('#,##0', 'th_TH');

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0;
  String _paymentMethod = 'creditCard';
  bool _processing = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameController.text = user.name;
    _emailController.text = user.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final useNewFlow = ldService.getBool(FlagKeys.newCheckoutFlow);
    final buttonColor = ldService.getString(FlagKeys.checkoutButtonColor, defaultValue: 'green');
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: const AISNavBar(),
      body: useNewFlow
          ? _NewCheckoutFlow(
              step: _step,
              onStepChanged: (s) => setState(() => _step = s),
              paymentMethod: _paymentMethod,
              onPaymentChanged: (p) => setState(() => _paymentMethod = p),
              cart: cart,
              buttonColor: buttonColor,
              processing: _processing,
              onConfirm: _confirmOrder,
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
            )
          : _ClassicCheckout(
              cart: cart,
              paymentMethod: _paymentMethod,
              onPaymentChanged: (p) => setState(() => _paymentMethod = p),
              buttonColor: buttonColor,
              processing: _processing,
              onConfirm: _confirmOrder,
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
            ),
    );
  }

  Future<void> _confirmOrder() async {
    setState(() => _processing = true);
    final ldService = context.read<LDService>();
    final cart = context.read<CartProvider>();

    ldService.track('checkout-completed',
        metricValue: cart.total,
        data: {'paymentMethod': _paymentMethod, 'items': cart.itemCount});

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    cart.clear();
    context.go('/success');
  }
}

// === NEW CHECKOUT FLOW (Percentage Rollout) ===
class _NewCheckoutFlow extends StatelessWidget {
  final int step;
  final Function(int) onStepChanged;
  final String paymentMethod;
  final Function(String) onPaymentChanged;
  final CartProvider cart;
  final String buttonColor;
  final bool processing;
  final VoidCallback onConfirm;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const _NewCheckoutFlow({
    required this.step,
    required this.onStepChanged,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.cart,
    required this.buttonColor,
    required this.processing,
    required this.onConfirm,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar (New flow)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AISColors.ldBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.new_releases,
                            size: 12, color: AISColors.ldBlue),
                        const SizedBox(width: 4),
                        const Text('NEW Checkout Flow (Percentage Rollout)',
                            style: TextStyle(
                                fontSize: 11,
                                color: AISColors.ldBlue,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StepDot(0, step, 'ข้อมูล'),
                  Expanded(child: _StepLine(step > 0)),
                  _StepDot(1, step, 'ชำระเงิน'),
                  Expanded(child: _StepLine(step > 1)),
                  _StepDot(2, step, 'ยืนยัน'),
                ],
              ),
            ],
          ),
        ),

        // Step content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (step == 0)
                  _ContactForm(
                    nameController: nameController,
                    phoneController: phoneController,
                    emailController: emailController,
                    onNext: () => onStepChanged(1),
                    isNew: true,
                  ),
                if (step == 1)
                  _PaymentStep(
                    cart: cart,
                    paymentMethod: paymentMethod,
                    onPaymentChanged: onPaymentChanged,
                    onNext: () => onStepChanged(2),
                    onBack: () => onStepChanged(0),
                    isNew: true,
                  ),
                if (step == 2)
                  _ConfirmStep(
                    cart: cart,
                    name: nameController.text,
                    email: emailController.text,
                    paymentMethod: paymentMethod,
                    buttonColor: buttonColor,
                    processing: processing,
                    onBack: () => onStepChanged(1),
                    onConfirm: onConfirm,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int currentStep;
  final String label;
  const _StepDot(this.index, this.currentStep, this.label);

  @override
  Widget build(BuildContext context) {
    final done = currentStep > index;
    final active = currentStep == index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: done
                ? AISColors.successGreen
                : active
                    ? AISColors.primaryGreen
                    : AISColors.divider,
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check : Icons.circle,
            color: done || active ? Colors.white : Colors.white70,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: active
                    ? AISColors.primaryGreen
                    : AISColors.textMedium,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool filled;
  const _StepLine(this.filled);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: filled ? AISColors.successGreen : AISColors.divider,
    );
  }
}

// === CLASSIC CHECKOUT FLOW ===
class _ClassicCheckout extends StatelessWidget {
  final CartProvider cart;
  final String paymentMethod;
  final Function(String) onPaymentChanged;
  final String buttonColor;
  final bool processing;
  final VoidCallback onConfirm;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const _ClassicCheckout({
    required this.cart,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.buttonColor,
    required this.processing,
    required this.onConfirm,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 16, vertical: 24),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _ContactForm(
                        nameController: nameController,
                        phoneController: phoneController,
                        emailController: emailController,
                        isNew: false,
                      ),
                      const SizedBox(height: 16),
                      _PaymentOptions(
                        paymentMethod: paymentMethod,
                        onChanged: onPaymentChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _ClassicSummary(
                    cart: cart,
                    buttonColor: buttonColor,
                    processing: processing,
                    onConfirm: onConfirm,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _ContactForm(
                  nameController: nameController,
                  phoneController: phoneController,
                  emailController: emailController,
                  isNew: false,
                ),
                const SizedBox(height: 16),
                _PaymentOptions(
                    paymentMethod: paymentMethod, onChanged: onPaymentChanged),
                const SizedBox(height: 16),
                _ClassicSummary(
                  cart: cart,
                  buttonColor: buttonColor,
                  processing: processing,
                  onConfirm: onConfirm,
                ),
              ],
            ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final VoidCallback? onNext;
  final bool isNew;

  const _ContactForm({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    this.onNext,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ข้อมูลผู้สมัคร',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AISColors.textDark)),
            const SizedBox(height: 16),
            _Field('ชื่อ-นามสกุล', nameController, Icons.person),
            const SizedBox(height: 12),
            _Field('เบอร์มือถือ', phoneController, Icons.phone,
                hint: '0xx-xxx-xxxx'),
            const SizedBox(height: 12),
            _Field('อีเมล', emailController, Icons.email,
                hint: 'email@example.com'),
            if (isNew && onNext != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text('ถัดไป: เลือกช่องทางชำระเงิน'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  const _Field(this.label, this.controller, this.icon, {this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class _PaymentOptions extends StatelessWidget {
  final String paymentMethod;
  final Function(String) onChanged;
  const _PaymentOptions(
      {required this.paymentMethod, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('creditCard', '💳', 'บัตรเครดิต/เดบิต'),
      ('promptpay', '📱', 'PromptPay'),
      ('truemoney', '💚', 'TrueMoney Wallet'),
    ];

    final ldService = context.watch<LDService>();
    final config = ldService.getJson(FlagKeys.paymentMethodsConfig);

    final available = options
        .where((o) => config[o.$1] == true)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ช่องทางชำระเงิน',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AISColors.textDark)),
            const SizedBox(height: 12),
            ...available.map((opt) => RadioListTile<String>(
                  value: opt.$1,
                  groupValue: paymentMethod,
                  onChanged: (v) => onChanged(v!),
                  title: Text('${opt.$2}  ${opt.$3}'),
                  activeColor: AISColors.primaryGreen,
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  final CartProvider cart;
  final String paymentMethod;
  final Function(String) onPaymentChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isNew;

  const _PaymentStep({
    required this.cart,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.onNext,
    required this.onBack,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentOptions(
            paymentMethod: paymentMethod, onChanged: onPaymentChanged),
        const SizedBox(height: 16),
        Row(
          children: [
            OutlinedButton(onPressed: onBack, child: const Text('← ย้อนกลับ')),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text('ถัดไป: ยืนยันคำสั่งซื้อ'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  final CartProvider cart;
  final String name;
  final String email;
  final String paymentMethod;
  final String buttonColor;
  final bool processing;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const _ConfirmStep({
    required this.cart,
    required this.name,
    required this.email,
    required this.paymentMethod,
    required this.buttonColor,
    required this.processing,
    required this.onBack,
    required this.onConfirm,
  });

  Color get _btnColor {
    switch (buttonColor) {
      case 'orange': return const Color(0xFFFF7628);
      case 'blue': return const Color(0xFF2196F3);
      case 'red': return const Color(0xFFE53935);
      default: return AISColors.limeGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ยืนยันคำสั่งซื้อ',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            _InfoRow('ชื่อ', name),
            _InfoRow('อีเมล', email),
            _InfoRow('ช่องทางชำระ', paymentMethod),
            _InfoRow('จำนวนแพ็กเกจ', '${cart.itemCount} รายการ'),
            _InfoRow('ยอดรวม', '${_fmt.format(cart.total)} บาท/เดือน'),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton(
                    onPressed: onBack, child: const Text('← ย้อนกลับ')),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: processing ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _btnColor,
                      foregroundColor: buttonColor == 'green'
                          ? AISColors.primaryGreen
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: processing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('ยืนยันสมัคร',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassicSummary extends StatelessWidget {
  final CartProvider cart;
  final String buttonColor;
  final bool processing;
  final VoidCallback onConfirm;

  const _ClassicSummary({
    required this.cart,
    required this.buttonColor,
    required this.processing,
    required this.onConfirm,
  });

  Color get _btnColor {
    switch (buttonColor) {
      case 'orange': return const Color(0xFFFF7628);
      case 'blue': return const Color(0xFF2196F3);
      case 'red': return const Color(0xFFE53935);
      default: return AISColors.limeGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('สรุปคำสั่งซื้อ',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(item.package.name,
                              style: const TextStyle(fontSize: 13))),
                      Text('${_fmt.format(item.totalPrice)} บาท',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('รวมทั้งสิ้น',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_fmt.format(cart.total)} บาท',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AISColors.primaryGreen)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: processing ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _btnColor,
                foregroundColor: buttonColor == 'green'
                    ? AISColors.primaryGreen
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: processing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('ยืนยันสมัคร', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.toggle_on, size: 12, color: AISColors.ldBlue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Button color: $buttonColor (Experiment flag)',
                    style: const TextStyle(
                        fontSize: 10, color: AISColors.ldBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AISColors.textMedium, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
