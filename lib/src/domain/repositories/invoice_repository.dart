import '../entities/invoice.dart';

/// Repository contract for invoices.
abstract class InvoiceRepository {
  Stream<List<Invoice>> watchInvoices({
    String search = '',
    InvoiceStatus? status,
    InvoiceDateRange? issuedBetween,
    int? clientId,
    String? currency,
  });

  Future<Invoice?> findById(int id);
  Future<int> upsert(Invoice invoice);
  Future<void> delete(int id);
  Future<String> nextInvoiceNumber(DateTime date);
}

/// Date range used for filtering invoices.
class InvoiceDateRange {
  const InvoiceDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
