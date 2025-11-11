import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/catalog_item.dart';
import '../state/providers.dart';

/// Stream provider for catalog items.
final catalogProvider = StreamProvider.family<List<CatalogItem>, String>((ref, query) {
  return ref.watch(catalogRepositoryProvider).watchItems(search: query);
});
