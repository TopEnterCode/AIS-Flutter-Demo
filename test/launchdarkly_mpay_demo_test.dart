import 'package:flutter_test/flutter_test.dart';

import 'package:ais_package_store/features/launchdarkly_mpay_demo/domain/mpay_flow.dart';
import 'package:ais_package_store/features/launchdarkly_mpay_demo/domain/mpay_routing.dart';
import 'package:ais_package_store/features/launchdarkly_mpay_demo/models/mpay_demo_context.dart';

void main() {
  test('false API and connector flags resolve to V1', () {
    expect(versionForFlag(false), MpayVersion.v1);
    expect(MpayFlagEvaluation.fromNullable(false).usedFallback, isFalse);
  });

  test('true API and connector flags resolve to V2', () {
    expect(versionForFlag(true), MpayVersion.v2);
    expect(MpayFlagEvaluation.fromNullable(true).usedFallback, isFalse);
  });

  test(
      'missing or failed evaluation uses false / API and connector V1 fallback',
      () {
    final evaluation = MpayFlagEvaluation.fromNullable(null);

    expect(evaluation.value, isFalse);
    expect(evaluation.usedFallback, isTrue);
    expect(versionForFlag(evaluation.value), MpayVersion.v1);
  });

  test('internal demo context includes stable internal targeting attributes',
      () {
    final context = MpayDemoContext.demoUsers.first.toLDContext();

    expect(context.key, 'employee-001');
    expect(context.attributes['userType'], 'internal');
    expect(context.attributes['merchantId'], 'MPAY-INTERNAL');
  });

  test('beta merchant context includes production merchant key', () {
    final context = MpayDemoContext.demoUsers[1].toLDContext();

    expect(context.key, 'merchant-001');
    expect(context.attributes['userType'], 'merchant');
    expect(context.attributes['merchantId'], '201');
  });

  test(
      'production routing rule sends only merchant 201 requesting v2 to API v2',
      () {
    final decision = evaluateMpayRoute(
      merchantKey: '201',
      requestedVersion: MpayRequestedApiVersion.v2,
      apiV2Flag: true,
      sdkAvailable: true,
    );

    expect(decision.isV2, isTrue);
    expect(decision.productionRuleMatched, isTrue);
  });

  test('routing rule safely sends mismatches to API v1', () {
    final decision = evaluateMpayRoute(
      merchantKey: '1',
      requestedVersion: MpayRequestedApiVersion.v2,
      apiV2Flag: true,
      sdkAvailable: true,
    );

    expect(decision.selectedVersion, MpayRequestedApiVersion.v1);
    expect(decision.productionRuleMatched, isFalse);
  });

  test('unavailable SDK uses the safe API v1 default', () {
    final decision = evaluateMpayRoute(
      merchantKey: '201',
      requestedVersion: MpayRequestedApiVersion.v2,
      apiV2Flag: true,
      sdkAvailable: false,
    );

    expect(decision.selectedVersion, MpayRequestedApiVersion.v1);
    expect(decision.usedSafeDefault, isTrue);
  });

  test('request preview keeps one idempotency key and request id visible', () {
    const request = MpayRequestPreview();

    expect(request.endpoint, '/api/payments');
    expect(request.headers['Idempotency-Key'], 'pay-8f21');
    expect(request.headers['X-Request-Id'], 'req-1042');
    expect(request.body['transactionId'], 'tx-9081');
  });
}
