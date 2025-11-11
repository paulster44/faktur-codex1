import '../entities/invoice.dart';
import '../entities/payment.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/payment_repository.dart';
import '../value_objects/money.dart';
import 'calculate_invoice_totals.dart';

/// Use case for recording payments and updating invoice balances.
class RecordPayment {
  const RecordPayment(
    this._paymentRepository,
    this._invoiceRepository,
    this._calculator,
  );

  final PaymentRepository _paymentRepository;
  final InvoiceRepository _invoiceRepository;
  final InvoiceCalculator _calculator;

  Future<void> call(Payment payment, Invoice invoice) async {
    await _paymentRepository.insert(payment);
    final totals = _calculator.calculateTotals(
      invoice.copyWith(payments: [...invoice.payments, payment]),
    );
    final updatedInvoice = invoice.copyWith(
      balanceDue: totals.balanceDue,
      status: totals.status,
      subtotal: totals.subtotal,
      total: totals.total,
      taxTotal: totals.taxTotal,
      discountTotal: totals.discountTotal,
    );
    await _invoiceRepository.upsert(updatedInvoice);
  }
}

/// Convenience method to build payment entity safely.
Payment createPayment({
  required int invoiceId,
  required int cents,
  required DateTime date,
  required String method,
  String notes = '',
}) {
  return Payment(
    id: 0,
    invoiceId: invoiceId,
    amount: Money(cents),
    date: date,
    method: method,
    notes: notes,
    createdAt: DateTime.now(),
  );
}
