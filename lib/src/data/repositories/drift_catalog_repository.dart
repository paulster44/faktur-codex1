import 'package:drift/drift.dart';

import '../../domain/entities/catalog_item.dart' as model;
import '../../domain/repositories/catalog_repository.dart';
import '../local/faktur_database.dart' as db;

/// Drift repository for catalog items.
class DriftCatalogRepository implements CatalogRepository {
  DriftCatalogRepository(this._database);

  final db.FakturDatabase _database;

  @override
  Future<void> delete(int id) {
    return (_database.delete(_database.itemsCatalog)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<int> upsert(model.CatalogItem item) {
    final companion = db.ItemsCatalogCompanion(
      id: item.id == 0 ? const Value.absent() : Value(item.id),
      name: Value(item.name),
      description: Value(item.description),
      unitPrice: Value(item.unitPriceCents),
      defaultTaxCategoryId: Value(item.defaultTaxCategoryId),
    );
    return _database.into(_database.itemsCatalog).insertOnConflictUpdate(companion);
  }

  @override
  Stream<List<model.CatalogItem>> watchItems({String search = ''}) {
    final query = _database.select(_database.itemsCatalog)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    if (search.isNotEmpty) {
      final like = '%$search%';
      query.where((tbl) => tbl.name.like(like) | tbl.description.like(like));
    }
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => model.CatalogItem(
                  id: row.id,
                  name: row.name,
                  description: row.description,
                  unitPriceCents: row.unitPrice,
                  defaultTaxCategoryId: row.defaultTaxCategoryId,
                ),
              )
              .toList(),
        );
  }
}
