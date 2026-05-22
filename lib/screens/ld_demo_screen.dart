import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';

class LDDemoScreen extends StatelessWidget {
  const LDDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: const AISNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _LDHeader(),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 12, vertical: 24),
              child: Column(
                children: [
                  // Section 1: Boolean Flags
                  _SectionHeader(
                    number: '01',
                    title: 'Boolean Flags',
                    subtitle: 'เปิด/ปิดฟีเจอร์แบบ True/False',
                    color: AISColors.ldBlue,
                    icon: Icons.toggle_on,
                  ),
                  _BooleanFlagsSection(),
                  const SizedBox(height: 32),

                  // Section 2: Multivariate String
                  _SectionHeader(
                    number: '02',
                    title: 'Multivariate String',
                    subtitle: 'ส่งค่า String เพื่อเปลี่ยนดีไซน์',
                    color: AISColors.ldPurple,
                    icon: Icons.text_fields,
                  ),
                  _StringFlagsSection(),
                  const SizedBox(height: 32),

                  // Section 3: Multivariate Number
                  _SectionHeader(
                    number: '03',
                    title: 'Multivariate Number',
                    subtitle: 'ส่งค่าตัวเลขเพื่อปรับ Configuration',
                    color: AISColors.ldOrange,
                    icon: Icons.tag,
                  ),
                  _NumberFlagsSection(),
                  const SizedBox(height: 32),

                  // Section 4: Multivariate JSON
                  _SectionHeader(
                    number: '04',
                    title: 'Multivariate JSON',
                    subtitle: 'ส่ง JSON Object เพื่อปรับ Config ซับซ้อน',
                    color: AISColors.ldTeal,
                    icon: Icons.data_object,
                  ),
                  _JsonFlagsSection(),
                  const SizedBox(height: 32),

                  // Section 5: User Targeting
                  _SectionHeader(
                    number: '05',
                    title: 'User Targeting',
                    subtitle: 'เปิดฟีเจอร์เฉพาะผู้ใช้บางกลุ่ม',
                    color: AISColors.limeGreen,
                    icon: Icons.person_pin,
                  ),
                  _UserTargetingSection(),
                  const SizedBox(height: 32),

                  // Section 6: Percentage Rollout
                  _SectionHeader(
                    number: '06',
                    title: 'Percentage Rollout',
                    subtitle: 'ทยอยปล่อยฟีเจอร์เป็นเปอร์เซ็นต์',
                    color: AISColors.ldPink,
                    icon: Icons.bar_chart,
                  ),
                  _RolloutSection(),
                  const SizedBox(height: 32),

                  // Section 7: Kill Switch
                  _SectionHeader(
                    number: '07',
                    title: 'Kill Switch',
                    subtitle: 'ปิดฉุกเฉินทันทีภายใน 200ms',
                    color: Colors.red,
                    icon: Icons.emergency,
                  ),
                  _KillSwitchSection(),
                  const SizedBox(height: 32),

                  // Section 8: Scheduled Changes
                  _SectionHeader(
                    number: '08',
                    title: 'Scheduled Changes',
                    subtitle: 'ตั้งเวลาเปิด/ปิดฟีเจอร์อัตโนมัติ',
                    color: AISColors.ldYellow,
                    icon: Icons.schedule,
                  ),
                  _ScheduledSection(),
                  const SizedBox(height: 32),

                  // Section 9: Experimentation
                  _SectionHeader(
                    number: '09',
                    title: 'Experimentation (A/B Test)',
                    subtitle: 'วัดผลว่า Variant ไหนให้ Conversion ดีกว่า',
                    color: AISColors.primaryGreen,
                    icon: Icons.science,
                  ),
                  _ExperimentSection(),
                  const SizedBox(height: 32),

                  // Section 10: AI Config
                  _SectionHeader(
                    number: '10',
                    title: 'AI Config Flags',
                    subtitle: 'ปรับ AI Model / Prompt แบบ Real-time',
                    color: const Color(0xFF7C4DFF),
                    icon: Icons.smart_toy,
                  ),
                  _AIConfigSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LDHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), AISColors.navGreen],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AISColors.ldBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.toggle_on, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Text(
                'LaunchDarkly',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AISColors.ldBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('DEMO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Feature Flag Management — ทดสอบ Feature Flags ทุกประเภทแบบ Real-time',
            style: TextStyle(color: Colors.white70, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'ทุกการเปลี่ยนแปลงจะสะท้อนในแอปทันที < 200ms',
            style: TextStyle(color: AISColors.limeGreen, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _TypeChip('Boolean', AISColors.ldBlue),
              _TypeChip('String', AISColors.ldPurple),
              _TypeChip('Number', AISColors.ldOrange),
              _TypeChip('JSON', AISColors.ldTeal),
              _TypeChip('User Targeting', AISColors.limeGreen),
              _TypeChip('% Rollout', AISColors.ldPink),
              _TypeChip('Kill Switch', Colors.red),
              _TypeChip('Scheduled', AISColors.ldYellow),
              _TypeChip('A/B Test', AISColors.primaryGreen),
              _TypeChip('AI Config', const Color(0xFF7C4DFF)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AISColors.textMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== BOOLEAN FLAGS =====================
class _BooleanFlagsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final flags = [
      FlagKeys.showPromoBanner,
      FlagKeys.enableAiAssistant,
      FlagKeys.showNewNavbar,
    ];
    final isWide = MediaQuery.of(context).size.width > 700;
    return GridView.count(
      crossAxisCount: isWide ? 3 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 1.5 : 2.5,
      children: flags.map((key) {
        final flag = ldService.getFlag(key)!;
        final val = flag.value as bool;
        return _BoolFlagCard(
          flag: flag,
          value: val,
          onToggle: (v) => ldService.setMockFlag(key, v),
          color: AISColors.ldBlue,
        );
      }).toList(),
    );
  }
}

class _BoolFlagCard extends StatelessWidget {
  final LDFlagInfo flag;
  final bool value;
  final Function(bool) onToggle;
  final Color color;

  const _BoolFlagCard({
    required this.flag,
    required this.value,
    required this.onToggle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FlagKey(flag.key),
                      const SizedBox(height: 2),
                      Text(flag.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onToggle,
                  activeColor: color,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(flag.description,
                style: const TextStyle(
                    color: AISColors.textMedium, fontSize: 11)),
            const Spacer(),
            _StatusPill(value ? 'TRUE ✓' : 'FALSE ✗',
                value ? AISColors.successGreen : AISColors.textLight),
            const SizedBox(height: 4),
            Text(flag.demoHint,
                style: const TextStyle(
                    color: AISColors.ldBlue,
                    fontSize: 10,
                    fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ===================== STRING FLAGS =====================
class _StringFlagsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isWide = MediaQuery.of(context).size.width > 700;
    final flags = [FlagKeys.heroBannerVariant, FlagKeys.ctaButtonText];
    return GridView.count(
      crossAxisCount: isWide ? 2 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 1.4 : 2.0,
      children: flags.map((key) {
        final flag = ldService.getFlag(key)!;
        return _StringFlagCard(
          flag: flag,
          color: AISColors.ldPurple,
          onSelect: (v) => ldService.setMockFlag(key, v),
        );
      }).toList(),
    );
  }
}

class _StringFlagCard extends StatelessWidget {
  final LDFlagInfo flag;
  final Color color;
  final Function(String) onSelect;

  const _StringFlagCard({
    required this.flag,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlagKey(flag.key),
            const SizedBox(height: 2),
            Text(flag.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(flag.description,
                style: const TextStyle(
                    color: AISColors.textMedium, fontSize: 11)),
            const Spacer(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: flag.possibleValues.map<Widget>((v) {
                final selected = flag.value == v;
                return GestureDetector(
                  onTap: () => onSelect(v as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected
                          ? color
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color:
                              selected ? color : color.withOpacity(0.3)),
                    ),
                    child: Text(
                      v.toString(),
                      style: TextStyle(
                          color:
                              selected ? Colors.white : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            Text(flag.demoHint,
                style: const TextStyle(
                    color: AISColors.ldPurple,
                    fontSize: 10,
                    fontStyle: FontStyle.italic),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

// ===================== NUMBER FLAGS =====================
class _NumberFlagsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isWide = MediaQuery.of(context).size.width > 700;
    final flags = [FlagKeys.discountPercentage, FlagKeys.freeDataGb];
    return GridView.count(
      crossAxisCount: isWide ? 2 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 1.3 : 2.0,
      children: flags.map((key) {
        final flag = ldService.getFlag(key)!;
        return _NumberFlagCard(
          flag: flag,
          onSelect: (v) => ldService.setMockFlag(key, v),
        );
      }).toList(),
    );
  }
}

class _NumberFlagCard extends StatelessWidget {
  final LDFlagInfo flag;
  final Function(double) onSelect;
  const _NumberFlagCard({required this.flag, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final currentVal = (flag.value as num).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlagKey(flag.key),
            const SizedBox(height: 2),
            Text(flag.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(flag.description,
                style: const TextStyle(
                    color: AISColors.textMedium, fontSize: 11)),
            const Spacer(),
            Center(
              child: Text(
                currentVal.toInt().toString(),
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AISColors.ldOrange),
              ),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: flag.possibleValues.map<Widget>((v) {
                final val = (v as num).toDouble();
                final selected = currentVal == val;
                return GestureDetector(
                  onTap: () => onSelect(val),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AISColors.ldOrange
                          : AISColors.ldOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: selected
                              ? AISColors.ldOrange
                              : AISColors.ldOrange.withOpacity(0.3)),
                    ),
                    child: Text('${val.toInt()}',
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AISColors.ldOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            Text(flag.demoHint,
                style: const TextStyle(
                    color: AISColors.ldOrange,
                    fontSize: 10,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

// ===================== JSON FLAGS =====================
class _JsonFlagsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isWide = MediaQuery.of(context).size.width > 700;
    final flags = [FlagKeys.featuredPackagesConfig, FlagKeys.paymentMethodsConfig];
    return GridView.count(
      crossAxisCount: isWide ? 2 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 1.0 : 1.5,
      children: flags.map((key) {
        final flag = ldService.getFlag(key)!;
        return _JsonFlagCard(
          flag: flag,
          onSelect: flag.possibleValues.isNotEmpty
              ? (v) => ldService.setMockFlag(key, v)
              : null,
        );
      }).toList(),
    );
  }
}

class _JsonFlagCard extends StatelessWidget {
  final LDFlagInfo flag;
  final Function(Map<String, dynamic>)? onSelect;
  const _JsonFlagCard({required this.flag, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(flag.value);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlagKey(flag.key),
            const SizedBox(height: 2),
            Text(flag.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(flag.description,
                style: const TextStyle(
                    color: AISColors.textMedium, fontSize: 11)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                jsonStr,
                style: const TextStyle(
                    color: AISColors.ldTeal,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.4),
              ),
            ),
            if (onSelect != null && flag.possibleValues.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('เลือก Preset:',
                  style: TextStyle(fontSize: 11, color: AISColors.textMedium)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: flag.possibleValues.asMap().entries.map<Widget>((e) {
                  final v = e.value as Map<String, dynamic>;
                  final isSelected = const DeepCollectionEquality()
                      .equals(flag.value, v);
                  return GestureDetector(
                    onTap: () => onSelect!(v),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AISColors.ldTeal
                            : AISColors.ldTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: isSelected
                                ? AISColors.ldTeal
                                : AISColors.ldTeal.withOpacity(0.3)),
                      ),
                      child: Text('Preset ${e.key + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : AISColors.ldTeal)),
                    ),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            Text(flag.demoHint,
                style: const TextStyle(
                    color: AISColors.ldTeal,
                    fontSize: 10,
                    fontStyle: FontStyle.italic),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

// ===================== USER TARGETING =====================
class _UserTargetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final userCtx = ldService.userContext;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AISColors.limeGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AISColors.limeGreen.withOpacity(0.4)),
                  ),
                  child: const Text('User Targeting Rules',
                      style: TextStyle(
                          color: AISColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _TargetRule(
                  condition: 'email ends with @ais.th',
                  result: 'show-vip-benefits = TRUE\nshow-corporate-packages = TRUE',
                  icon: '👑',
                  active: userCtx.email?.endsWith('@ais.th') ?? false,
                ),
                _TargetRule(
                  condition: 'role = "corporate" OR "enterprise"',
                  result: 'show-corporate-packages = TRUE',
                  icon: '🏢',
                  active: userCtx.role == 'corporate' || userCtx.role == 'enterprise',
                ),
                _TargetRule(
                  condition: 'role = "vip" OR email contains "vip"',
                  result: 'show-vip-benefits = TRUE',
                  icon: '⭐',
                  active: (userCtx.role == 'vip' || (userCtx.email?.contains('vip') ?? false)),
                ),
                _TargetRule(
                  condition: 'All other users (default)',
                  result: 'ได้รับ flags ค่า default',
                  icon: '👤',
                  active: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AISColors.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AISColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current User Context:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AISColors.primaryGreen)),
                  const SizedBox(height: 6),
                  Text(
                    'key: "${userCtx.key}"\nemail: "${userCtx.email ?? 'none'}"\nrole: "${userCtx.role ?? 'user'}"',
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AISColors.primaryGreen,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('เปลี่ยน user ได้ที่:',
                    style: TextStyle(fontSize: 12, color: AISColors.textMedium)),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => context.go('/profile'),
                  icon: const Icon(Icons.person, size: 14),
                  label: const Text('Profile / User Targeting',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetRule extends StatelessWidget {
  final String condition;
  final String result;
  final String icon;
  final bool active;
  const _TargetRule({
    required this.condition,
    required this.result,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active
            ? AISColors.limeGreen.withOpacity(0.1)
            : AISColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? AISColors.limeGreen
              : AISColors.divider,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(condition,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('→ $result',
              style: TextStyle(
                  fontSize: 11,
                  color: active
                      ? AISColors.primaryGreen
                      : AISColors.textMedium)),
          if (active)
            const Text('✓ MATCHED',
                style: TextStyle(
                    color: AISColors.successGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ===================== ROLLOUT =====================
class _RolloutSection extends StatefulWidget {
  @override
  State<_RolloutSection> createState() => _RolloutSectionState();
}

class _RolloutSectionState extends State<_RolloutSection> {
  double _rolloutPct = 0;

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isNew = ldService.getBool(FlagKeys.newCheckoutFlow);
    final isNewCard = ldService.getBool(FlagKeys.newPackageCard);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('จำลอง Percentage Rollout',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                          'ใน Production: LaunchDarkly hash user key เพื่อ assign % อย่างสม่ำเสมอ',
                          style: TextStyle(
                              fontSize: 11, color: AISColors.textMedium)),
                    ],
                  ),
                ),
                Text('${_rolloutPct.toInt()}%',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AISColors.ldPink)),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AISColors.ldPink,
                thumbColor: AISColors.ldPink,
                overlayColor: AISColors.ldPink.withOpacity(0.2),
                inactiveTrackColor: AISColors.divider,
                trackHeight: 6,
              ),
              child: Slider(
                value: _rolloutPct,
                min: 0,
                max: 100,
                divisions: 10,
                onChanged: (v) {
                  setState(() => _rolloutPct = v);
                  ldService.setMockFlag(FlagKeys.newCheckoutFlow, v >= 50);
                  ldService.setMockFlag(FlagKeys.newPackageCard, v >= 25);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0% (ไม่มีใครเห็น)',
                    style: TextStyle(fontSize: 11, color: AISColors.textMedium)),
                const Text('100% (ทุกคนเห็น)',
                    style: TextStyle(fontSize: 11, color: AISColors.textMedium)),
              ],
            ),
            const SizedBox(height: 16),
            _RolloutStatus('new-checkout-flow', isNew,
                'เห็น New Checkout Flow (เริ่มที่ 50%)', AISColors.ldPink),
            const SizedBox(height: 8),
            _RolloutStatus('new-package-card-design', isNewCard,
                'เห็น Package Card ใหม่ (เริ่มที่ 25%)', AISColors.ldOrange),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '''// LaunchDarkly Dashboard → Targeting → Percentage Rollout
{
  "flag": "new-checkout-flow",
  "rollout": {
    "weightedVariations": [
      {"variation": 0 (false), "weight": ${(100 - _rolloutPct).toInt()}000},  // ${(100 - _rolloutPct).toInt()}%
      {"variation": 1 (true),  "weight": ${_rolloutPct.toInt()}000}   // ${_rolloutPct.toInt()}%
    ]
  }
}''',
                style: const TextStyle(
                    color: Color(0xFF64FFDA),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RolloutStatus extends StatelessWidget {
  final String flagKey;
  final bool value;
  final String label;
  final Color color;
  const _RolloutStatus(this.flagKey, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: value ? color : AISColors.textLight,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(flagKey,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Text('= ${value ? 'TRUE' : 'FALSE'}',
            style: TextStyle(
                color: value ? color : AISColors.textLight,
                fontSize: 11)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AISColors.textMedium)),
      ],
    );
  }
}

// ===================== KILL SWITCH =====================
class _KillSwitchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isMaintenance = ldService.getBool(FlagKeys.maintenanceMode);

    return Card(
      color: isMaintenance ? Colors.red.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isMaintenance ? Icons.emergency : Icons.check_circle,
                  color: isMaintenance ? Colors.red : AISColors.successGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMaintenance
                            ? '🚨 KILL SWITCH ACTIVE — ระบบปิดแล้ว!'
                            : '✅ ระบบทำงานปกติ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isMaintenance ? Colors.red.shade200 : AISColors.textDark,
                        ),
                      ),
                      Text(
                        isMaintenance
                            ? 'maintenance-mode = TRUE — ผู้ใช้เห็นหน้า Maintenance'
                            : 'maintenance-mode = FALSE — แสดงผลปกติ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isMaintenance
                              ? Colors.red.shade300
                              : AISColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isMaintenance,
                  onChanged: (v) {
                    ldService.setMockFlag(FlagKeys.maintenanceMode, v);
                  },
                  activeColor: Colors.red,
                ),
              ],
            ),
            if (isMaintenance) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      '⚡ ผู้ใช้ทุกคนเห็นหน้า Maintenance ทันที < 200ms\nปิด Toggle ด้านบนเพื่อกลับสู่การทำงานปกติ',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: const Text('ดูหน้า Maintenance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AISColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 Kill Switch ใช้ป้องกันเหตุฉุกเฉิน เช่น Bug รุนแรงหรือ Security Issue\n'
                  'เพียง Toggle เดียวในหน้า LaunchDarkly Dashboard จะปิดทุก User ทั่วโลกได้ทันที',
                  style: TextStyle(
                      color: AISColors.textMedium,
                      fontSize: 12,
                      height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===================== SCHEDULED =====================
class _ScheduledSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isActive = ldService.getBool(FlagKeys.seasonalPromo);
    final now = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: AISColors.ldYellow, size: 20),
                const SizedBox(width: 8),
                const Text('seasonal-promo',
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                _StatusPill(
                  isActive ? 'ACTIVE' : 'INACTIVE',
                  isActive ? AISColors.successGreen : AISColors.textLight,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Scheduled Changes ช่วยให้ตั้งเวลาเปิด/ปิด Flag ล่วงหน้าอัตโนมัติ ไม่ต้องนั่งเฝ้า',
              style: TextStyle(fontSize: 12, color: AISColors.textMedium, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ScheduleCard(
                    time: '2025-12-31 00:00',
                    action: 'Turn ON',
                    detail: 'เปิดโปรโมชั่นปีใหม่',
                    color: AISColors.successGreen,
                    isPast: now.isAfter(DateTime(2025, 12, 31)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ScheduleCard(
                    time: '2026-01-02 23:59',
                    action: 'Turn OFF',
                    detail: 'ปิดโปรโมชั่นหลังปีใหม่',
                    color: Colors.red,
                    isPast: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.lightbulb, size: 14, color: AISColors.ldYellow),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ตัวอย่าง: เปิดโปรฉลองปีใหม่ 31 ธ.ค. 00:00 น. และปิดอัตโนมัติ 2 ม.ค. 23:59 น.',
                    style: TextStyle(fontSize: 11, color: AISColors.textMedium),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Toggle ทดสอบ: ',
                    style: TextStyle(fontSize: 12)),
                Switch(
                  value: isActive,
                  onChanged: (v) =>
                      ldService.setMockFlag(FlagKeys.seasonalPromo, v),
                  activeColor: AISColors.ldYellow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String time;
  final String action;
  final String detail;
  final Color color;
  final bool isPast;
  const _ScheduleCard({
    required this.time,
    required this.action,
    required this.detail,
    required this.color,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: color, size: 14),
              const SizedBox(width: 4),
              Text(time,
                  style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: color,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(action,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(detail,
              style: const TextStyle(
                  fontSize: 11, color: AISColors.textMedium)),
          if (isPast)
            const Text('✓ เสร็จแล้ว',
                style: TextStyle(
                    color: AISColors.textLight,
                    fontSize: 10)),
        ],
      ),
    );
  }
}

// ===================== EXPERIMENTATION =====================
class _ExperimentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final variant = ldService.getString(FlagKeys.checkoutButtonColor, defaultValue: 'green');

    // Simulated A/B test results
    final results = <String, Map<String, num>>{
      'green':  {'clicks': 524, 'conversions': 89,  'rate': 17.0},
      'orange': {'clicks': 510, 'conversions': 102, 'rate': 20.0},
      'blue':   {'clicks': 498, 'conversions': 74,  'rate': 14.9},
      'red':    {'clicks': 501, 'conversions': 112, 'rate': 22.4},
    };

    final isWide = MediaQuery.of(context).size.width > 700;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science,
                    color: AISColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                const Text('checkout-button-color Experiment',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'A/B Test วัด Conversion Rate ของสีปุ่ม Checkout\nmetric: "checkout-completed" clicks',
              style: TextStyle(fontSize: 12, color: AISColors.textMedium, height: 1.4),
            ),
            const SizedBox(height: 16),
            // Current variant
            Row(
              children: [
                const Text('Active Variant: ',
                    style: TextStyle(
                        fontSize: 13, color: AISColors.textMedium)),
                _VariantPill(variant),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('เปลี่ยนที่ Flag 09 (String)',
                      style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Results chart
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _ConversionChart(results: results, current: variant)),
                  const SizedBox(width: 16),
                  Expanded(child: _ResultsTable(results: results, current: variant)),
                ],
              )
            else
              Column(
                children: [
                  _ConversionChart(results: results, current: variant),
                  const SizedBox(height: 12),
                  _ResultsTable(results: results, current: variant),
                ],
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Text('🏆', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Winner: "red" (22.4% conversion rate) — LD สามารถ Auto-promote variant ที่ดีที่สุดได้อัตโนมัติ',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB07D00),
                          fontWeight: FontWeight.w600),
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

class _VariantPill extends StatelessWidget {
  final String variant;
  const _VariantPill(this.variant);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (variant) {
      case 'orange': color = const Color(0xFFFF7628); break;
      case 'blue': color = const Color(0xFF2196F3); break;
      case 'red': color = const Color(0xFFE53935); break;
      default: color = AISColors.limeGreen;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        variant,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ConversionChart extends StatelessWidget {
  final Map<String, Map<String, num>> results;
  final String current;
  const _ConversionChart({required this.results, required this.current});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'green': AISColors.limeGreen,
      'orange': const Color(0xFFFF7628),
      'blue': const Color(0xFF2196F3),
      'red': const Color(0xFFE53935),
    };

    final bars = results.entries.toList().asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      final key = entry.key;
      final rate = (entry.value['rate'] ?? 0).toDouble();
      final color = colors[key] ?? Colors.grey;
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: rate,
            color: key == current ? color : color.withOpacity(0.4),
            width: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final keys = results.keys.toList();
                  if (val.toInt() < keys.length) {
                    return Text(keys[val.toInt()].toString(),
                        style: const TextStyle(fontSize: 11));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, meta) =>
                    Text('${val.toInt()}%',
                        style: const TextStyle(fontSize: 10)),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          maxY: 30,
        ),
      ),
    );
  }
}

class _ResultsTable extends StatelessWidget {
  final Map<String, Map<String, num>> results;
  final String current;
  const _ResultsTable({required this.results, required this.current});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      border: TableBorder.all(
          color: AISColors.divider,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration:
              const BoxDecoration(color: AISColors.primaryGreen),
          children: ['Variant', 'Clicks', 'Conv.', 'Rate%']
              .map((h) => Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(h,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                        textAlign: TextAlign.center),
                  ))
              .toList(),
        ),
        ...results.entries.map((e) {
          final key = e.key as String;
          final v = e.value;
          final isActive = key == current;
          return TableRow(
            decoration: BoxDecoration(
              color: isActive
                  ? AISColors.limeGreen.withOpacity(0.1)
                  : null,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        color: key == 'green'
                            ? AISColors.limeGreen
                            : key == 'orange'
                                ? const Color(0xFFFF7628)
                                : key == 'blue'
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFFE53935)),
                    const SizedBox(width: 4),
                    Text(key,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ],
                ),
              ),
              ...[(v['clicks'] ?? 0).toString(), (v['conversions'] ?? 0).toString(), '${v['rate'] ?? 0}%']
                  .map((val) => Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(val,
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center),
                      )),
            ],
          );
        }),
      ],
    );
  }
}

// ===================== AI CONFIG =====================
class _AIConfigSection extends StatefulWidget {
  @override
  State<_AIConfigSection> createState() => _AIConfigSectionState();
}

class _AIConfigSectionState extends State<_AIConfigSection> {
  String? _editingPrompt;

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final config = ldService.getJson(FlagKeys.aiModelConfig);

    final models = [
      ('claude-opus-4-7', 'Opus 4.7', '⚡ Most capable'),
      ('claude-sonnet-4-6', 'Sonnet 4.6', '⚖️ Balanced'),
      ('claude-haiku-4-5', 'Haiku 4.5', '🚀 Fastest'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy,
                    color: Color(0xFF7C4DFF), size: 20),
                const SizedBox(width: 8),
                const Text('AI Model Config',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('ai-model-config (JSON)',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7C4DFF),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'เปลี่ยน AI Model, Temperature, System Prompt แบบ Real-time โดยไม่ต้อง Deploy ใหม่',
              style: TextStyle(fontSize: 12, color: AISColors.textMedium, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Model selector
            const Text('เลือก Model:',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: models.map((m) {
                final selected = config['model'] == m.$1;
                return GestureDetector(
                  onTap: () {
                    final updated = Map<String, dynamic>.from(config)
                      ..['model'] = m.$1;
                    ldService.setMockFlag(FlagKeys.aiModelConfig, updated);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF7C4DFF)
                          : const Color(0xFF7C4DFF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: selected
                              ? const Color(0xFF7C4DFF)
                              : const Color(0xFF7C4DFF).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(m.$1.split('-').take(2).join('-'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF7C4DFF))),
                        Text(m.$3,
                            style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? Colors.white70
                                    : AISColors.textMedium)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Temperature slider
            Row(
              children: [
                const Text('Temperature: ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  (config['temperature'] as num? ?? 0.7).toStringAsFixed(1),
                  style: const TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF7C4DFF),
                thumbColor: const Color(0xFF7C4DFF),
                inactiveTrackColor: AISColors.divider,
                trackHeight: 4,
              ),
              child: Slider(
                value: (config['temperature'] as num? ?? 0.7).toDouble(),
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (v) {
                  final updated = Map<String, dynamic>.from(config)
                    ..['temperature'] = (v * 10).round() / 10;
                  ldService.setMockFlag(FlagKeys.aiModelConfig, updated);
                },
              ),
            ),
            const SizedBox(height: 12),

            // System prompt
            const Text('System Prompt:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                config['systemPrompt'] as String? ?? '',
                style: const TextStyle(
                    color: Color(0xFFAB9AF9),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PromptPreset(
                  label: '🇹🇭 ภาษาไทย',
                  prompt: 'คุณคือ AIS Assistant ผู้ช่วยอัจฉริยะ ตอบเป็นภาษาไทยเท่านั้น',
                  onSelect: (p) {
                    final updated = Map<String, dynamic>.from(config)
                      ..['systemPrompt'] = p;
                    ldService.setMockFlag(FlagKeys.aiModelConfig, updated);
                  },
                ),
                _PromptPreset(
                  label: '🇬🇧 English',
                  prompt: 'You are AIS Assistant. Always respond in English. Help users choose packages.',
                  onSelect: (p) {
                    final updated = Map<String, dynamic>.from(config)
                      ..['systemPrompt'] = p;
                    ldService.setMockFlag(FlagKeys.aiModelConfig, updated);
                  },
                ),
                _PromptPreset(
                  label: '💼 Sales Mode',
                  prompt: 'คุณคือ Sales Expert ของ AIS แนะนำแพ็กเกจแบบ Upsell เน้น Premium',
                  onSelect: (p) {
                    final updated = Map<String, dynamic>.from(config)
                      ..['systemPrompt'] = p;
                    ldService.setMockFlag(FlagKeys.aiModelConfig, updated);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF7C4DFF).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on,
                      color: Color(0xFF7C4DFF), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ทุกการเปลี่ยนแปลง AI Config ถูกอ่านจาก LaunchDarkly JSON flag\n'
                      'ไม่ต้อง redeploy โค้ด — เปลี่ยนได้ทันทีจาก LD Dashboard',
                      style: const TextStyle(
                          color: Color(0xFF7C4DFF),
                          fontSize: 11,
                          height: 1.4),
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

class _PromptPreset extends StatelessWidget {
  final String label;
  final String prompt;
  final Function(String) onSelect;
  const _PromptPreset(
      {required this.label, required this.prompt, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onSelect(prompt),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF7C4DFF),
        side: const BorderSide(color: Color(0xFF7C4DFF)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 11),
      ),
      child: Text(label),
    );
  }
}

// ===================== HELPERS =====================
class _FlagKey extends StatelessWidget {
  final String flagKey;
  const _FlagKey(this.flagKey);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        flagKey,
        style: const TextStyle(
            color: Color(0xFF58A6FF),
            fontSize: 10,
            fontFamily: 'monospace'),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DeepCollectionEquality {
  const DeepCollectionEquality();

  bool equals(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final k in a.keys) {
        if (!b.containsKey(k)) return false;
        if (!equals(a[k], b[k])) return false;
      }
      return true;
    }
    return a == b;
  }
}
