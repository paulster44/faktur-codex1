import 'package:drift/drift.dart';
import '../local/faktur_database.dart' as db;
import '../../domain/entities/payment.dart' as model;
import '../../domain/repositories/payment_repository.dart';
import '../../domain/value_objects/money.dart';

class DriftPaymentRepository implements PaymentRepository {
  final db.FakturDatabase _database;

  DriftPaymentRepository(this._database);

  @override
  Future<int> insert(model.Payment payment) async {
    final companion = db.PaymentsCompanion(
      invoiceId: Value(payment.invoiceId),
      amount: Value(payment.amount.cents),
      date: Value(payment.date),
      method: Value(payment.method),
      notes: Value(payment.notes),
      createdAt: Value(payment.createdAt),
    );
    return await _database.into(_database.payments).insert(companion);
  }

  @override
  Stream<List<model.Payment>> watchByInvoice(int invoiceId) {
    final query = _database.select(_database.payments)
      ..where((t) => t.invoiceId.equals(invoiceId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<void> delete(int id) async {
    await (_database.delete(_database.payments)..where((t) => t.id.equals(id))).go();
  }

  // ---- MAPPER ----
  model.Payment _mapRow(db.Payment row) {
    return model.Payment(
      id: row.id,
      invoiceId: row.invoiceId,
      amount: Money(row.amount),
      date: row.date,
      method: row.method,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }
}