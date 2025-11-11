import '../entities/catalog_item.dart';

/// Repository contract for catalog items.
abstract class CatalogRepository {
  Stream<List<CatalogItem>> watchItems({String search = ''});
  Future<int> upsert(CatalogItem item);
  Future<void> delete(int id);
}
