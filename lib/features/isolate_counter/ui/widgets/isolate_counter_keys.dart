import 'package:flutter/foundation.dart';

abstract final class IsolateCounterKeys {
  static const Key value = ValueKey('isolate_counter.value');
  static const Key parityBadge = ValueKey('isolate_counter.parity_badge');
  static const Key status = ValueKey('isolate_counter.status');
  static const Key start = ValueKey('isolate_counter.start');
  static const Key togglePause = ValueKey('isolate_counter.toggle_pause');
  static const Key stop = ValueKey('isolate_counter.stop');
  static const Key intervalSlider = ValueKey('isolate_counter.interval_slider');
  static const Key limitInput = ValueKey('isolate_counter.limit_input');
}
