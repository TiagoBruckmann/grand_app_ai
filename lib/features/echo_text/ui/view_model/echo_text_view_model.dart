import 'package:flutter/foundation.dart';

class EchoTextViewModel extends ChangeNotifier {
  String _input = '';
  String? _echoedText;

  String? get echoedText => _echoedText;

  bool get canSubmit => _input.trim().isNotEmpty;

  void onInputChanged(String value) {
    final couldSubmit = canSubmit;
    _input = value;
    if (couldSubmit != canSubmit) {
      notifyListeners();
    }
  }

  void submit() {
    if (!canSubmit) {
      return;
    }
    _echoedText = _input.trim();
    _input = '';
    notifyListeners();
  }
}
