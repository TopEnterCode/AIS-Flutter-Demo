import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';
import '../providers/user_provider.dart';
import '../services/ld_service.dart';
import '../services/ld_context_factory.dart';
import '../constants/flag_keys.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _sdkKeyCtrl = TextEditingController();
  String _selectedRole = 'user';
  String? _activePersonaId;
  bool _saved = false;

  final _roles = [
    ('user', 'ลูกค้าทั่วไป', '👤'),
    ('vip', 'VIP Member', '⭐'),
    ('premium', 'Premium', '💎'),
    ('corporate', 'องค์กร', '🏢'),
    ('enterprise', 'Enterprise', '🏭'),
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameCtrl.text = user.name;
    _emailCtrl.text = user.email;
    _selectedRole = user.role;

    final ld = context.read<LDService>();
    _sdkKeyCtrl.text = ld.sdkKey ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _sdkKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final ldService = context.watch<LDService>();
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: const AISNavBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: isWide ? 120 : 16, vertical: 24),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _ProfileCard(user: user),
                        const SizedBox(height: 16),
                        _PersonaSwitcherCard(
                          activePersonaId: _activePersonaId,
                          onPersonaSelected: _applyPersona,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _EditForm(
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          selectedRole: _selectedRole,
                          roles: _roles,
                          onRoleChanged: (v) =>
                              setState(() => _selectedRole = v),
                          onSave: _saveProfile,
                          saved: _saved,
                        ),
                        const SizedBox(height: 16),
                        _LDConnectionCard(
                          sdkKeyCtrl: _sdkKeyCtrl,
                          ldService: ldService,
                          onConnect: _connectLD,
                          onDisconnect: () {
                            ldService.disconnect();
                            _sdkKeyCtrl.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _ProfileCard(user: user),
                  const SizedBox(height: 16),
                  _PersonaSwitcherCard(
                    activePersonaId: _activePersonaId,
                    onPersonaSelected: _applyPersona,
                  ),
                  const SizedBox(height: 16),
                  _EditForm(
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    selectedRole: _selectedRole,
                    roles: _roles,
                    onRoleChanged: (v) =>
                        setState(() => _selectedRole = v),
                    onSave: _saveProfile,
                    saved: _saved,
                  ),
                  const SizedBox(height: 16),
                  _LDConnectionCard(
                    sdkKeyCtrl: _sdkKeyCtrl,
                    ldService: ldService,
                    onConnect: _connectLD,
                    onDisconnect: () {
                      ldService.disconnect();
                      _sdkKeyCtrl.clear();
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _applyPersona(LDTargetingPersona persona) async {
    setState(() => _activePersonaId = persona.id);

    final user = context.read<UserProvider>();
    await user.applyPersona(persona.context);

    // Update form fields to reflect new persona
    _nameCtrl.text = persona.context.name ?? '';
    _emailCtrl.text = persona.context.email ?? '';
    setState(() => _selectedRole = persona.context.role ?? 'user');

    final ldService = context.read<LDService>();
    await ldService.identifyUser(persona.context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${persona.label} — LaunchDarkly Context อัปเดตแล้ว'),
          backgroundColor: AISColors.ldBlue,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _activePersonaId = null);
    final user = context.read<UserProvider>();
    await user.login(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      role: _selectedRole,
    );

    final ldService = context.read<LDService>();
    await ldService.identifyUser(user.toLDContext());

    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'บันทึกข้อมูลแล้ว — LaunchDarkly Context อัปเดตสำหรับ ${_emailCtrl.text}'),
          backgroundColor: AISColors.successGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _connectLD() async {
    if (_sdkKeyCtrl.text.isEmpty) return;
    final user = context.read<UserProvider>();
    await context.read<LDService>().connectToLaunchDarkly(
          sdkKey: _sdkKeyCtrl.text,
          context: user.toLDContext(),
        );
  }
}

// ── Persona Switcher ─────────────────────────────────────────────────────────

class _PersonaSwitcherCard extends StatelessWidget {
  final String? activePersonaId;
  final Future<void> Function(LDTargetingPersona) onPersonaSelected;

  const _PersonaSwitcherCard({
    required this.activePersonaId,
    required this.onPersonaSelected,
  });

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
                const Icon(Icons.people_alt,
                    color: AISColors.ldPurple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Targeting Personas',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AISColors.textDark),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AISColors.ldPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${LDContextFactory.personas.length} personas',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AISColors.ldPurple,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'เลือก Persona เพื่อสลับ LDContext — ดูว่า Targeting Rules ส่ง Flags ต่างกันอย่างไร',
              style: TextStyle(fontSize: 12, color: AISColors.textMedium),
            ),
            const SizedBox(height: 12),
            ...LDContextFactory.personas
                .map((p) => _PersonaItem(
                      persona: p,
                      isActive: p.id == activePersonaId,
                      onTap: () => onPersonaSelected(p),
                    )),
          ],
        ),
      ),
    );
  }
}

