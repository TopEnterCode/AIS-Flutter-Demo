// LaunchDarkly Flag Keys - all flags used in the app
class FlagKeys {
  // 1. Boolean Flags
  static const String showPromoBanner = 'show-promo-banner';
  static const String enableAiAssistant = 'enable-ai-assistant';
  static const String maintenanceMode = 'maintenance-mode';
  static const String showNewNavbar = 'show-new-navbar';
  static const String enableDarkMode = 'enable-dark-mode';

  // 2. Multivariate - String
  static const String heroBannerVariant = 'hero-banner-variant';
  static const String ctaButtonText = 'cta-button-text';
  static const String promoBannerStyle = 'promo-banner-style';

  // 3. Multivariate - Number
  static const String discountPercentage = 'discount-percentage';
  static const String maxCartItems = 'max-cart-items';
  static const String freeDataGb = 'free-data-gb';

  // 4. Multivariate - JSON
  static const String featuredPackagesConfig = 'featured-packages-config';
  static const String checkoutConfig = 'checkout-config';
  static const String paymentMethodsConfig = 'payment-methods-config';

  // 5. User Targeting (boolean flags that evaluate differently per user)
  static const String showVipBenefits = 'show-vip-benefits';
  static const String showCorporatePackages = 'show-corporate-packages';

  // 6. Percentage Rollout
  static const String newCheckoutFlow = 'new-checkout-flow';
  static const String newPackageCard = 'new-package-card-design';

  // 7. Kill Switch (same as boolean but used for emergency)
  // Uses maintenanceMode above

  // 8. Scheduled Changes (same flags, toggled on schedule in LD dashboard)
  static const String seasonalPromo = 'seasonal-promo';

  // 9. Experimentation
  static const String checkoutButtonColor = 'checkout-button-color';
  static const String packageSortOrder = 'package-sort-order';

  // 10. AI Config
  static const String aiModelConfig = 'ai-model-config';
}
