import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';

class ParityBadge extends StatelessWidget {
  const ParityBadge({required this.parity, super.key});

  final ParityEnum parity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (background, foreground, icon, labelKey) = switch (parity) {
      ParityEnum.odd => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        Icons.filter_1,
        I18nKeys.isolateCounterParityOdd,
      ),
      ParityEnum.even => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        Icons.filter_2,
        I18nKeys.isolateCounterParityEven,
      ),
    };

    return DecoratedBox(
      key: IsolateCounterKeys.parityBadge,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              icon,
              color: foreground,
            ),

            const SizedBox(width: AppSpacing.sm),

            Flexible(
              child: Text(
                FlutterI18n.translate(context, labelKey),
                style: theme.textTheme.labelLarge?.copyWith(color: foreground),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
