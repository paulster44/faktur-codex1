import 'package:equatable/equatable.dart';

/// Catalog item available for invoice lines.
class CatalogItem extends Equatable {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.unitPriceCents,
    required this.defaultTaxCategoryId,
  });

  final int id;
  final String name;
  final String description;
  final int unitPriceCents;
  final int? defaultTaxCategoryId;

  @override
  List<Object?> get props => [id, name, description, unitPriceCents, defaultTaxCategoryId];
}
