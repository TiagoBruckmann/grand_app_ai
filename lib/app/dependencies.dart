import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/counter_coordinator.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/data/services/isolate_counter_coordinator.dart';
import 'package:provider/provider.dart';

class AppDependencies extends StatelessWidget {
  const AppDependencies({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CounterCoordinator>(
          create: (_) => IsolateCounterCoordinator(),
          dispose: (_, coordinator) => unawaited(coordinator.dispose()),
        ),
      ],
      child: child,
    );
  }
}
