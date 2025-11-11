import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/business_profile.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/value_objects/money.dart';

/// Generates invoice PDFs with an original layout tailored for Faktur.
class InvoicePdfRenderer {
  Future<Uint8List> render({
    required Invoice invoice,
    required BusinessProfile profile,
  }) async {
    final pdf = pw.Document();
    final formatter = DateFormat.yMMMMd();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(),
        ),
        build: (context) {
          return [
            _buildHeader(invoice, profile),
            pw.SizedBox(height: 24),
            _buildSummary(invoice, formatter),
            pw.SizedBox(height: 16),
            _buildLineItems(invoice),
            pw.SizedBox(height: 16),
            _buildTotals(invoice),
            pw.SizedBox(height: 24),
            _buildFooter(invoice),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Invoice invoice, BusinessProfile profile) {
    final accent = PdfColor.fromInt(profile.accentColor);
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: accent, width: 2),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(profile.name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: accent)),
              pw.Text(profile.email),
              pw.Text(profile.phone),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text(invoice.invoiceNumber),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(Invoice invoice, DateFormat formatter) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Issued: ${formatter.format(invoice.issueDate)}'),
            pw.Text('Due: ${formatter.format(invoice.dueDate)}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Status: ${invoice.status.name.toUpperCase()}'),
            pw.Text('Client ID: ${invoice.clientId}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildLineItems(Invoice invoice) {
    final headers = ['Item', 'Description', 'Qty', 'Unit Price', 'Tax', 'Total'];
    final data = invoice.lines
        .map(
          (line) => [
            line.itemName,
            line.itemDescription,
            line.quantity.toStringAsFixed(2),
            _formatCurrency(Money(line.unitPriceCents), invoice.currency),
            _formatCurrency(Money(line.lineTaxCents), invoice.currency),
            _formatCurrency(Money(line.lineTotalCents), invoice.currency),
          ],
        )
        .toList();
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      border: null,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    );
  }

  pw.Widget _buildTotals(Invoice invoice) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 260,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _totalRow('Subtotal', invoice.subtotal, invoice.currency),
            _totalRow('Tax', invoice.taxTotal, invoice.currency),
            _totalRow('Discount', invoice.discountTotal, invoice.currency),
            const pw.Divider(),
            _totalRow('Total', invoice.total, invoice.currency, emphasize: true),
            _totalRow('Balance due', invoice.balanceDue, invoice.currency, emphasize: true),
          ],
        ),
      ),
    );
  }

  pw.Widget _totalRow(String label, Money amount, String currency, {bool emphasize = false}) {
    final style = emphasize
        ? pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)
        : const pw.TextStyle(fontSize: 12);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(_formatCurrency(amount, currency), style: style),
      ],
    );
  }

  pw.Widget _buildFooter(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Notes'),
        pw.Text(invoice.notes.isEmpty ? 'No additional notes provided.' : invoice.notes),
        pw.SizedBox(height: 12),
        pw.Text('Terms'),
        pw.Text(invoice.terms.isEmpty ? 'Payment due within 30 days.' : invoice.terms),
      ],
    );
  }

  String _formatCurrency(Money amount, String currency) {
    final format = NumberFormat.simpleCurrency(name: currency);
    return format.format(amount.decimal);
  }
}
