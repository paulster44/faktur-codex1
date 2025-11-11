import 'package:drift/drift.dart';

import '../../domain/entities/tax_category.dart';
import '../../domain/repositories/tax_category_repository.dart';
import '../local/faktur_database.dart';

/// Drift repository for tax categories.
class DriftTaxCategoryRepository implements TaxCategoryRepository {
  DriftTaxCategoryRepository(this._database);

  final FakturDatabase _database;

  @override
  Future<void> delete(int id) {
    return (_database.delete(_database.taxCategories)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<int> upsert(TaxCategory taxCategory) {
    final companion = TaxCategoriesCompanion(
      id: taxCategory.id == 0 ? const Value.absent() : Value(taxCategory.id),
      name: Value(taxCategory.name),
      ratePercent: Value(taxCategory.ratePercent),
      isCompound: Value(taxCategory.isCompound),
    );
    return _database.into(_database.taxCategories).insertOnConflictUpdate(companion);
  }

  @override
  Stream<List<TaxCategory>> watchAll() {
    return _database.select(_database.taxCategories).watch().map(
          (rows) => rows
              .map(
                (row) => TaxCategory(
                  id: row.id,
                  name: row.name,
                  ratePercent: row.ratePercent,
                  isCompound: row.isCompound,
                ),
              )
              .toList(),
        );
  }
}
