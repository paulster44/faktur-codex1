import '../entities/payment.dart';

/// Repository contract for payments.
abstract class PaymentRepository {
  Stream<List<Payment>> watchByInvoice(int invoiceId);
  Future<int> insert(Payment payment);
  Future<void> delete(int id);
}
