import '../entities/client.dart';

/// Repository contract for clients.
abstract class ClientRepository {
  Stream<List<Client>> watchClients({String search = ''});
  Future<Client?> findById(int id);
  Future<int> upsert(Client client);
  Future<void> delete(int id);
}
