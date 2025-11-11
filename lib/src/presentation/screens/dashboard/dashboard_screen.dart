import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/value_objects/money.dart';
import '../../controllers/dashboard_controller.dart';

/// Dashboard presenting financial insights at a glance.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    return metrics.when(
      data: (data) => LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 3 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 160,
                  ),
                  delegate: SliverChildListDelegate([
                    _MetricCard(
                      title: 'Outstanding',
                      description: 'Open balance across all invoices.',
                      amount: data.outstanding,
                      color: Colors.indigo,
                    ),
                    _MetricCard(
                      title: 'Overdue',
                      description: 'Past due balance requiring attention.',
                      amount: data.overdue,
                      color: Colors.deepOrange,
                    ),
                    _MetricCard(
                      title: 'Paid (30 days)',
                      description: 'Payments received in the last month.',
                      amount: data.paidLast30,
                      color: Colors.teal,
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: _TopClientsSection(topClients: data.topClients),
                ),
              ),
            ],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Failed to load dashboard: $error')),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.description,
    required this.amount,
    required this.color,
  });

  final String title;
  final String description;
  final Money amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                amount.format(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopClientsSection extends StatelessWidget {
  const _TopClientsSection({required this.topClients});

  final List<TopClient> topClients;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Clients', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (topClients.isEmpty)
              const Text('No invoices yet. Add your first invoice to see insights.')
            else
              Column(
                children: topClients
                    .map(
                      (client) => ListTile(
                        leading: CircleAvatar(child: Text(client.clientId.toString())),
                        title: Text('Client #${client.clientId}'),
                        subtitle: const Text('Revenue to date'),
                        trailing: Text(client.total.format()),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
