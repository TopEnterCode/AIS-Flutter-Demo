import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/ais_theme.dart';
import '../widgets/ais_navbar.dart';
import '../widgets/package_card.dart';
import '../data/packages_data.dart';
import '../models/package.dart';
import '../services/ld_service.dart';
import '../constants/flag_keys.dart';

class PackagesScreen extends StatefulWidget {
  final String? categoryFilter;
  const PackagesScreen({super.key, this.categoryFilter});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final _categories = [
    (null, 'ทั้งหมด'),
    (PackageCategory.postpaid, 'มือถือรายเดือน'),
    (PackageCategory.prepaid, 'เติมเงิน'),
    (PackageCategory.fiber, 'AIS Fibre'),
    (PackageCategory.bundle, 'บันเดิล'),
    (PackageCategory.international, 'โรมมิ่ง'),
  ];

  int get _initialIndex {
    if (widget.categoryFilter == null) return 0;
    final idx = _categories.indexWhere(
        (c) => c.$1?.name == widget.categoryFilter);
    return idx >= 0 ? idx : 0;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: _initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ldService = context.watch<LDService>();
    final isMaintenance = ldService.getBool(FlagKeys.maintenanceMode);
    final showVip = ldService.getBool(FlagKeys.showVipBenefits);
    final showCorp = ldService.getBool(FlagKeys.showCorporatePackages);
    final discountPct = ldService.getNumber(FlagKeys.discountPercentage);

    if (isMaintenance) {
      return Scaffold(
        appBar: const AISNavBar(),
        body: const Center(child: Text('ระบบกำลังปรับปรุง')),
      );
    }

    return Scaffold(
      appBar: const AISNavBar(),
      body: Column(
        children: [
          // Header
          Container(
            color: AISColors.primaryGreen,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'แพ็กเกจทั้งหมด',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาแพ็กเกจ...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _categories
                      .map((c) => Tab(
                            text: c.$2,
                          ))
                      .toList(),
                  labelColor: AISColors.limeGreen,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: AISColors.limeGreen,
                  tabAlignment: TabAlignment.start,
                ),
              ],
            ),
          ),

          // Flags indicator
          if (discountPct > 0 || showVip || showCorp)
            Container(
              color: AISColors.ldBlue.withOpacity(0.05),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.toggle_on,
                      size: 16, color: AISColors.ldBlue),
                  const SizedBox(width: 6),
                  const Text('LaunchDarkly flags active: ',
                      style: TextStyle(
                          fontSize: 11, color: AISColors.ldBlue)),
                  if (discountPct > 0)
                    _FlagChip('ลด ${discountPct.toInt()}%', Colors.red),
                  if (showVip)
                    _FlagChip('VIP Mode', AISColors.gold),
                  if (showCorp)
                    _FlagChip('Corporate Mode', AISColors.ldPurple),
                ],
              ),
            ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((cat) {
                var packages = cat.$1 == null
                    ? PackagesData.all
                    : PackagesData.byCategory(cat.$1!);

                if (_searchQuery.isNotEmpty) {
                  packages = packages
                      .where((p) =>
                          p.name.contains(_searchQuery) ||
                          p.description.contains(_searchQuery))
                      .toList();
                }

                // VIP targeting: add Privilege package to visible list
                if (showVip && cat.$1 == null) {
                  packages = packages.toList(); // already includes privilege
                }

                return _PackageGrid(
                  packages: packages,
                  discountPct: discountPct,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageGrid extends StatelessWidget {
  final List<AISPackage> packages;
  final double discountPct;
  const _PackageGrid({required this.packages, required this.discountPct});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isMed = MediaQuery.of(context).size.width > 600;

    if (packages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64, color: AISColors.textLight),
            SizedBox(height: 16),
            Text('ไม่พบแพ็กเกจ',
                style: TextStyle(
                    color: AISColors.textMedium, fontSize: 16)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : (isMed ? 3 : 2),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 0.58 : 0.65,
      ),
      itemCount: packages.length,
      itemBuilder: (ctx, i) => PackageCard(package: packages[i]),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _FlagChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
