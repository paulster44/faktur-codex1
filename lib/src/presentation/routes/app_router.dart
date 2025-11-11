import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/invoices/invoices_screen.dart';
import '../screens/items/items_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/adaptive_navigation_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveNavigationShell(
            currentLocation: state.fullPath ?? '',
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/clients',
            name: 'clients',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClientsScreen(),
            ),
          ),
          GoRoute(
            path: '/invoices',
            name: 'invoices',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InvoicesScreen(),
            ),
          ),
          GoRoute(
            path: '/items',
            name: 'items',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ItemsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return '/dashboard';
      }
      return null;
    },
  );
});

/// Helper describing navigation destinations for the adaptive shell.
class FakturDestination {
  const FakturDestination({
    required this.path,
    required this.icon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final String label;
}

/// Visible navigation destinations.
const destinations = [
  FakturDestination(path: '/dashboard', icon: Icons.space_dashboard_outlined, label: AppStrings.dashboard),
  FakturDestination(path: '/clients', icon: Icons.people_alt_outlined, label: AppStrings.clients),
  FakturDestination(path: '/invoices', icon: Icons.receipt_long_outlined, label: AppStrings.invoices),
  FakturDestination(path: '/items', icon: Icons.inventory_2_outlined, label: AppStrings.items),
  FakturDestination(path: '/settings', icon: Icons.tune_outlined, label: AppStrings.settings),
];
