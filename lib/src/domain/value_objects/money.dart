import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Represents a monetary value stored in integer cents to avoid precision loss.
class Money extends Equatable {
  const Money(this.cents);

  final int cents;

  factory Money.zero() => const Money(0);

  Money operator +(Money other) => Money(cents + other.cents);

  Money operator -(Money other) => Money(cents - other.cents);

  Money operator *(num multiplier) => Money((cents * multiplier).round());

  bool get isNegative => cents < 0;

  Money abs() => Money(cents.abs());

  double get decimal => cents / 100;

  String format([String currencyCode = 'USD']) {
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.format(decimal);
  }

  Money percentage(num percent) => Money(((cents * percent) / 100).round());

  Money clampAtZero() => cents < 0 ? Money.zero() : this;

  @override
  List<Object?> get props => [cents];
}
