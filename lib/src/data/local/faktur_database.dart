import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'faktur_database.g.dart';

/// Drift table for clients.
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text()();
  TextColumn get companyName => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  TextColumn get street => text()();
  TextColumn get city => text()();
  TextColumn get region => text()();
  TextColumn get postalCode => text()();
  TextColumn get country => text()();
  TextColumn get defaultCurrency => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class TaxCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get ratePercent => real()();
  BoolColumn get isCompound => boolean().withDefault(const Constant(false))();
}

class ItemsCatalog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get unitPrice => integer()();
  IntColumn get defaultTaxCategoryId => integer().nullable().references(TaxCategories, #id)();
}

class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text()();
  IntColumn get clientId => integer().references(Clients, #id)();
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get currency => text()();
  TextColumn get status => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get terms => text().withDefault(const Constant(''))();
  IntColumn get subtotal => integer()();
  IntColumn get taxTotal => integer()();
  IntColumn get discountTotal => integer()();
  IntColumn get total => integer()();
  IntColumn get balanceDue => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class InvoiceLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(Invoices, #id)();
  TextColumn get itemName => text()();
  TextColumn get itemDescription => text().withDefault(const Constant(''))();
  RealColumn get quantity => real()();
  IntColumn get unitPrice => integer()();
  RealColumn get discountPercent => real().withDefault(const Constant(0.0))();
  IntColumn get taxCategoryId => integer().nullable().references(TaxCategories, #id)();
  IntColumn get lineSubtotal => integer()();
  IntColumn get lineTax => integer()();
  IntColumn get lineTotal => integer()();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(Invoices, #id)();
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Counters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  IntColumn get currentValue => integer()();
}

class AppPrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get valueJson => text()();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'faktur.sqlite')); 
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    Clients,
    TaxCategories,
    ItemsCatalog,
    Invoices,
    InvoiceLines,
    Payments,
    Counters,
    AppPrefs,
  ],
)
class FakturDatabase extends _$FakturDatabase {
  FakturDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < to) {
            await m.createAll();
          }
        },
      );

  Future<int> nextCounter(String key) {
    return transaction(() async {
      final existing = await (select(counters)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
      if (existing == null) {
        final id = await into(counters).insert(CountersCompanion.insert(key: key, currentValue: 1));
        return 1;
      }
      final updated = existing.currentValue + 1;
      await update(counters).replace(existing.copyWith(currentValue: Value(updated)));
      return updated;
    });
  }
}
