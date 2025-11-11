import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/catalog_item.dart';
import '../../controllers/catalog_controller.dart';
import '../../widgets/search_query_scope.dart';

/// Catalog screen showing reusable services or products.
class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryListenable = SearchQueryScope.maybeOf(context) ?? ValueNotifier('');
    return ValueListenableBuilder<String>(
      valueListenable: queryListenable,
      builder: (context, query, _) {
        final items = ref.watch(catalogProvider(query));
        return items.when(
          data: (data) => _CatalogList(items: data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Could not load catalog: $error')),
        );
      },
    );
  }
}

class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.items});

  final List<CatalogItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No catalog entries yet. Add your frequently billed work.'));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 900
            ? 3
            : width > 600
                ? 2
                : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 2.0 : 1.4,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        item.description.isEmpty ? 'No description provided.' : item.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Unit price: ${(item.unitPriceCents / 100).toStringAsFixed(2)}'),
                    if (item.defaultTaxCategoryId != null)
                      Text('Tax category #${item.defaultTaxCategoryId}', style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
