import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../routes/app_router.dart';
import 'search_field.dart';
import 'search_query_scope.dart';

/// Adaptive shell that renders navigation rail on macOS and bottom bar on iOS.
class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({
    required this.child,
    required this.currentLocation,
    super.key,
  });

  final Widget child;
  final String currentLocation;

  @override
  State<AdaptiveNavigationShell> createState() => _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  final ValueNotifier<String> _query = ValueNotifier('');

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  int get _selectedIndex {
    final index = destinations.indexWhere((element) => widget.currentLocation.startsWith(element.path));
    return index < 0 ? 0 : index;
  }

  void _onDestinationSelected(int index) {
    if (index < 0 || index >= destinations.length) {
      return;
    }
    final destination = destinations[index];
    if (!mounted) return;
    context.go(destination.path);
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isMac = platform == TargetPlatform.macOS;
    final navigationItems = destinations
        .map(
          (destination) => NavigationDestination(
            icon: Icon(destination.icon),
            label: destination.label,
          ),
        )
        .toList();

    if (isMac) {
      return SearchQueryScope(
        notifier: _query,
        child: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onDestinationSelected,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _NavigationHeader(query: _query),
                ),
                destinations: destinations
                    .map(
                      (destination) => NavigationRailDestination(
                        icon: Icon(destination.icon),
                        label: Text(destination.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: widget.child),
            ],
          ),
        ),
      );
    }

    return SearchQueryScope(
      notifier: _query,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 220,
                child: SearchField(queryListenable: _query),
              ),
            ),
          ],
        ),
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          destinations: navigationItems,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
        ),
      ),
    );
  }
}

class _NavigationHeader extends StatelessWidget {
  const _NavigationHeader({required this.query});

  final ValueNotifier<String> query;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AppStrings.appName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: SearchField(queryListenable: query),
        ),
      ],
    );
  }
}
