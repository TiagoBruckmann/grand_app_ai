import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/counter_emission.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/parity_badge.dart';
import 'package:provider/provider.dart';

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.select<IsolateCounterViewModel, CounterEmission?>(
      (viewModel) => viewModel.current,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String text = FlutterI18n.translate(
      context,
      I18nKeys.isolateCounterEmptyLabel,
    );
    String semanticsLabel = text;
    TextStyle? style = theme.textTheme.headlineSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    if (current != null) {
      text = '${current.value}';
      semanticsLabel = FlutterI18n.translate(
        context,
        I18nKeys.isolateCounterCurrentValue,
        translationParams: {I18nParams.value: text},
      );
      style = theme.textTheme.displayLarge?.copyWith(
        color: colorScheme.primary,
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Semantics(
            liveRegion: true,
            label: semanticsLabel,
            excludeSemantics: true,
            child: Text(
              text,
              key: IsolateCounterKeys.value,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),

          if (current != null) ...[
            const SizedBox(height: AppSpacing.md),

            ParityBadge(parity: current.parity),
          ],
        ],
      ),
    );
  }
}