class _PersonaItem extends StatelessWidget {
  final LDTargetingPersona persona;
  final bool isActive;
  final VoidCallback onTap;

  const _PersonaItem({
    required this.persona,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? AISColors.ldPurple.withOpacity(0.08)
              : AISColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AISColors.ldPurple
                : AISColors.divider,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  persona.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isActive
                        ? AISColors.ldPurple
                        : AISColors.textDark,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AISColors.ldPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              persona.description,
              style: const TextStyle(
                  fontSize: 11, color: AISColors.textMedium),
            ),
            const SizedBox(height: 4),
            // Targeting rule badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AISColors.ldBlue.withOpacity(0.07),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                persona.targetingRule,
                style: const TextStyle(
                    fontSize: 10,
                    color: AISColors.ldBlue,
                    fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 6),
            // Expected flags preview
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: persona.expectedFlags.entries.map((e) {
                final val = e.value;
                final isPositive = val == true ||
                    (val is num && val > 0) ||
                    (val is String && val.isNotEmpty);
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AISColors.successGreen.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isPositive
                          ? AISColors.successGreen.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '${e.key}: $val',
                    style: TextStyle(
                      fontSize: 9,
                      color: isPositive
                          ? AISColors.successGreen
                          : AISColors.textLight,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final UserProvider user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final showVip = ldService.getBool(FlagKeys.showVipBenefits);
    final showCorp = ldService.getBool(FlagKeys.showCorporatePackages);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AISColors.primaryGreen,
              child: Text(
                user.avatarInitial,
                style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user.email,
                style: const TextStyle(
                    color: AISColors.textMedium, fontSize: 14)),
            const SizedBox(height: 8),
            _RoleChip(user.role),
            const SizedBox(height: 20),

            // LDContext inspector
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AISColors.ldBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AISColors.ldBlue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin,
                          size: 16, color: AISColors.ldBlue),
                      const SizedBox(width: 6),
                      const Text('LaunchDarkly Context',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AISColors.ldBlue)),
                      const Spacer(),
                      Text(
                        ldService.isMockMode ? 'Mock Mode' : 'Live',
                        style: TextStyle(
                          fontSize: 10,
                          color: ldService.isMockMode
                              ? AISColors.warningOrange
                              : AISColors.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ContextRow('kind', 'user'),
                  _ContextRow('key', user.userKey),
                  _ContextRow('name', user.name),
                  _ContextRow('email', user.email),
                  _ContextRow('role', user.role),
                  _ContextRow('plan', user.plan),
                  _ContextRow('country', user.country),
                  _ContextRow('betaTester', user.betaTester.toString()),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Active flags
            const Text('Flags ที่ได้รับสำหรับ user นี้',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AISColors.textMedium)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (showVip)
                  _FlagActive('👑 VIP Benefits', AISColors.gold),
                if (showCorp)
                  _FlagActive('🏢 Corporate', AISColors.ldPurple),
                if (user.betaTester)
                  _FlagActive('🧪 Beta Tester', AISColors.ldTeal),
                if (!showVip && !showCorp && !user.betaTester)
                  const Text('ยังไม่มี targeting พิเศษ',
                      style: TextStyle(
                          color: AISColors.textMedium, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip(this.role);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case 'vip':
        color = AISColors.gold;
        break;
      case 'premium':
        color = AISColors.ldPurple;
        break;
      case 'corporate':
        color = AISColors.ldBlue;
        break;
      case 'enterprise':
        color = AISColors.ldTeal;
        break;
      default:
        color = AISColors.primaryGreen;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(role.toUpperCase(),
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1)),
    );
  }
}

class _ContextRow extends StatelessWidget {
  final String k;
  final String v;
  const _ContextRow(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('  $k: ',
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AISColors.textMedium)),
          Expanded(
            child: Text('"$v"',
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AISColors.primaryGreen,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _FlagActive extends StatelessWidget {
  final String label;
  final Color color;
  const _FlagActive(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// ── Edit Form ─────────────────────────────────────────────────────────────────

class _EditForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final String selectedRole;
  final List<(String, String, String)> roles;
  final Function(String) onRoleChanged;
  final VoidCallback onSave;
  final bool saved;

  const _EditForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.selectedRole,
    required this.roles,
    required this.onRoleChanged,
    required this.onSave,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_pin, color: AISColors.ldBlue, size: 20),
                SizedBox(width: 8),
                Text('Custom User Context',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AISColors.textDark)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'แก้ไข Email หรือ Role แบบ Manual — LaunchDarkly จะ re-evaluate Targeting Rules ทันที',
              style: TextStyle(fontSize: 12, color: AISColors.textMedium),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                prefixIcon: Icon(Icons.person, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, size: 20),
                helperText: 'ลอง: user@ais.th → เปิด VIP Mode',
                helperStyle:
                    TextStyle(color: AISColors.ldBlue, fontSize: 10),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Role',
                style: TextStyle(
                    fontSize: 13,
                    color: AISColors.textMedium,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: roles
                  .map((r) => GestureDetector(
                        onTap: () => onRoleChanged(r.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedRole == r.$1
                                ? AISColors.primaryGreen
                                : AISColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedRole == r.$1
                                  ? AISColors.primaryGreen
                                  : AISColors.divider,
                            ),
                          ),
                          child: Text(
                            '${r.$3} ${r.$2}',
                            style: TextStyle(
                              color: selectedRole == r.$1
                                  ? Colors.white
                                  : AISColors.textDark,
                              fontSize: 12,
                              fontWeight: selectedRole == r.$1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: saved
                    ? const Icon(Icons.check, size: 18)
                    : const Icon(Icons.person_add, size: 18),
                label: Text(
                    saved ? 'บันทึกแล้ว!' : 'บันทึกและอัปเดต LD Context'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      saved ? AISColors.successGreen : AISColors.limeGreen,
                  foregroundColor:
                      saved ? Colors.white : AISColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LD Connection Card ────────────────────────────────────────────────────────

class _LDConnectionCard extends StatefulWidget {
  final TextEditingController sdkKeyCtrl;
  final LDService ldService;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _LDConnectionCard({
    required this.sdkKeyCtrl,
    required this.ldService,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  State<_LDConnectionCard> createState() => _LDConnectionCardState();
}

class _LDConnectionCardState extends State<_LDConnectionCard> {
  bool _showKey = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.ldService.status;
    final isConnected = widget.ldService.isConnected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_input_antenna,
                    color: AISColors.ldBlue, size: 20),
                const SizedBox(width: 8),
                const Text('LaunchDarkly Connection',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AISColors.textDark)),
                const Spacer(),
                _StatusDot(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isConnected
                  ? '✅ เชื่อมต่อกับ LaunchDarkly แล้ว (Real-time flags)'
                  : '🔧 Demo Mode — ใส่ Mobile SDK Key เพื่อใช้งานจริง',
              style: TextStyle(
                fontSize: 12,
                color: isConnected
                    ? AISColors.successGreen
                    : AISColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.sdkKeyCtrl,
              obscureText: !_showKey,
              decoration: InputDecoration(
                labelText: 'LaunchDarkly Mobile SDK Key',
                hintText: 'mob-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                prefixIcon: const Icon(Icons.vpn_key, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showKey ? Icons.visibility_off : Icons.visibility,
                      size: 18),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
                helperText:
                    'หาได้ที่ app.launchdarkly.com → Account → Projects → Client-side ID',
                helperStyle: const TextStyle(
                    fontSize: 10, color: AISColors.textMedium),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isConnected ? null : widget.onConnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AISColors.ldBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('เชื่อมต่อ LaunchDarkly'),
                  ),
                ),
                if (isConnected) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: widget.onDisconnect,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AISColors.errorRed,
                        side: const BorderSide(color: AISColors.errorRed)),
                    child: const Text('Disconnect'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final LDConnectionStatus status;
  const _StatusDot(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case LDConnectionStatus.connected:
        color = AISColors.successGreen;
        label = 'Connected';
        break;
      case LDConnectionStatus.connecting:
        color = AISColors.warningOrange;
        label = 'Connecting...';
        break;
      case LDConnectionStatus.error:
        color = AISColors.errorRed;
        label = 'Error';
        break;
      default:
        color = AISColors.textLight;
        label = 'Mock Mode';
    }
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
