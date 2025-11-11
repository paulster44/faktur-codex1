import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../state/providers.dart';

/// Invoice filter request describing UI filters.
class InvoiceFilters {
  const InvoiceFilters({
    this.query = '',
    this.status,
    this.range,
    this.clientId,
    this.currency,
  });

  final String query;
  final InvoiceStatus? status;
  final InvoiceDateRange? range;
  final int? clientId;
  final String? currency;
}

/// Stream provider exposing invoices with filters applied.
final invoiceListProvider = StreamProvider.family<List<Invoice>, InvoiceFilters>((ref, filters) {
  return ref.watch(invoiceRepositoryProvider).watchInvoices(
        search: filters.query,
        status: filters.status,
        issuedBetween: filters.range,
        clientId: filters.clientId,
        currency: filters.currency,
      );
});
