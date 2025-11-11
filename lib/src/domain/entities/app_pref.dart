import 'package:equatable/equatable.dart';

/// Application key/value preference stored in the local database.
class AppPreference extends Equatable {
  const AppPreference({
    required this.id,
    required this.key,
    required this.valueJson,
  });

  final int id;
  final String key;
  final String valueJson;

  @override
  List<Object?> get props => [id, key, valueJson];
}
