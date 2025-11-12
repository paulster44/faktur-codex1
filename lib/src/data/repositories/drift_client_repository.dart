import 'package:drift/drift.dart';
import '../local/faktur_database.dart' as db;
import '../../domain/entities/client.dart' as model;
import '../../domain/repositories/client_repository.dart';

class DriftClientRepository implements ClientRepository {
  final db.FakturDatabase _database;

  DriftClientRepository(this._database);

  @override
  Stream<List<model.Client>> watchClients({String search = ''}) {
    final query = _database.select(_database.clients);
    if (search.isNotEmpty) {
      final like = '%$search%';
      query.where((tbl) => tbl.displayName.like(like) | tbl.companyName.like(like) | tbl.email.like(like));
    }
    return query.watch().map((rows) => rows.map(_mapClient).toList());
  }

  @override
  Future<model.Client?> findById(int id) async {
    final query = _database.select(_database.clients)
      ..where((tbl) => tbl.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null ? _mapClient(row) : null;
  }

  @override
  Future<int> upsert(model.Client client) async {
    final companion = db.ClientsCompanion(
      id: client.id == 0 ? const Value.absent() : Value(client.id),
      displayName: Value(client.displayName),
      companyName: Value(client.companyName),
      email: Value(client.email),
      phone: Value(client.phone),
      street: Value(client.street),
      city: Value(client.city),
      region: Value(client.region),
      postalCode: Value(client.postalCode),
      country: Value(client.country),
      defaultCurrency: Value(client.defaultCurrency),
      notes: Value(client.notes),
      createdAt: client.id == 0 ? Value(DateTime.now()) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
    return await _database.into(_database.clients).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> delete(int id) async {
    await (_database.delete(_database.clients)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ---- MAPPER ----
  model.Client _mapClient(db.Client row) {
    return model.Client(
      id: row.id,
      displayName: row.displayName,
      companyName: row.companyName,
      email: row.email,
      phone: row.phone,
      street: row.street,
      city: row.city,
      region: row.region,
      postalCode: row.postalCode,
      country: row.country,
      defaultCurrency: row.defaultCurrency,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}