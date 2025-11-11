import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/value_objects/money.dart';
import '../state/providers.dart';

/// Dashboard metrics derived from invoices.
class DashboardMetrics {
  const DashboardMetrics({
    required this.outstanding,
    required this.overdue,
    required this.paidLast30,
    required this.topClients,
  });

  final Money outstanding;
  final Money overdue;
  final Money paidLast30;
  final List<TopClient> topClients;
}

/// Top client summary by revenue.
class TopClient {
  const TopClient({required this.clientId, required this.total});

  final int clientId;
  final Money total;
}

/// Stream provider emitting dashboard metrics.
final dashboardMetricsProvider = StreamProvider<DashboardMetrics>((ref) {
  return ref.watch(invoiceRepositoryProvider).watchInvoices().map((invoices) {
    Money outstanding = Money.zero();
    Money overdue = Money.zero();
    Money paidLast30 = Money.zero();
    final clientTotals = <int, Money>{};
    final now = DateTime.now();
    for (final invoice in invoices) {
      outstanding += invoice.balanceDue;
      if (invoice.isOverdue) {
        overdue += invoice.balanceDue;
      }
      for (final payment in invoice.payments) {
        if (now.difference(payment.date).inDays <= 30) {
          paidLast30 += payment.amount;
        }
      }
      clientTotals.update(
        invoice.clientId,
        (value) => value + invoice.total,
        ifAbsent: () => invoice.total,
      );
    }
    final topClients = clientTotals.entries
        .toList()
        ..sort((a, b) => b.value.cents.compareTo(a.value.cents));
    final top = topClients.take(5).map((entry) => TopClient(clientId: entry.key, total: entry.value)).toList();
    return DashboardMetrics(
      outstanding: outstanding,
      overdue: overdue,
      paidLast30: paidLast30,
      topClients: top,
    );
  });
});
