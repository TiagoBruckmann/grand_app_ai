import 'package:go_router/go_router.dart';
import 'package:grand_app_ia_challange1/app/app_shell.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/view_model/echo_text_view_model.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/widgets/echo_text_screen.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/view_model/isolate_counter_view_model.dart';
import 'package:grand_app_ia_challange1/features/isolate_counter/ui/widgets/isolate_counter_screen.dart';
import 'package:provider/provider.dart';

abstract final class AppRoutes {
  static const String echoText = '/echo-text';
  static const String isolateCounter = '/isolate-counter';
}

GoRouter createRouter() => GoRouter(
  initialLocation: AppRoutes.echoText,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.echoText,
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => EchoTextViewModel(),
                child: const EchoTextScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.isolateCounter,
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) =>
                    IsolateCounterViewModel(coordinator: context.read()),
                child: const IsolateCounterScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
