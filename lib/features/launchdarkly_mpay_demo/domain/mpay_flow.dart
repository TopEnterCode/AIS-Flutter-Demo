enum MpayVersion { v1, v2 }

MpayVersion versionForFlag(bool value) =>
    value ? MpayVersion.v2 : MpayVersion.v1;

class MpayFlagEvaluation {
  final bool value;
  final bool usedFallback;

  const MpayFlagEvaluation({required this.value, required this.usedFallback});

  const MpayFlagEvaluation.fallback()
      : value = false,
        usedFallback = true;

  factory MpayFlagEvaluation.fromNullable(bool? value) => value == null
      ? const MpayFlagEvaluation.fallback()
      : MpayFlagEvaluation(value: value, usedFallback: false);
}

String mpayVersionLabel(MpayVersion version) =>
    version == MpayVersion.v2 ? 'V2' : 'V1';
