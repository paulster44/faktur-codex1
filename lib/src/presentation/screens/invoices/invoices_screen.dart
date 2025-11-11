import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/invoice.dart';
import '../../../domain/value_objects/money.dart';
import '../../controllers/invoice_list_controller.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../widgets/search_query_scope.dart';

/// Invoices screen showing workflow states, filters, and balances.
class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  InvoiceStatus? _selectedStatus;
  DateTimeRange? _range;
  int? _clientId;
  String? _currency;

  @override
  Widget build(BuildContext context) {
    final queryListenable = SearchQueryScope.maybeOf(context) ?? ValueNotifier('');
    return Column(
      children: [
        _FiltersBar(
          selectedStatus: _selectedStatus,
          onStatusChanged: (value) => setState(() => _selectedStatus = value),
          onClear: () => setState(() {
            _selectedStatus = null;
            _range = null;
            _clientId = null;
            _currency = null;
          }),
          onDateRangePressed: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 1),
            );
            if (picked != null) {
              setState(() => _range = DateTimeRange(start: picked.start, end: picked.end));
            }
          },
        ),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: queryListenable,
            builder: (context, query, _) {
              final invoices = ref.watch(
                invoiceListProvider(
                  InvoiceFilters(
                    query: query,
                    status: _selectedStatus,
                    range: _range == null
                        ? null
                        : InvoiceDateRange(start: _range!.start, end: _range!.end),
                    clientId: _clientId,
                    currency: _currency,
                  ),
                ),
              );
              return invoices.when(
                data: (data) => _InvoiceList(invoices: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(child: Text('Could not load invoices: $error')),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClear,
    required this.onDateRangePressed,
  });

  final InvoiceStatus? selectedStatus;
  final ValueChanged<InvoiceStatus?> onStatusChanged;
  final VoidCallback onClear;
  final VoidCallback onDateRangePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          DropdownButton<InvoiceStatus?>(
            value: selectedStatus,
            hint: const Text('Status'),
            onChanged: onStatusChanged,
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: InvoiceStatus.draft, child: Text('Draft')),
              DropdownMenuItem(value: InvoiceStatus.sent, child: Text('Sent')),
              DropdownMenuItem(value: InvoiceStatus.partial, child: Text('Partial')),
              DropdownMenuItem(value: InvoiceStatus.paid, child: Text('Paid')),
              DropdownMenuItem(value: InvoiceStatus.voided, child: Text('Void')),
            ],
          ),
          const SizedBox(width: 16),
          FilledButton.tonal(
            onPressed: onDateRangePressed,
            child: const Text('Date range'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({required this.invoices});

  final List<Invoice> invoices;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const Center(child: Text('No invoices recorded yet. Create one to send to clients.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _InvoiceTile(invoice: invoice);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMd();
    final statusColor = _statusColor(invoice.status, Theme.of(context).colorScheme);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.12),
          child: Text(invoice.status.name.substring(0, 1).toUpperCase()),
        ),
        title: Text(invoice.invoiceNumber),
        subtitle: Text('Issued ${formatter.format(invoice.issueDate)} · Due ${formatter.format(invoice.dueDate)}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(invoice.total.format(invoice.currency)),
            const SizedBox(height: 4),
            Text('Balance ${invoice.balanceDue.format(invoice.currency)}', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        onTap: () => _showInvoiceDetails(context, invoice),
      ),
    );
  }

  Color _statusColor(InvoiceStatus status, ColorScheme scheme) {
    switch (status) {
      case InvoiceStatus.draft:
        return scheme.outline;
      case InvoiceStatus.sent:
        return scheme.primary;
      case InvoiceStatus.partial:
        return scheme.tertiary;
      case InvoiceStatus.paid:
        return scheme.secondary;
      case InvoiceStatus.voided:
        return scheme.error;
    }
  }

  void _showInvoiceDetails(BuildContext context, Invoice invoice) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invoice.invoiceNumber, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text('Status: ${invoice.status.name.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Issued: ${invoice.issueDate.toIso8601String()}'),
              Text('Due: ${invoice.dueDate.toIso8601String()}'),
              const Divider(height: 32),
              Text('Line items', style: Theme.of(context).textTheme.titleMedium),
              ...invoice.lines.map(
                (line) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(line.itemName),
                  subtitle: Text(line.itemDescription),
                  trailing: Text(Money(line.lineTotalCents).format(invoice.currency)),
                ),
              ),
              const Divider(height: 32),
              Text('Notes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(invoice.notes.isEmpty ? 'No notes' : invoice.notes),
            ],
          ),
        );
      },
    );
  }
}
