import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_exception.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_status_enum.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:provider/provider.dart';

class StatusText extends StatelessWidget {
  const StatusText({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<IsolateCounterViewModel, CounterStatusEnum>(
      (viewModel) => viewModel.status,
    );

    final failure = context.select<IsolateCounterViewModel, CounterException?>(
      (viewModel) => viewModel.failure,
    );

    final theme = Theme.of(context);

    final statusKey = switch (status) {
      CounterStatusEnum.idle => I18nKeys.isolateCounterStatusIdle,
      CounterStatusEnum.running => I18nKeys.isolateCounterStatusRunning,
      CounterStatusEnum.paused => I18nKeys.isolateCounterStatusPaused,
      CounterStatusEnum.finished => I18nKeys.isolateCounterStatusFinished,
      CounterStatusEnum.failed => I18nKeys.isolateCounterStatusFailed,
    };

    final failureKey = switch (failure) {
      null => null,
      CounterSpawnFailed() => I18nKeys.isolateCounterErrorSpawnFailed,
      CounterWorkerCrashed() => I18nKeys.isolateCounterErrorWorkerCrashed,
    };

    return Column(
      children: [
        Text(
          FlutterI18n.translate(context, statusKey),
          key: IsolateCounterKeys.status,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),

        if (failureKey != null) ...[
          const SizedBox(height: AppSpacing.xs),

          Text(
            FlutterI18n.translate(context, failureKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
