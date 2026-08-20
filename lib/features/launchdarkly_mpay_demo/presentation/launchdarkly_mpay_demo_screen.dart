import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/ais_theme.dart';
import '../../../widgets/ais_navbar.dart';
import '../domain/mpay_flow.dart';
import '../models/mpay_demo_context.dart';
import '../services/mpay_demo_controller.dart';

class LaunchDarklyMpayDemoScreen extends StatelessWidget {
  const LaunchDarklyMpayDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MpayDemoController(context.read()),
      child: const _MpayDemoView(),
    );
  }
}

class _MpayDemoView extends StatelessWidget {
  const _MpayDemoView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MpayDemoController>();
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: const AISNavBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 32 : 12,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _MpayHeader(),
                const SizedBox(height: 20),
                _ContextSelector(controller: controller),
                const SizedBox(height: 16),
                _FlagSummary(controller: controller),
                if (controller.emergencyFallbackActive) ...[
                  const SizedBox(height: 12),
                  const _EmergencyFallbackBanner(),
                ],
                const SizedBox(height: 16),
                _PaymentFlowCard(
                  key: ValueKey(
                      '${controller.paymentFlowV2}-${controller.apiV2}-${controller.connectorV2}'),
                  controller: controller,
                ),
                const SizedBox(height: 16),
                _FailureControl(controller: controller),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MpayHeader extends StatelessWidget {
  const _MpayHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AISColors.navGreen, Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        children: [
          const SizedBox(
            width: 620,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LaunchDarkly mPAY Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'See how LaunchDarkly rolls out a new API and Backend Connector independently. Simulate a Connector V2 failure, then turn off both flags to fall back to V1.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AISColors.ldBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                Text('PAYMENT',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('V1  <->  V2',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextSelector extends StatelessWidget {
  final MpayDemoController controller;

  const _ContextSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final selected = controller.selected;
    return _SectionCard(
      title: 'Demo User',
      icon: Icons.people_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<MpayDemoContext>(
            initialValue: selected,
            decoration: const InputDecoration(
              labelText: 'Select a synthetic identity',
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: MpayDemoContext.demoUsers
                .map((demoUser) => DropdownMenuItem(
                      value: demoUser,
                      child: Text('${demoUser.name}  (${demoUser.key})'),
                    ))
                .toList(),
            onChanged: controller.isSelecting
                ? null
                : (value) {
                    if (value != null) controller.selectContext(value);
                  },
          ),
          if (controller.isSelecting) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _FlagSummary extends StatelessWidget {
  final MpayDemoController controller;

  const _FlagSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    final apiV2 = controller.apiV2;
    final connectorV2 = controller.connectorV2;
    final paymentFlowV2 = controller.paymentFlowV2;
    final valueColor = controller.v2Ready
        ? AISColors.ldBlue
        : paymentFlowV2 || apiV2 || connectorV2
            ? AISColors.warningOrange
            : AISColors.successGreen;
    return _SectionCard(
      title: 'Backend integration',
      icon: Icons.toggle_on_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Payment flow flag: payment-flow-v2',
                  value: paymentFlowV2 ? 'Payment V2' : 'Payment V1',
                  color: valueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'API flag: mpay-api-v2',
                  value: apiV2 ? 'API V2' : 'API V1',
                  color: valueColor,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Connector flag: mpay-connector-v2',
                  value: connectorV2 ? 'Connector V2' : 'Connector V1',
                  color: valueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                controller.sdkAvailable ? Icons.cloud_done : Icons.cloud_off,
                size: 17,
                color: controller.sdkAvailable
                    ? AISColors.successGreen
                    : AISColors.warningOrange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  controller.sdkAvailable
                      ? controller.v2Ready
                          ? 'V2 ready: Payment Flow, API and Connector flags are all ON.'
                          : !paymentFlowV2 && (apiV2 || connectorV2)
                              ? 'Payment Flow V1 is active; V2 API and Connector are not used.'
                              : paymentFlowV2 && (!apiV2 || !connectorV2)
                                  ? 'Enable all three V2 flags to activate the new integration.'
                                  : 'V1 active: all V2 flags are OFF.'
                      : 'LaunchDarkly unavailable${controller.evaluationError ? ' or evaluation failed' : ''}; Fallback: API V1 + Connector V1',
                  style: TextStyle(
                    color: controller.sdkAvailable
                        ? AISColors.successGreen
                        : AISColors.warningOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentFlowCard extends StatefulWidget {
  final MpayDemoController controller;

  const _PaymentFlowCard({super.key, required this.controller});

  @override
  State<_PaymentFlowCard> createState() => _PaymentFlowCardState();
}

enum _PaymentStep { details, confirm, processing, success, failure }

class _PaymentFlowCardState extends State<_PaymentFlowCard> {
  _PaymentStep _step = _PaymentStep.details;

  @override
  void didUpdateWidget(covariant _PaymentFlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.connectorVersion !=
        widget.controller.connectorVersion) {
      setState(() => _step = _PaymentStep.details);
    }
  }

  void _advance() {
    setState(() {
      if (_step == _PaymentStep.details) {
        _step = _PaymentStep.confirm;
      } else if (_step == _PaymentStep.confirm) {
        _step = _PaymentStep.processing;
      } else if (_step == _PaymentStep.processing) {
        if (widget.controller.v2Ready && widget.controller.simulateV2Failure) {
          widget.controller.recordV2PaymentFailure();
          _step = _PaymentStep.failure;
        } else {
          _step = _PaymentStep.success;
        }
      }
    });
  }

  void _reset() {
    setState(() => _step = _PaymentStep.details);
  }

  @override
  Widget build(BuildContext context) {
    final isV2 = widget.controller.v2Ready;
    const title = 'Payment processing';
    final subtitle =
        'API ${mpayVersionLabel(widget.controller.apiVersion)} / Connector ${mpayVersionLabel(widget.controller.connectorVersion)}';
    final steps = ['Details', 'Confirm', 'Processing', 'Success'];
    final activeIndex = _step == _PaymentStep.failure
        ? 2
        : _PaymentStep.values.indexOf(_step).clamp(0, 3);

    return _SectionCard(
      title: title,
      icon: isV2 ? Icons.auto_awesome : Icons.shield_outlined,
      trailing: _FlowBadge(
          label: subtitle,
          color: isV2 ? AISColors.ldBlue : AISColors.successGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(steps: steps, activeIndex: activeIndex),
          const SizedBox(height: 18),
          if (isV2) const _V2PaymentSummary() else const _V1PaymentSummary(),
          const SizedBox(height: 16),
          if (_step == _PaymentStep.failure)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PaymentFailure(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Start over'),
                  ),
                ),
              ],
            )
          else if (_step == _PaymentStep.success)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PaymentSuccess(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Start over'),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _advance,
                icon: Icon(_step == _PaymentStep.processing
                    ? Icons.lock_outline
                    : Icons.arrow_forward),
                label: Text(_step == _PaymentStep.details
                    ? 'Pay ฿1,250'
                    : _step == _PaymentStep.confirm
                        ? 'Confirm payment'
                        : 'Complete payment'),
              ),
            ),
        ],
      ),
    );
  }
}

class _V1PaymentSummary extends StatelessWidget {
  const _V1PaymentSummary();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        SizedBox(height: 12),
        _SimplePaymentLine(label: 'mPAY wallet', value: '•••• 0125'),
        _SimplePaymentLine(label: 'Amount', value: '฿1,250.00'),
      ],
    );
  }
}

