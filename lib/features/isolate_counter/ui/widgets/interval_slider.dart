import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:provider/provider.dart';

class IntervalSlider extends StatelessWidget {
  const IntervalSlider({super.key});

  static const int _stepMs = 100;

  @override
  Widget build(BuildContext context) {
    final (:interval, :enabled) = context
        .select<IsolateCounterViewModel, ({Duration interval, bool enabled})>(
          (viewModel) => (
            interval: viewModel.interval,
            enabled: viewModel.canChangeInterval,
          ),
        );

    const min = IsolateCounterViewModel.minInterval;
    const max = IsolateCounterViewModel.maxInterval;
    final label = FlutterI18n.translate(
      context,
      I18nKeys.isolateCounterIntervalLabel,
      translationParams: {I18nParams.ms: '${interval.inMilliseconds}'},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),

        Semantics(
          label: label,
          child: Slider.adaptive(
            key: IsolateCounterKeys.intervalSlider,
            value: interval.inMilliseconds.toDouble(),
            min: min.inMilliseconds.toDouble(),
            max: max.inMilliseconds.toDouble(),
            divisions: (max - min).inMilliseconds ~/ _stepMs,
            onChanged: enabled
                ? (value) => context
                      .read<IsolateCounterViewModel>()
                      .setInterval(Duration(milliseconds: value.round()))
                : null,
          ),
        ),

      ],
    );
  }
}
