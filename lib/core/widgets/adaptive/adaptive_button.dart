import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/core/widgets/adaptive/adaptive_platform.dart';

enum AdaptiveButtonStyle { filled, tonal }

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AdaptiveButtonStyle.filled,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AdaptiveButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final content = _ButtonContent(label: label, icon: icon);

    if (context.isCupertino) {
      const minSize = Size.square(AppSizes.minTouchTarget);
      return switch (style) {
        AdaptiveButtonStyle.filled => CupertinoButton.filled(
          onPressed: onPressed,
          minimumSize: minSize,
          child: content,
        ),
        AdaptiveButtonStyle.tonal => CupertinoButton.tinted(
          onPressed: onPressed,
          minimumSize: minSize,
          child: content,
        ),
      };
    }

    const buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, AppSizes.minTouchTarget)),
    );

    return switch (style) {
      AdaptiveButtonStyle.filled => FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: content,
      ),
      AdaptiveButtonStyle.tonal => FilledButton.tonal(
        onPressed: onPressed,
        style: buttonStyle,
        child: content,
      ),
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, required this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    final icon = this.icon;
    if (icon == null) {
      return text;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),

        const SizedBox(width: AppSpacing.sm),

        Flexible(child: text),
      ],
    );
  }
}
