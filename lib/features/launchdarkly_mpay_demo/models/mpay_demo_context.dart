import '../../../services/ld_service.dart';

const mpayDemoAppVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0+1',
);

/// Synthetic identities used only by the mPAY customer demo.
class MpayDemoContext {
  final String name;
  final String key;
  final String userType;
  final String merchantId;
  final String country;
  final String appVersion;

  const MpayDemoContext({
    required this.name,
    required this.key,
    required this.userType,
    required this.merchantId,
    this.country = 'TH',
    this.appVersion = mpayDemoAppVersion,
  });

  LDUserContext toLDContext() => LDUserContext(
        key: key,
        name: name,
        role: userType,
        plan: 'mpay-demo',
        country: country,
        attributes: {
          'userType': userType,
          'merchantId': merchantId,
          'appVersion': appVersion,
        },
      );

  static const demoUsers = <MpayDemoContext>[
    MpayDemoContext(
      name: 'Internal Tester',
      key: 'employee-001',
      userType: 'internal',
      merchantId: 'MPAY-INTERNAL',
    ),
    MpayDemoContext(
      name: 'Beta Merchant',
      key: 'merchant-001',
      userType: 'merchant',
      // The merchant business key used by the production routing rule.
      merchantId: '201',
    ),
    MpayDemoContext(
      name: 'Normal Customer A',
      key: 'customer-001',
      userType: 'customer',
      merchantId: 'MERCHANT-001',
    ),
    MpayDemoContext(
      name: 'Normal Customer B',
      key: 'customer-002',
      userType: 'customer',
      merchantId: 'MERCHANT-002',
    ),
  ];

  static List<MpayDemoContext> get rolloutPopulation => [
        for (var i = 1; i <= 20; i++)
          MpayDemoContext(
            name: 'Synthetic Customer $i',
            key: 'customer-${i.toString().padLeft(3, '0')}',
            userType: 'customer',
            merchantId: 'MERCHANT-${i.toString().padLeft(3, '0')}',
          ),
      ];
}
