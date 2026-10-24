import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_keys.dart';

class EchoLabel extends StatelessWidget {
  const EchoLabel({required this.text, super.key});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = this.text;
    final isEmpty = text == null;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          text ?? FlutterI18n.translate(context, I18nKeys.echoTextEmptyLabel),
          key: EchoTextKeys.label,
          softWrap: true,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isEmpty
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
