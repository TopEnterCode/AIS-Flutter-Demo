import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/ais_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';

class AISNavBar extends StatefulWidget implements PreferredSizeWidget {
  const AISNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AISNavBar> createState() => _AISNavBarState();
}

class _AISNavBarState extends State<AISNavBar> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final cart = context.watch<CartProvider>();
    final user = context.watch<UserProvider>();
    final useNewNavbar = ldService.getBool(FlagKeys.showNewNavbar);
    final isMaintenance = ldService.getBool(FlagKeys.maintenanceMode);

    return AppBar(
      backgroundColor: AISColors.navGreen,
      leading: _buildLogo(context),
      leadingWidth: 140,
      title: useNewNavbar
          ? _buildNewNavItems(context)
          : _buildNavItems(context),
      actions: [
        if (!isMaintenance) ...[
          _buildSearchIcon(context),
          _buildCartIcon(context, cart),
          _buildUserIcon(context, user),
          _buildLDDemoButton(context),
        ],
        const SizedBox(width: 8),
      ],
      flexibleSpace: _buildTopBanner(context, ldService),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/'),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            _AISLogoIcon(),
            const SizedBox(width: 6),
            const Text(
              'AIS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItems(BuildContext context) {
    final items = [
      ('มือถือ', '/packages?category=mobile'),
      ('ไฟเบอร์', '/packages?category=fiber'),
      ('โปรโมชั่น', '/packages'),
      ('บริการ', '/packages?category=bundle'),
    ];
    final isWide = MediaQuery.of(context).size.width > 900;
    if (!isWide) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map((item) => _NavItem(label: item.$1, route: item.$2))
          .toList(),
    );
  }

  Widget _buildNewNavItems(BuildContext context) {
    final items = [
      ('📱', 'มือถือ', '/packages?category=mobile'),
      ('🌐', 'ไฟเบอร์', '/packages?category=fiber'),
      ('🎁', 'โปรโมชั่น', '/packages'),
      ('📦', 'บันเดิล', '/packages?category=bundle'),
    ];
    final isWide = MediaQuery.of(context).size.width > 900;
    if (!isWide) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map((item) => _NewNavItem(
                icon: item.$1,
                label: item.$2,
                route: item.$3,
              ))
          .toList(),
    );
  }

  Widget _buildSearchIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      tooltip: 'ค้นหา',
      onPressed: () {},
    );
  }

  Widget _buildCartIcon(BuildContext context, CartProvider cart) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          tooltip: 'ตะกร้า',
          onPressed: () => context.go('/cart'),
        ),
        if (cart.itemCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AISColors.limeGreen,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                cart.itemCount.toString(),
                style: const TextStyle(
                  color: AISColors.primaryGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserIcon(BuildContext context, UserProvider user) {
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AISColors.limeGreen.withOpacity(0.2),
          child: Text(
            user.avatarInitial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLDDemoButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: TextButton.icon(
        onPressed: () => context.go('/ld-demo'),
        icon: const Icon(Icons.toggle_on, color: AISColors.ldBlue, size: 20),
        label: const Text(
          'LD Demo',
          style: TextStyle(
            color: AISColors.ldBlue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: AISColors.ldBlue.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context, LDService ldService) {
    // This is here to render under the AppBar content — not actually used as flexibleSpace
    return const SizedBox.shrink();
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final String route;
  const _NavItem({required this.label, required this.route});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _hovered ? AISColors.limeGreen : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovered ? AISColors.limeGreen : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewNavItem extends StatefulWidget {
  final String icon;
  final String label;
  final String route;
  const _NewNavItem(
      {required this.icon, required this.label, required this.route});

  @override
  State<_NewNavItem> createState() => _NewNavItemState();
}

class _NewNavItemState extends State<_NewNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 20)),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovered ? AISColors.limeGreen : Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AISLogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(painter: _AISBirdPainter()),
    );
  }
}

class _AISBirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AISColors.limeGreen
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw simplified AIS bird/chevron shape
    final path1 = Path()
      ..moveTo(w * 0.1, h * 0.7)
      ..lineTo(w * 0.45, h * 0.2)
      ..lineTo(w * 0.6, h * 0.4)
      ..lineTo(w * 0.35, h * 0.75)
      ..close();

    final path2 = Path()
      ..moveTo(w * 0.35, h * 0.7)
      ..lineTo(w * 0.65, h * 0.2)
      ..lineTo(w * 0.8, h * 0.4)
      ..lineTo(w * 0.55, h * 0.78)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Secondary Navbar for mobile categories
class AISCategoryBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;
  final List<String> categories;

  const AISCategoryBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AISColors.primaryGreen,
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? AISColors.limeGreen
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[i],
                  style: TextStyle(
                    color:
                        selected ? AISColors.primaryGreen : Colors.white,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
