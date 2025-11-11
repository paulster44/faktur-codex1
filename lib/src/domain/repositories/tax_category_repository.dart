import '../entities/tax_category.dart';

/// Repository contract for tax categories.
abstract class TaxCategoryRepository {
  Stream<List<TaxCategory>> watchAll();
  Future<int> upsert(TaxCategory taxCategory);
  Future<void> delete(int id);
}
