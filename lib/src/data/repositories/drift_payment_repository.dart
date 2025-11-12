import 'package:drift/drift.dart';
import '../local/faktur_database.dart' as db;
import 'package:faktur/src/domain/entities/payment.dart' as model;
import 'package:faktur/src/domain/value_objects/money.dart' as vo;

class DriftPaymentRepository {
  final db.FakturDatabase _database;

  DriftPaymentRepository(this._database);

  // ---- CREATE ----
  Future<int> create(model.Payment payment) async {
    final companion = db.PaymentsCompanion(
      invoiceId: db.Value(payment.invoiceId),
      amount: db.Value(payment.amount.cents),
      date: db.Value(payment.date),
      method: db.Value(payment.method),
      // createdAt/updatedAt if your table has them:
      // createdAt: db.Value(payment.createdAt ?? DateTime.now()),
      // updatedAt: db.Value(payment.updatedAt ?? DateTime.now()),
    );
    return await _database.into(_database.payments).insert(companion);
  }

  // ---- READ ----
  Future<List<model.Payment>> getByInvoiceId(int invoiceId) async {
    final query = _database.select(_database.payments)
      ..where((t) => t.invoiceId.equals(invoiceId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  Future<List<model.Payment>> getAll() async {
    final rows = await _database.select(_database.payments).get();
    return rows.map(_mapRow).toList();
  }

  Future<model.Payment?> getById(int id) async {
    final row = await (_database.select(_database.payments)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  // ---- UPDATE ----
  Future<bool> updatePayment(model.Payment payment) async {
    if (payment.id == null) return false;
    final companion = db.PaymentsCompanion(
      id: db.Value(payment.id!),
      invoiceId: db.Value(payment.invoiceId),
      amount: db.Value(payment.amount.cents),
      date: db.Value(payment.date),
      method: db.Value(payment.method),
      // updatedAt: db.Value(DateTime.now()),
    );
    return await _database.update(_database.payments).replace(companion);
  }

  // ---- DELETE ----
  Future<int> deletePayment(int id) async {
    return await (_database.delete(_database.payments)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ---- MAPPER ----
  model.Payment _mapRow(db.Payment row) {
    return model.Payment(
      id: row.id,
      invoiceId: row.invoiceId,
      amount: vo.Money.cents(row.amount),
      date: row.date,
      method: row.method,
      // createdAt: row.createdAt,
      // updatedAt: row.updatedAt,
    );
  }
}