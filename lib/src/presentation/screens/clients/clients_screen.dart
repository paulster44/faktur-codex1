import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/client.dart';
import '../../controllers/client_list_controller.dart';
import '../../widgets/search_query_scope.dart';

/// Clients management screen with list and quick details panel.
class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryListenable = SearchQueryScope.maybeOf(context) ?? ValueNotifier('');
    return ValueListenableBuilder<String>(
      valueListenable: queryListenable,
      builder: (context, query, _) {
        final clients = ref.watch(clientListProvider(query));
        return clients.when(
          data: (data) => _ClientsList(clients: data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Could not load clients: $error')),
        );
      },
    );
  }
}

class _ClientsList extends StatelessWidget {
  const _ClientsList({required this.clients});

  final List<Client> clients;

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return const Center(child: Text('No clients yet. Create one to get started.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(client.displayName.characters.first.toUpperCase())),
            title: Text(client.displayName),
            subtitle: Text(client.email),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(client.companyName, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(client.defaultCurrency, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                builder: (context) => _ClientDetails(client: client),
              );
            },
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _ClientDetails extends StatelessWidget {
  const _ClientDetails({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(client.displayName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(client.companyName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18),
              const SizedBox(width: 8),
              Text(client.email),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.call_outlined, size: 18),
              const SizedBox(width: 8),
              Text(client.phone),
            ],
          ),
          const Divider(height: 32),
          Text('${client.street}\n${client.city}, ${client.region} ${client.postalCode}\n${client.country}'),
          const SizedBox(height: 16),
          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(client.notes.isEmpty ? 'No notes added.' : client.notes),
        ],
      ),
    );
  }
}
