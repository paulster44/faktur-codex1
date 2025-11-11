import 'package:flutter/foundation.dart';

import '../../data/services/service_registry.dart';

/// Initializes platform specific services before the application launches.
Future<void> bootstrapCoreServices() async {
  // Register platform abstractions for secure storage, sharing, and paths.
  await ServiceRegistry.instance.initialize();

  if (kDebugMode) {
    debugPrint('Faktur services initialized');
  }
}
