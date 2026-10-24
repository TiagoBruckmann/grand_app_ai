import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/widgets/adaptive/adaptive_text_field.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_keys.dart';
import 'package:provider/provider.dart';

class LimitField extends StatefulWidget {
  const LimitField({super.key});

  @override
  State<LimitField> createState() => _LimitFieldState();
}

class _LimitFieldState extends State<LimitField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<IsolateCounterViewModel>().limitInput,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (
      :enabled,
      :isValid,
    ) = context.select<IsolateCounterViewModel, ({bool enabled, bool isValid})>(
      (viewModel) =>
          (enabled: viewModel.canEditLimit, isValid: viewModel.isLimitValid),
    );

    return AdaptiveTextField(
      key: IsolateCounterKeys.limitInput,
      controller: _controller,
      enabled: enabled,
      label: FlutterI18n.translate(context, I18nKeys.isolateCounterLimitLabel),
      errorText: isValid
          ? null
          : FlutterI18n.translate(
              context,
              I18nKeys.isolateCounterLimitError,
              translationParams: {
                I18nParams.min: '${IsolateCounterViewModel.minLimit}',
                I18nParams.max: '${IsolateCounterViewModel.maxLimit}',
              },
            ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) =>
          context.read<IsolateCounterViewModel>().onLimitChanged(value),
    );
  }
}
