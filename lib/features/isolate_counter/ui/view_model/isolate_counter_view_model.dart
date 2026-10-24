import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grand_app_ia_challange1/core/result/result.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_coordinator.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_exception.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_status_enum.dart';

class IsolateCounterViewModel extends ChangeNotifier {
  IsolateCounterViewModel({required this._coordinator}) {
    _coordinator.interval = _interval;
    _subscription = _coordinator.emissions.listen(
      _onEmission,
      onError: _onError,
    );
  }

  static const Duration minInterval = Duration(milliseconds: 100);
  static const Duration maxInterval = Duration(milliseconds: 2000);
  static const Duration defaultInterval = Duration(milliseconds: 500);
  static const int minLimit = 2;
  static const int maxLimit = 1000;
  static const int defaultLimit = 20;

  final CounterCoordinator _coordinator;
  late final StreamSubscription<CounterEmission> _subscription;

  CounterStatusEnum _status = CounterStatusEnum.idle;
  CounterEmission? _current;
  CounterException? _failure;
  Duration _interval = defaultInterval;
  String _limitInput = '$defaultLimit';
  int _activeLimit = defaultLimit;
  int _generation = 0;
  bool _isStarting = false;
  bool _disposed = false;

  CounterStatusEnum get status => _status;
  CounterEmission? get current => _current;
  CounterException? get failure => _failure;
  Duration get interval => _interval;
  String get limitInput => _limitInput;

  int? get limit => switch (int.tryParse(_limitInput)) {
    final int value when value >= minLimit && value <= maxLimit => value,
    _ => null,
  };

  bool get isLimitValid => limit != null;

  bool get _isActive =>
      _status == CounterStatusEnum.running ||
      _status == CounterStatusEnum.paused;

  bool get canEditLimit => !_isActive;
  bool get canStart => !_isActive && isLimitValid;
  bool get canTogglePause => _isActive && !_isStarting;
  bool get canStop => _status != CounterStatusEnum.idle;
  bool get canChangeInterval => _isActive;

  void onLimitChanged(String value) {
    if (!canEditLimit || value == _limitInput) {
      return;
    }

    _limitInput = value;
    _notify();
  }

  void setInterval(Duration value) {
    final clamped = Duration(
      milliseconds: value.inMilliseconds.clamp(
        minInterval.inMilliseconds,
        maxInterval.inMilliseconds,
      ),
    );

    if (clamped == _interval) {
      return;
    }

    _interval = clamped;
    _coordinator.interval = clamped;
    _notify();
  }

  Future<void> start() async {
    final limit = this.limit;
    if (!canStart || limit == null) {
      return;
    }

    final generation = ++_generation;
    _status = CounterStatusEnum.running;
    _current = null;
    _failure = null;
    _activeLimit = limit;
    _isStarting = true;
    _notify();

    final result = await _coordinator.start(limit: limit);
    if (_disposed || generation != _generation) {
      return;
    }

    _isStarting = false;
    switch (result) {
      case Ok():
        _notify();
      case Error(:final error):
        _fail(error);
    }
  }

  void togglePause() {
    switch (_status) {
      case CounterStatusEnum.running:
        _coordinator.pause();
        _status = CounterStatusEnum.paused;
      case CounterStatusEnum.paused:
        _coordinator.resume();
        _status = CounterStatusEnum.running;
      case CounterStatusEnum.idle ||
          CounterStatusEnum.finished ||
          CounterStatusEnum.failed:
        return;
    }

    _notify();
  }

  Future<void> stop() async {
    if (!canStop) {
      return;
    }

    _generation++;
    _status = CounterStatusEnum.idle;
    _current = null;
    _failure = null;
    _isStarting = false;
    _notify();
    await _coordinator.stop();
  }

  void _onEmission(CounterEmission emission) {
    if (!_isActive) {
      return;
    }

    _current = emission;
    if (emission.value >= _activeLimit) {
      _status = CounterStatusEnum.finished;
    }

    _notify();
  }

  void _onError(Object error) {
    if (!_isActive) {
      return;
    }

    _fail(error);
  }

  void _fail(Object error) {
    _status = CounterStatusEnum.failed;
    _failure = switch (error) {
      final CounterException exception => exception,
      _ => null,
    };

    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    unawaited(_coordinator.stop());
    super.dispose();
  }
}
