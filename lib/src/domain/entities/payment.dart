import 'package:equatable/equatable.dart';

import '../value_objects/money.dart';

/// Payment entity storing partial or full payments against an invoice.
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.method,
    required this.notes,
    required this.createdAt,
  });

  final int id;
  final int invoiceId;
  final Money amount;
  final DateTime date;
  final String method;
  final String notes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, invoiceId, amount.cents, date];
}
