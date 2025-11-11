import 'package:drift/drift.dart';

import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../local/faktur_database.dart';

/// Drift implementation for [ClientRepository].
class DriftClientRepository implements ClientRepository {
  DriftClientRepository(this._database);

  final FakturDatabase _database;

  @override
  Future<void> delete(int id) {
    return (_database.delete(_database.clients)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<Client?> findById(int id) async {
    final row = await (_database.select(_database.clients)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapClient(row);
  }

  @override
  Stream<List<Client>> watchClients({String search = ''}) {
    final query = _database.select(_database.clients)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.displayName)]);
    if (search.isNotEmpty) {
      final like = '%$search%';
      query.where((tbl) => tbl.displayName.like(like) | tbl.companyName.like(like));
    }
    return query.watch().map((rows) => rows.map(_mapClient).toList());
  }

  @override
  Future<int> upsert(Client client) async {
    final companion = ClientsCompanion(
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
      createdAt: Value(client.createdAt),
      updatedAt: Value(client.updatedAt),
    );

    return _database.into(_database.clients).insertOnConflictUpdate(companion);
  }

  Client _mapClient(ClientsData row) {
    return Client(
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
