import 'package:equatable/equatable.dart';

/// Stores auto-numbering counters for invoice sequences.
class Counter extends Equatable {
  const Counter({
    required this.id,
    required this.key,
    required this.currentValue,
  });

  final int id;
  final String key;
  final int currentValue;

  Counter next() => Counter(id: id, key: key, currentValue: currentValue + 1);

  @override
  List<Object?> get props => [id, key, currentValue];
}
