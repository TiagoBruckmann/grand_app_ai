import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/theme/tokens.dart';
import 'package:grand_app_ia_challange1/core/widgets/max_width_body.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/counter_controls.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/counter_display.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/interval_slider.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/limit_field.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/status_text.dart';

class IsolateCounterScreen extends StatelessWidget {
  const IsolateCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, I18nKeys.isolateCounterTitle),
        ),
      ),
      body: const MaxWidthBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            CounterDisplay(),

            SizedBox(height: AppSpacing.md),

            StatusText(),

            SizedBox(height: AppSpacing.lg),

            CounterControls(),

            SizedBox(height: AppSpacing.lg),

            IntervalSlider(),

            SizedBox(height: AppSpacing.md),

            LimitField(),

          ],
        ),
      ),
    );
  }
}
