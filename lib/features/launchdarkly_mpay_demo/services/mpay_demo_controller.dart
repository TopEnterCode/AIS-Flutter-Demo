import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../constants/flag_keys.dart';
import '../../../services/ld_service.dart';
import '../domain/mpay_flow.dart';
import '../models/mpay_demo_context.dart';

class MpayPopulationResult {
  final MpayDemoContext context;
  final bool value;
  final bool usedFallback;

  const MpayPopulationResult({
    required this.context,
    required this.value,
    required this.usedFallback,
  });
}

class MpayDemoController extends ChangeNotifier {
  final LDService ldService;

  MpayDemoContext _selected = MpayDemoContext.demoUsers[2];
  bool _isSelecting = false;
  bool _populationLoading = false;
  bool _simulateV2Failure = false;
  bool _evaluationError = false;
  bool _usingFallback = true;
  bool _paymentV2FailureObserved = false;
  bool _disposed = false;
  bool _apiV2 = false;
  bool _connectorV2 = false;
  bool _paymentFlowV2 = false;
  List<MpayPopulationResult> _populationResults = const [];

  MpayDemoController(this.ldService) {
    ldService.addListener(_onLaunchDarklyChanged);
    _syncEvaluation();
    unawaited(selectContext(_selected));
  }

  MpayDemoContext get selected => _selected;
  bool get isSelecting => _isSelecting;
  bool get populationLoading => _populationLoading;
  bool get simulateV2Failure => _simulateV2Failure;
  bool get evaluationError => _evaluationError;
  bool get usingFallback => _usingFallback;
  bool get sdkAvailable => ldService.isConnected && !_evaluationError;
  bool get apiV2 => _apiV2;
  bool get connectorV2 => _connectorV2;
  bool get paymentFlowV2 => _paymentFlowV2;
  bool get v2Ready => _paymentFlowV2 && _apiV2 && _connectorV2;

  MpayVersion get apiVersion => versionForFlag(_apiV2);
  MpayVersion get connectorVersion => versionForFlag(_connectorV2);
  MpayVersion get paymentFlowVersion => versionForFlag(_paymentFlowV2);
  List<MpayPopulationResult> get populationResults => _populationResults;
  bool get populationUsesFallback =>
      _populationResults.any((result) => result.usedFallback);
  bool get emergencyFallbackActive =>
      _paymentV2FailureObserved && !_apiV2 && !_connectorV2;

  Future<void> selectContext(MpayDemoContext context) async {
    _selected = context;
    _isSelecting = true;
    _evaluationError = false;
    _paymentV2FailureObserved = false;
    notifyListeners();

    try {
      await ldService.identifyUser(context.toLDContext());
    } catch (error) {
      debugPrint('[mPAY Demo] LaunchDarkly evaluation error: $error');
      _evaluationError = true;
    }

    if (_disposed) return;

    _isSelecting = false;
    _syncEvaluation();
    notifyListeners();
  }

  void setSimulateV2Failure(bool value) {
    _simulateV2Failure = value;
    notifyListeners();
  }

  void recordV2PaymentFailure() {
    _paymentV2FailureObserved = true;
    notifyListeners();
  }

  Future<void> evaluatePopulation() async {
    _populationLoading = true;
    _populationResults = const [];
    notifyListeners();

    final population = MpayDemoContext.rolloutPopulation;
    if (!ldService.isConnected) {
      _populationResults = population
          .map((context) => MpayPopulationResult(
                context: context,
                value: false,
                usedFallback: true,
              ))
          .toList();
      _populationLoading = false;
      notifyListeners();
      return;
    }

    final originalContext = _selected;
    final results = <MpayPopulationResult>[];
    for (final context in population) {
      var usedFallback = false;
      var value = false;
      try {
        await ldService.identifyUser(context.toLDContext());
        if (_disposed) return;
        value = ldService.getBool(FlagKeys.mpayApiV2);
      } catch (error) {
        debugPrint('[mPAY Demo] Population evaluation error: $error');
        usedFallback = true;
      }
      results.add(MpayPopulationResult(
        context: context,
        value: value,
        usedFallback: usedFallback,
      ));
    }

    try {
      await ldService.identifyUser(originalContext.toLDContext());
    } catch (error) {
      debugPrint('[mPAY Demo] Could not restore selected context: $error');
      _evaluationError = true;
    }

    if (_disposed) return;

    _populationResults = results;
    _populationLoading = false;
    _syncEvaluation();
    notifyListeners();
  }

  void _onLaunchDarklyChanged() {
    _syncEvaluation();
    notifyListeners();
  }

  void _syncEvaluation() {
    final available = ldService.isConnected && !_evaluationError;
    _usingFallback = !available;
    if (!available) {
      _apiV2 = false;
      _connectorV2 = false;
      _paymentFlowV2 = false;
      return;
    }

    try {
      _apiV2 = ldService.getBool(FlagKeys.mpayApiV2);
      _connectorV2 = ldService.getBool(FlagKeys.mpayConnectorV2);
      _paymentFlowV2 = ldService.getBool(FlagKeys.paymentFlowV2);
    } catch (error) {
      debugPrint('[mPAY Demo] LaunchDarkly variation error: $error');
      _evaluationError = true;
      _usingFallback = true;
      _apiV2 = false;
      _connectorV2 = false;
      _paymentFlowV2 = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ldService.removeListener(_onLaunchDarklyChanged);
    super.dispose();
  }
}
