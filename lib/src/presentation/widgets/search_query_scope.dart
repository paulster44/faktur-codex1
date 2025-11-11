import 'package:flutter/widgets.dart';

/// Provides access to the global search query across the shell.
class SearchQueryScope extends InheritedNotifier<ValueNotifier<String>> {
  const SearchQueryScope({
    required ValueNotifier<String> notifier,
    required Widget child,
    super.key,
  }) : super(notifier: notifier, child: child);

  static ValueNotifier<String>? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SearchQueryScope>()?.notifier;
  }

  static ValueNotifier<String> of(BuildContext context) {
    final notifier = maybeOf(context);
    assert(notifier != null, 'No SearchQueryScope found in context');
    return notifier!;
  }
}
