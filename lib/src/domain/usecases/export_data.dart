import 'dart:convert';

import '../entities/catalog_item.dart';
import '../entities/client.dart';
import '../entities/invoice.dart';
import '../entities/invoice_line.dart';
import '../entities/payment.dart';

/// Aggregate result containing export payloads.
class ExportBundle {
  const ExportBundle({
    required this.json,
    required this.clientsCsv,
    required this.itemsCsv,
    required this.invoicesCsv,
  });

  final String json;
  final String clientsCsv;
  final String itemsCsv;
  final String invoicesCsv;
}

/// Builds JSON and CSV exports based on provided data snapshots.
class ExportData {
  ExportBundle call({
    required List<Client> clients,
    required List<Invoice> invoices,
    required List<CatalogItem> items,
  }) {
    final jsonPayload = _buildJson(clients: clients, invoices: invoices, items: items);
    final clientsCsv = _toCsv(
      headers: const [
        'displayName',
        'companyName',
        'email',
        'phone',
        'street',
        'city',
        'region',
        'postalCode',
        'country',
        'defaultCurrency',
        'notes',
      ],
      rows: clients.map((client) => [
            client.displayName,
            client.companyName,
            client.email,
            client.phone,
            client.street,
            client.city,
            client.region,
            client.postalCode,
            client.country,
            client.defaultCurrency,
            client.notes,
          ]),
    );

    final itemsCsv = _toCsv(
      headers: const ['name', 'description', 'unitPriceCents', 'defaultTaxCategoryId'],
      rows: items.map(
        (item) => [
          item.name,
          item.description,
          item.unitPriceCents,
          item.defaultTaxCategoryId ?? '',
        ],
      ),
    );

    final invoicesCsv = _toCsv(
      headers: const [
        'invoiceNumber',
        'clientId',
        'issueDate',
        'dueDate',
        'currency',
        'status',
        'subtotalCents',
        'taxCents',
        'discountCents',
        'totalCents',
        'balanceDueCents',
      ],
      rows: invoices.map((invoice) => [
            invoice.invoiceNumber,
            invoice.clientId,
            invoice.issueDate.toIso8601String(),
            invoice.dueDate.toIso8601String(),
            invoice.currency,
            invoice.status.name,
            invoice.subtotal.cents,
            invoice.taxTotal.cents,
            invoice.discountTotal.cents,
            invoice.total.cents,
            invoice.balanceDue.cents,
          ]),
    );

    return ExportBundle(
      json: jsonPayload,
      clientsCsv: clientsCsv,
      itemsCsv: itemsCsv,
      invoicesCsv: invoicesCsv,
    );
  }

  String _buildJson({
    required List<Client> clients,
    required List<Invoice> invoices,
    required List<CatalogItem> items,
  }) {
    final payload = <String, dynamic>{
      'generatedAt': DateTime.now().toIso8601String(),
      'clients': clients
          .map(
            (client) => {
              'id': client.id,
              'displayName': client.displayName,
              'companyName': client.companyName,
              'email': client.email,
              'phone': client.phone,
              'street': client.street,
              'city': client.city,
              'region': client.region,
              'postalCode': client.postalCode,
              'country': client.country,
              'defaultCurrency': client.defaultCurrency,
              'notes': client.notes,
              'createdAt': client.createdAt.toIso8601String(),
              'updatedAt': client.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'items': items
          .map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'description': item.description,
              'unitPrice': item.unitPriceCents,
              'defaultTaxCategoryId': item.defaultTaxCategoryId,
            },
          )
          .toList(),
      'invoices': invoices
          .map((invoice) => {
                'id': invoice.id,
                'invoiceNumber': invoice.invoiceNumber,
                'clientId': invoice.clientId,
                'issueDate': invoice.issueDate.toIso8601String(),
                'dueDate': invoice.dueDate.toIso8601String(),
                'currency': invoice.currency,
                'status': invoice.status.name,
                'notes': invoice.notes,
                'terms': invoice.terms,
                'subtotal': invoice.subtotal.cents,
                'taxTotal': invoice.taxTotal.cents,
                'discountTotal': invoice.discountTotal.cents,
                'total': invoice.total.cents,
                'balanceDue': invoice.balanceDue.cents,
                'createdAt': invoice.createdAt.toIso8601String(),
                'updatedAt': invoice.updatedAt.toIso8601String(),
                'lines': invoice.lines
                    .map((line) => {
                          'itemName': line.itemName,
                          'itemDescription': line.itemDescription,
                          'quantity': line.quantity,
                          'unitPrice': line.unitPriceCents,
                          'discountPercent': line.discountPercent,
                          'taxCategoryId': line.taxCategoryId,
                          'lineSubtotal': line.lineSubtotalCents,
                          'lineTax': line.lineTaxCents,
                          'lineTotal': line.lineTotalCents,
                        })
                    .toList(),
                'payments': invoice.payments
                    .map((payment) => {
                          'amount': payment.amount.cents,
                          'date': payment.date.toIso8601String(),
                          'method': payment.method,
                          'notes': payment.notes,
                          'createdAt': payment.createdAt.toIso8601String(),
                        })
                    .toList(),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  String _toCsv({required List<String> headers, required Iterable<List<Object?>> rows}) {
    final buffer = StringBuffer(headers.join(','))..writeln();
    for (final row in rows) {
      buffer.writeln(row.map((cell) => '"${cell ?? ''}"').join(','));
    }
    return buffer.toString();
  }
}
