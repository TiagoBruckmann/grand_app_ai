import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/core/widgets/adaptive/adaptive_platform.dart';

class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  Widget build(BuildContext context) {

    if (!context.isCupertino) {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          errorMaxLines: 2,
        ),
      );
    }

    final theme = Theme.of(context);
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Text(
          label,
          style: theme.textTheme.labelLarge,
        ),

        const SizedBox(height: AppSpacing.xs),

        Semantics(
          label: label,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: CupertinoTextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: textInputAction,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              enabled: enabled,
              placeholder: hint,
              padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
            ),
          ),
        ),

        if (error != null) ...[

          const SizedBox(height: AppSpacing.xs),

          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),

        ],

      ],
    );
  }
}
