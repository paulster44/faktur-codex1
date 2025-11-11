import 'package:equatable/equatable.dart';

/// Invoice line item entity.
class InvoiceLine extends Equatable {
  const InvoiceLine({
    required this.id,
    required this.invoiceId,
    required this.itemName,
    required this.itemDescription,
    required this.quantity,
    required this.unitPriceCents,
    required this.discountPercent,
    required this.taxCategoryId,
    required this.lineSubtotalCents,
    required this.lineTaxCents,
    required this.lineTotalCents,
  });

  final int id;
  final int invoiceId;
  final String itemName;
  final String itemDescription;
  final double quantity;
  final int unitPriceCents;
  final double discountPercent;
  final int? taxCategoryId;
  final int lineSubtotalCents;
  final int lineTaxCents;
  final int lineTotalCents;

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        itemName,
        quantity,
        unitPriceCents,
        discountPercent,
        taxCategoryId,
        lineSubtotalCents,
        lineTaxCents,
        lineTotalCents,
      ];
}
