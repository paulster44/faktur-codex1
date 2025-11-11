import 'package:equatable/equatable.dart';

/// Business profile shown on invoices and exports.
class BusinessProfile extends Equatable {
  const BusinessProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
    required this.accentColor,
  });

  final String name;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final int accentColor;

  @override
  List<Object?> get props => [name, email, phone, street, city, region, postalCode, country, accentColor];
}
