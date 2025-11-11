import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../state/providers.dart';

/// Stream provider exposing the list of clients filtered by search query.
final clientListProvider = StreamProvider.family<List<Client>, String>((ref, query) {
  return ref.watch(clientRepositoryProvider).watchClients(search: query);
});
