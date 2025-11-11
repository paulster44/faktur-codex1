import '../entities/invoice.dart';
import '../entities/invoice_line.dart';
import '../entities/payment.dart';
import '../entities/tax_category.dart';
import '../value_objects/money.dart';

/// Calculates invoice totals considering discounts, compound taxes, and payments.
class InvoiceCalculator {
  const InvoiceCalculator({required this.taxCategories});

  final List<TaxCategory> taxCategories;

  Money calculateLineSubtotal(InvoiceLine line) {
    final lineTotal = line.unitPriceCents * line.quantity;
    final discount = lineTotal * (line.discountPercent / 100);
    return Money((lineTotal - discount).round());
  }

  Money calculateLineTax(InvoiceLine line) {
    final subtotal = calculateLineSubtotal(line);
    if (line.taxCategoryId == null) {
      return Money.zero();
    }
    final category =
        taxCategories.firstWhere((element) => element.id == line.taxCategoryId, orElse: () => const TaxCategory(id: 0, name: 'None', ratePercent: 0, isCompound: false));
    final baseTax = subtotal.percentage(category.ratePercent);
    if (!category.isCompound) {
      return baseTax;
    }
    return baseTax + baseTax.percentage(category.ratePercent);
  }

  InvoiceTotals calculateTotals(Invoice invoice) {
    Money subtotal = Money.zero();
    Money taxTotal = Money.zero();
    Money discountTotal = Money.zero();

    for (final line in invoice.lines) {
      final lineSubtotal = calculateLineSubtotal(line);
      subtotal += lineSubtotal;
      discountTotal += Money((line.unitPriceCents * line.quantity * (line.discountPercent / 100)).round());
      taxTotal += calculateLineTax(line);
    }

    final total = subtotal + taxTotal;
    Money paid = Money.zero();
    for (final payment in invoice.payments) {
      paid += payment.amount;
    }
    final balanceDue = (total - paid).clampAtZero();
    final status = _determineStatus(invoice.status, total, paid);

    return InvoiceTotals(
      subtotal: subtotal,
      taxTotal: taxTotal,
      discountTotal: discountTotal,
      total: total,
      paid: paid,
      balanceDue: balanceDue,
      status: status,
    );
  }

  InvoiceStatus _determineStatus(InvoiceStatus current, Money total, Money paid) {
    if (current == InvoiceStatus.voided) {
      return InvoiceStatus.voided;
    }
    if (paid.cents <= 0) {
      return current == InvoiceStatus.sent ? InvoiceStatus.sent : InvoiceStatus.draft;
    }
    if (paid.cents >= total.cents) {
      return InvoiceStatus.paid;
    }
    return InvoiceStatus.partial;
  }
}

/// Result of invoice total calculations.
class InvoiceTotals {
  const InvoiceTotals({
    required this.subtotal,
    required this.taxTotal,
    required this.discountTotal,
    required this.total,
    required this.paid,
    required this.balanceDue,
    required this.status,
  });

  final Money subtotal;
  final Money taxTotal;
  final Money discountTotal;
  final Money total;
  final Money paid;
  final Money balanceDue;
  final InvoiceStatus status;
}
