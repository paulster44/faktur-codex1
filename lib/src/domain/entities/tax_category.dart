import 'package:equatable/equatable.dart';

/// Tax category definitions, supporting compound tax calculations.
class TaxCategory extends Equatable {
  const TaxCategory({
    required this.id,
    required this.name,
    required this.ratePercent,
    required this.isCompound,
  });

  final int id;
  final String name;
  final double ratePercent;
  final bool isCompound;

  @override
  List<Object?> get props => [id, name, ratePercent, isCompound];
}
