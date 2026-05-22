enum PackageCategory {
  mobile,
  fiber,
  international,
  smartHome,
  bundle,
  prepaid,
  postpaid,
}

extension PackageCategoryExtension on PackageCategory {
  String get label {
    switch (this) {
      case PackageCategory.mobile:
        return 'มือถือ';
      case PackageCategory.fiber:
        return 'ไฟเบอร์';
      case PackageCategory.international:
        return 'โทรต่างประเทศ';
      case PackageCategory.smartHome:
        return 'สมาร์ทโฮม';
      case PackageCategory.bundle:
        return 'บันเดิล';
      case PackageCategory.prepaid:
        return 'เติมเงิน';
      case PackageCategory.postpaid:
        return 'รายเดือน';
    }
  }

  String get icon {
    switch (this) {
      case PackageCategory.mobile:
        return '📱';
      case PackageCategory.fiber:
        return '🌐';
      case PackageCategory.international:
        return '✈️';
      case PackageCategory.smartHome:
        return '🏠';
      case PackageCategory.bundle:
        return '📦';
      case PackageCategory.prepaid:
        return '💳';
      case PackageCategory.postpaid:
        return '📋';
    }
  }
}

class AISPackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final String priceUnit;
  final PackageCategory category;
  final List<String> features;
  final String? badge;
  final bool isPopular;
  final bool isBestValue;
  final String? networkType;
  final int? dataGb;
  final bool unlimitedData;
  final int? speedMbps;
  final int? voiceMinutes;
  final String? imageUrl;
  final String? colorHex;

  const AISPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.priceUnit = 'บาท/เดือน',
    required this.category,
    required this.features,
    this.badge,
    this.isPopular = false,
    this.isBestValue = false,
    this.networkType,
    this.dataGb,
    this.unlimitedData = false,
    this.speedMbps,
    this.voiceMinutes,
    this.imageUrl,
    this.colorHex,
  });

  AISPackage copyWith({
    double? price,
    String? badge,
    List<String>? features,
  }) {
    return AISPackage(
      id: id,
      name: name,
      description: description,
      price: price ?? this.price,
      priceUnit: priceUnit,
      category: category,
      features: features ?? this.features,
      badge: badge ?? this.badge,
      isPopular: isPopular,
      isBestValue: isBestValue,
      networkType: networkType,
      dataGb: dataGb,
      unlimitedData: unlimitedData,
      speedMbps: speedMbps,
      voiceMinutes: voiceMinutes,
      imageUrl: imageUrl,
      colorHex: colorHex,
    );
  }
}

class CartItem {
  final AISPackage package;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    required this.package,
    this.quantity = 1,
    required this.addedAt,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      package: package,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt,
    );
  }

  double get totalPrice => package.price * quantity;
}
