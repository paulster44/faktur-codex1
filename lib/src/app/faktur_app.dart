import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../presentation/routes/app_router.dart';

/// Root widget for the Faktur application.
class FakturApp extends ConsumerWidget {
  const FakturApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      themeMode: ThemeMode.system,
      theme: FakturTheme.light,
      darkTheme: FakturTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