class _V2PaymentSummary extends StatelessWidget {
  const _V2PaymentSummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New payment experience',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _DemoPaymentCard()),
            const SizedBox(width: 16),
            const _DemoQrCode(),
          ],
        ),
      ],
    );
  }
}

class _SimplePaymentLine extends StatelessWidget {
  final String label;
  final String value;

  const _SimplePaymentLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: AISColors.textMedium))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DemoPaymentCard extends StatelessWidget {
  const _DemoPaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AISColors.navGreen, AISColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AISColors.primaryGreen.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('mPAY wallet',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),
          Text('•••• 0125',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount', style: TextStyle(color: Colors.white70)),
              Text('฿1,250.00',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoQrCode extends StatelessWidget {
  const _DemoQrCode();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: const CustomPaint(painter: _DemoQrPainter()),
        ),
        const SizedBox(height: 6),
        const Text('PromptPay QR',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const Text('Demo only',
            style: TextStyle(fontSize: 10, color: AISColors.textLight)),
      ],
    );
  }
}

class _DemoQrPainter extends CustomPainter {
  const _DemoQrPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const count = 21;
    final cell = size.width / count;
    final paint = Paint()..color = Colors.black;

    bool inFinder(int x, int y, int left, int top) =>
        x >= left && x < left + 7 && y >= top && y < top + 7;

