import 'package:drift/drift.dart';
import '../local/faktur_database.dart' as db;
import 'package:faktur/src/domain/entities/client.dart' as model;

class DriftClientRepository {
  final db.FakturDatabase _database;

  DriftClientRepository(this._database);

  // ---- CREATE ----
  Future<int> create(model.Client client) async {
    final companion = db.ClientsCompanion(
      name: db.Value(client.name),
      email: db.Value(client.email),
      phone: db.Value(client.phone),
      address: db.Value(client.address),
      notes: db.Value(client.notes),
      createdAt: db.Value(client.createdAt ?? DateTime.now()),
      updatedAt: db.Value(client.updatedAt ?? DateTime.now()),
    );
    return await _database.into(_database.clients).insert(companion);
  }

  // ---- READ ----
  Future<List<model.Client>> getAll() async {
    final rows = await _database.select(_database.clients).get();
    return rows.map(_mapClient).toList();
  }

  Future<model.Client?> getById(int id) async {
    final query = _database.select(_database.clients)
      ..where((tbl) => tbl.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null ? _mapClient(row) : null;
  }

  // ---- UPDATE ----
  Future<bool> updateClient(model.Client client) async {
    final companion = db.ClientsCompanion(
      id: db.Value(client.id!),
      name: db.Value(client.name),
      email: db.Value(client.email),
      phone: db.Value(client.phone),
      address: db.Value(client.address),
      notes: db.Value(client.notes),
      updatedAt: db.Value(DateTime.now()),
    );
    final result = await _database.update(_database.clients).replace(companion);
    return result;
  }

  // ---- DELETE ----
  Future<int> deleteClient(int id) async {
    return await (_database.delete(_database.clients)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // ---- MAPPER ----
  model.Client _mapClient(db.Client row) {
    return model.Client(
      id: row.id,
      name: row.name,
      email: row.email,
      phone: row.phone,
      address: row.address,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}