import 'package:flutter_test/flutter_test.dart';

import 'package:faktur/src/domain/entities/invoice.dart';
import 'package:faktur/src/domain/entities/invoice_line.dart';
import 'package:faktur/src/domain/entities/payment.dart';
import 'package:faktur/src/domain/entities/tax_category.dart';
import 'package:faktur/src/domain/usecases/calculate_invoice_totals.dart';
import 'package:faktur/src/domain/value_objects/money.dart';

void main() {
  test('calculator aggregates subtotal, tax, and payments', () {
    final tax = TaxCategory(id: 1, name: 'VAT', ratePercent: 10, isCompound: false);
    final calculator = InvoiceCalculator(taxCategories: [tax]);

    final invoice = Invoice(
      id: 1,
      invoiceNumber: 'INV-2024-0001',
      clientId: 1,
      issueDate: DateTime(2024, 1, 1),
      dueDate: DateTime(2024, 1, 31),
      currency: 'USD',
      status: InvoiceStatus.sent,
      notes: '',
      terms: '',
      subtotal: Money.zero(),
      taxTotal: Money.zero(),
      discountTotal: Money.zero(),
      total: Money.zero(),
      balanceDue: Money.zero(),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      lines: const [
        InvoiceLine(
          id: 1,
          invoiceId: 1,
          itemName: 'Design',
          itemDescription: '',
          quantity: 2,
          unitPriceCents: 5000,
          discountPercent: 0,
          taxCategoryId: 1,
          lineSubtotalCents: 0,
          lineTaxCents: 0,
          lineTotalCents: 0,
        ),
      ],
      payments: const [],
    );

    final totals = calculator.calculateTotals(invoice);
    expect(totals.subtotal.cents, 10000);
    expect(totals.taxTotal.cents, 1000);
    expect(totals.total.cents, 11000);
    expect(totals.balanceDue.cents, 11000);
    expect(totals.status, InvoiceStatus.sent);
  });

  test('partial payments update status and balance', () {
    final calculator = InvoiceCalculator(taxCategories: const []);

    final invoice = Invoice(
      id: 1,
      invoiceNumber: 'INV-2024-0002',
      clientId: 1,
      issueDate: DateTime(2024, 1, 1),
      dueDate: DateTime(2024, 1, 31),
      currency: 'USD',
      status: InvoiceStatus.sent,
      notes: '',
      terms: '',
      subtotal: const Money(15000),
      taxTotal: const Money(0),
      discountTotal: const Money(0),
      total: const Money(15000),
      balanceDue: const Money(15000),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      lines: const [],
      payments: const [
        Payment(
          id: 1,
          invoiceId: 1,
          amount: Money(5000),
          date: DateTime(2024, 1, 10),
          method: 'Card',
          notes: '',
          createdAt: DateTime(2024, 1, 10),
        ),
      ],
    );

    final totals = calculator.calculateTotals(invoice);
    expect(totals.paid.cents, 5000);
    expect(totals.balanceDue.cents, 10000);
    expect(totals.status, InvoiceStatus.partial);
  });
}
