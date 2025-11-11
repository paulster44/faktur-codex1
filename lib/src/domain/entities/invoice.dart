import 'package:equatable/equatable.dart';

import '../value_objects/money.dart';
import 'invoice_line.dart';
import 'payment.dart';

/// Invoice workflow statuses.
enum InvoiceStatus { draft, sent, partial, paid, voided }

/// Invoice aggregate with lines and payments.
class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.issueDate,
    required this.dueDate,
    required this.currency,
    required this.status,
    required this.notes,
    required this.terms,
    required this.subtotal,
    required this.taxTotal,
    required this.discountTotal,
    required this.total,
    required this.balanceDue,
    required this.createdAt,
    required this.updatedAt,
    this.lines = const [],
    this.payments = const [],
  });

  final int id;
  final String invoiceNumber;
  final int clientId;
  final DateTime issueDate;
  final DateTime dueDate;
  final String currency;
  final InvoiceStatus status;
  final String notes;
  final String terms;
  final Money subtotal;
  final Money taxTotal;
  final Money discountTotal;
  final Money total;
  final Money balanceDue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceLine> lines;
  final List<Payment> payments;

  bool get isOverdue => DateTime.now().isAfter(dueDate) && balanceDue.cents > 0;

  Invoice copyWith({
    InvoiceStatus? status,
    Money? subtotal,
    Money? taxTotal,
    Money? discountTotal,
    Money? total,
    Money? balanceDue,
    List<InvoiceLine>? lines,
    List<Payment>? payments,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber,
      clientId: clientId,
      issueDate: issueDate,
      dueDate: dueDate,
      currency: currency,
      status: status ?? this.status,
      notes: notes,
      terms: terms,
      subtotal: subtotal ?? this.subtotal,
      taxTotal: taxTotal ?? this.taxTotal,
      discountTotal: discountTotal ?? this.discountTotal,
      total: total ?? this.total,
      balanceDue: balanceDue ?? this.balanceDue,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lines: lines ?? this.lines,
      payments: payments ?? this.payments,
    );
  }

  @override
  List<Object?> get props => [id, invoiceNumber, status, total.cents, balanceDue.cents];
}
