enum MpayRequestedApiVersion { v1, v2 }

extension MpayRequestedApiVersionLabel on MpayRequestedApiVersion {
  String get label => this == MpayRequestedApiVersion.v2 ? 'v2' : 'v1';
}

class MpayRouteDecision {
  final MpayRequestedApiVersion selectedVersion;
  final bool productionRuleMatched;
  final bool usedSafeDefault;
  final String reason;

  const MpayRouteDecision({
    required this.selectedVersion,
    required this.productionRuleMatched,
    required this.usedSafeDefault,
    required this.reason,
  });

  bool get isV2 => selectedVersion == MpayRequestedApiVersion.v2;
}

/// Mirrors the routing guard shown in the mPAY presentation:
/// merchant key "201" + requested API version "v2" routes to API v2.
/// Every other case is deliberately safe and routes to API v1.
MpayRouteDecision evaluateMpayRoute({
  required String merchantKey,
  required MpayRequestedApiVersion requestedVersion,
  required bool apiV2Flag,
  required bool sdkAvailable,
}) {
  if (!sdkAvailable) {
    return const MpayRouteDecision(
      selectedVersion: MpayRequestedApiVersion.v1,
      productionRuleMatched: false,
      usedSafeDefault: true,
      reason: 'SDK unavailable / cold start → default false',
    );
  }

  if (!apiV2Flag) {
    return const MpayRouteDecision(
      selectedVersion: MpayRequestedApiVersion.v1,
      productionRuleMatched: false,
      usedSafeDefault: false,
      reason: 'mpay-api-v2 evaluated false',
    );
  }

  final matches = merchantKey.trim() == '201' &&
      requestedVersion == MpayRequestedApiVersion.v2;
  if (matches) {
    return const MpayRouteDecision(
      selectedVersion: MpayRequestedApiVersion.v2,
      productionRuleMatched: true,
      usedSafeDefault: false,
      reason: 'merchant key 201 + apiVersion v2 matched',
    );
  }

  return const MpayRouteDecision(
    selectedVersion: MpayRequestedApiVersion.v1,
    productionRuleMatched: false,
    usedSafeDefault: false,
    reason: 'Production rule did not match → API v1',
  );
}

class MpayRequestPreview {
  final String transactionId;
  final String amount;
  final String currency;
  final String customerReference;
  final String description;
  final String idempotencyKey;
  final String requestId;
  final MpayRequestedApiVersion requestedVersion;

  const MpayRequestPreview({
    this.transactionId = 'tx-9081',
    this.amount = '1250.00',
    this.currency = 'THB',
    this.customerReference = 'C-771',
    this.description = 'Order 771',
    this.idempotencyKey = 'pay-8f21',
    this.requestId = 'req-1042',
    this.requestedVersion = MpayRequestedApiVersion.v2,
  });

  String get endpoint => '/api/payments';

  Map<String, String> get headers => {
        'Authorization': 'Bearer eyJ... (server-side)',
        'X-Requested-Api-Version': requestedVersion.label,
        'Idempotency-Key': idempotencyKey,
        'X-Request-Id': requestId,
      };

  Map<String, dynamic> get body => {
        'transactionId': transactionId,
        'amount': double.tryParse(amount) ?? amount,
        'currency': currency,
        'customerReference': customerReference,
        'description': description,
      };
}
