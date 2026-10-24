import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/core/widgets/adaptive/adaptive_button.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_status_enum.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:provider/provider.dart';

class CounterControls extends StatelessWidget {
  const CounterControls({super.key});

  @override
  Widget build(BuildContext context) {
    final (:canStart, :canTogglePause, :canStop, :isPaused) = context
        .select<
          IsolateCounterViewModel,
          ({bool canStart, bool canTogglePause, bool canStop, bool isPaused})
        >(
          (viewModel) => (
            canStart: viewModel.canStart,
            canTogglePause: viewModel.canTogglePause,
            canStop: viewModel.canStop,
            isPaused: viewModel.status == CounterStatusEnum.paused,
          ),
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AdaptiveButton(
          key: IsolateCounterKeys.start,
          label: FlutterI18n.translate(context, I18nKeys.isolateCounterStart),
          icon: Icons.play_arrow,
          onPressed: canStart
              ? () => unawaited(context.read<IsolateCounterViewModel>().start())
              : null,
        ),

        AdaptiveButton(
          key: IsolateCounterKeys.togglePause,
          label: FlutterI18n.translate(
            context,
            isPaused
                ? I18nKeys.isolateCounterResume
                : I18nKeys.isolateCounterPause,
          ),
          icon: isPaused ? Icons.play_arrow : Icons.pause,
          style: AdaptiveButtonStyle.tonal,
          onPressed: canTogglePause
              ? () => context.read<IsolateCounterViewModel>().togglePause()
              : null,
        ),

        AdaptiveButton(
          key: IsolateCounterKeys.stop,
          label: FlutterI18n.translate(context, I18nKeys.isolateCounterStop),
          icon: Icons.stop,
          style: AdaptiveButtonStyle.tonal,
          onPressed: canStop
              ? () => unawaited(context.read<IsolateCounterViewModel>().stop())
              : null,
        ),
      ],
    );
  }
}
