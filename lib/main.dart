import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/faktur_app.dart';
import 'src/core/platform/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapCoreServices();

  runApp(
    const ProviderScope(
      child: FakturApp(),
    ),
  );
}
