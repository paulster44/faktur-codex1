import 'package:drift/drift.dart';

import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/value_objects/money.dart';
import '../local/faktur_database.dart';

/// Drift repository dedicated to payments.
class DriftPaymentRepository implements PaymentRepository {
  DriftPaymentRepository(this._database);

  final FakturDatabase _database;

  @override
  Future<void> delete(int id) {
    return (_database.delete(_database.payments)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<int> insert(Payment payment) {
    final companion = PaymentsCompanion.insert(
      invoiceId: Value(payment.invoiceId),
      amount: Value(payment.amount.cents),
      date: Value(payment.date),
      method: Value(payment.method),
      notes: Value(payment.notes),
      createdAt: Value(payment.createdAt),
    );
    return _database.into(_database.payments).insert(companion);
  }

  @override
  Stream<List<Payment>> watchByInvoice(int invoiceId) {
    final query = _database.select(_database.payments)
      ..where((tbl) => tbl.invoiceId.equals(invoiceId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => Payment(
                  id: row.id,
                  invoiceId: row.invoiceId,
                  amount: Money(row.amount),
                  date: row.date,
                  method: row.method,
                  notes: row.notes,
                  createdAt: row.createdAt,
                ),
              )
              .toList(),
        );
  }
}