    bool finderModule(int x, int y, int left, int top) {
      final dx = x - left;
      final dy = y - top;
      return dx == 0 ||
          dx == 6 ||
          dy == 0 ||
          dy == 6 ||
          (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4);
    }

    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        var filled = false;
        for (final finder in const [(0, 0), (14, 0), (0, 14)]) {
          if (inFinder(x, y, finder.$1, finder.$2)) {
            filled = finderModule(x, y, finder.$1, finder.$2);
          }
        }
        if (!inFinder(x, y, 0, 0) &&
            !inFinder(x, y, 14, 0) &&
            !inFinder(x, y, 0, 14)) {
          filled = ((x * 17 + y * 31 + x * y) % 7) < 3;
        }
        if (filled) {
          canvas.drawRect(
              Rect.fromLTWH(x * cell, y * cell, cell + 0.3, cell + 0.3), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DemoQrPainter oldDelegate) => false;
}

class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int activeIndex;

  const _StepIndicator({required this.steps, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((entry) {
        final isActive = entry.key <= activeIndex;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor:
                    isActive ? AISColors.limeGreen : AISColors.divider,
                child: Text('${entry.key + 1}',
                    style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? AISColors.primaryGreen
                            : AISColors.textMedium,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(entry.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? AISColors.primaryGreen
                            : AISColors.textLight,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal)),
              ),
              if (entry.key < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: entry.key < activeIndex
                        ? AISColors.limeGreen
                        : AISColors.divider,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AISColors.successGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AISColors.successGreen),
            SizedBox(width: 8),
            Text('Payment successful',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

class _PaymentFailure extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AISColors.errorRed.withValues(alpha: 0.08),
          border: Border.all(color: AISColors.errorRed.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: AISColors.errorRed),
            SizedBox(width: 8),
            Expanded(
                child: Text(
                    'Simulated Backend Connector V2 failure. Turn off all three V2 flags in LaunchDarkly to fall back immediately.')),
          ],
        ),
      );
}

class _FailureControl extends StatelessWidget {
  final MpayDemoController controller;

  const _FailureControl({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Simulate Connector API V2 failure',
      icon: Icons.warning_amber_outlined,
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: controller.simulateV2Failure,
            onChanged:
                controller.v2Ready ? controller.setSimulateV2Failure : null,
            title: const Text('Simulate Connector API V2 failure',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text(
                'After failure, turn off all three V2 flags in LaunchDarkly to activate Payment V1 + API V1 + Connector V1.'),
            secondary: const Icon(Icons.warning_amber_outlined,
                color: AISColors.warningOrange),
          ),
        ],
      ),
    );
  }
}

class _EmergencyFallbackBanner extends StatelessWidget {
  const _EmergencyFallbackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AISColors.successGreen.withValues(alpha: 0.1),
        border:
            Border.all(color: AISColors.successGreen.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.emergency, color: AISColors.successGreen),
          SizedBox(width: 8),
          Expanded(
            child: Text(
                'Emergency fallback: all V2 flags are OFF. Payment V1 + API V1 + Connector V1 active — no rebuild required.',
                style: TextStyle(
                    color: AISColors.successGreen,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.child,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AISColors.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AISColors.textMedium, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _FlowBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _FlowBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
