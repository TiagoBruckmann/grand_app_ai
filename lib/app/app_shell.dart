import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_app_ia_challange1/core/i18n/i18n_keys.dart';
import 'package:grand_app_ia_challange1/core/widgets/adaptive/adaptive_platform.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<(IconData, String)> _destinations = [
    (Icons.text_fields, I18nKeys.navEchoText),
    (Icons.swap_vert, I18nKeys.navIsolateCounter),
  ];

  void _onSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      for (final (icon, labelKey) in _destinations)
        (icon, FlutterI18n.translate(context, labelKey)),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: context.isCupertino
          ? CupertinoTabBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onSelected,
              items: [

                for (final (icon, label) in destinations)
                  BottomNavigationBarItem(icon: Icon(icon), label: label),

              ],
            )
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelected,
              destinations: [

                for (final (icon, label) in destinations)
                  NavigationDestination(icon: Icon(icon), label: label),

              ],
            ),
    );
  }
}
