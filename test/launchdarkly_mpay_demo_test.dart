import 'package:flutter_test/flutter_test.dart';

import 'package:ais_package_store/features/launchdarkly_mpay_demo/domain/mpay_flow.dart';
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

  test('beta merchant context includes merchant targeting attribute', () {
    final context = MpayDemoContext.demoUsers[1].toLDContext();

    expect(context.key, 'merchant-001');
    expect(context.attributes['userType'], 'merchant');
    expect(context.attributes['merchantId'], 'MERCHANT-BETA');
  });
}
