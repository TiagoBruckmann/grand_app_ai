import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/core/widgets/adaptive/adaptive_button.dart';
import 'package:grand_app_ia_challange1/core/widgets/adaptive/adaptive_text_field.dart';
import 'package:grand_app_ia_challange1/core/widgets/max_width_body.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/view_model/echo_text_view_model.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_label.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_keys.dart';
import 'package:provider/provider.dart';

class EchoTextScreen extends StatefulWidget {
  const EchoTextScreen({super.key});

  @override
  State<EchoTextScreen> createState() => _EchoTextScreenState();
}

class _EchoTextScreenState extends State<EchoTextScreen> {
  final _controller = TextEditingController();

  void _submit() {
    final viewModel = context.read<EchoTextViewModel>();
    if (!viewModel.canSubmit) {
      return;
    }

    viewModel.submit();
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final echoedText = context.select<EchoTextViewModel, String?>(
      (viewModel) => viewModel.echoedText,
    );
    final canSubmit = context.select<EchoTextViewModel, bool>(
      (viewModel) => viewModel.canSubmit,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, I18nKeys.echoTextTitle)),
      ),
      body: MaxWidthBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EchoLabel(text: echoedText),

            const SizedBox(height: AppSpacing.lg),

            AdaptiveTextField(
              key: EchoTextKeys.input,
              controller: _controller,
              maxLines: 5,
              label: FlutterI18n.translate(
                context,
                I18nKeys.echoTextInputLabel,
              ),
              hint: FlutterI18n.translate(context, I18nKeys.echoTextInputHint),
              textInputAction: TextInputAction.done,
              onChanged: (value) =>
                  context.read<EchoTextViewModel>().onInputChanged(value),
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: AppSpacing.md),

            AdaptiveButton(
              key: EchoTextKeys.submit,
              label: FlutterI18n.translate(context, I18nKeys.echoTextSubmit),
              icon: Icons.send,
              onPressed: canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
