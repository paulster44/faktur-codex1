import 'package:equatable/equatable.dart';

/// Client entity representing billing recipients.
class Client extends Equatable {
  const Client({
    required this.id,
    required this.displayName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
    required this.defaultCurrency,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String displayName;
  final String companyName;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final String defaultCurrency;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client copyWith({
    String? displayName,
    String? companyName,
    String? email,
    String? phone,
    String? street,
    String? city,
    String? region,
    String? postalCode,
    String? country,
    String? defaultCurrency,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id,
      displayName: displayName ?? this.displayName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, displayName, companyName, email, phone];
}
