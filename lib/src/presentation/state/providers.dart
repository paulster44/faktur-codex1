import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/faktur_database.dart';
import '../../data/repositories/drift_catalog_repository.dart';
import '../../data/repositories/drift_client_repository.dart';
import '../../data/repositories/drift_invoice_repository.dart';
import '../../data/repositories/drift_payment_repository.dart';
import '../../data/repositories/drift_preference_repository.dart';
import '../../data/repositories/drift_tax_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/preference_repository.dart';
import '../../domain/repositories/tax_category_repository.dart';
import '../../domain/usecases/calculate_invoice_totals.dart';

/// Database provider used across repositories.
final databaseProvider = Provider<FakturDatabase>((ref) {
  final database = FakturDatabase();
  ref.onDispose(database.close);
  return database;
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return DriftClientRepository(ref.watch(databaseProvider));
});

final taxRepositoryProvider = Provider<TaxCategoryRepository>((ref) {
  return DriftTaxCategoryRepository(ref.watch(databaseProvider));
});

final taxCategoriesStreamProvider = StreamProvider((ref) {
  return ref.watch(taxRepositoryProvider).watchAll();
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return DriftCatalogRepository(ref.watch(databaseProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return DriftInvoiceRepository(ref.watch(databaseProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return DriftPaymentRepository(ref.watch(databaseProvider));
});

final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  return DriftPreferenceRepository(ref.watch(databaseProvider));
});

final invoiceCalculatorProvider = Provider<InvoiceCalculator>((ref) {
  final categories = ref.watch(taxCategoriesStreamProvider).maybeWhen(
        data: (data) => data,
        orElse: () => const [],
      );
  return InvoiceCalculator(taxCategories: categories);
});
