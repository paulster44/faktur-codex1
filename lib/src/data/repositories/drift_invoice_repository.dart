import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_line.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/value_objects/money.dart';
import '../local/faktur_database.dart';

/// Drift repository for invoices and related aggregates.
class DriftInvoiceRepository implements InvoiceRepository {
  DriftInvoiceRepository(this._database);

  final FakturDatabase _database;

  static const _invoiceCounterKey = 'invoice_number';

  @override
  Future<void> delete(int id) async {
    await _database.transaction(() async {
      await (_database.delete(_database.invoiceLines)..where((tbl) => tbl.invoiceId.equals(id))).go();
      await (_database.delete(_database.payments)..where((tbl) => tbl.invoiceId.equals(id))).go();
      await (_database.delete(_database.invoices)..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  @override
  Future<Invoice?> findById(int id) async {
    final row = await (_database.select(_database.invoices)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapAggregate(row);
  }

  @override
  Future<int> upsert(Invoice invoice) async {
    return _database.transaction(() async {
      final invoiceCompanion = InvoicesCompanion(
        id: invoice.id == 0 ? const Value.absent() : Value(invoice.id),
        invoiceNumber: Value(invoice.invoiceNumber),
        clientId: Value(invoice.clientId),
        issueDate: Value(invoice.issueDate),
        dueDate: Value(invoice.dueDate),
        currency: Value(invoice.currency),
        status: Value(invoice.status.name),
        notes: Value(invoice.notes),
        terms: Value(invoice.terms),
        subtotal: Value(invoice.subtotal.cents),
        taxTotal: Value(invoice.taxTotal.cents),
        discountTotal: Value(invoice.discountTotal.cents),
        total: Value(invoice.total.cents),
        balanceDue: Value(invoice.balanceDue.cents),
        createdAt: Value(invoice.createdAt),
        updatedAt: Value(invoice.updatedAt),
      );

      final id = await _database.into(_database.invoices).insertOnConflictUpdate(invoiceCompanion);

      await (_database.delete(_database.invoiceLines)..where((tbl) => tbl.invoiceId.equals(id))).go();
      for (final line in invoice.lines) {
        await _database.into(_database.invoiceLines).insert(
              InvoiceLinesCompanion.insert(
                invoiceId: id,
                itemName: line.itemName,
                itemDescription: Value(line.itemDescription),
                quantity: line.quantity,
                unitPrice: line.unitPriceCents,
                discountPercent: Value(line.discountPercent),
                taxCategoryId: Value(line.taxCategoryId),
                lineSubtotal: line.lineSubtotalCents,
                lineTax: line.lineTaxCents,
                lineTotal: line.lineTotalCents,
              ),
            );
      }

      await (_database.delete(_database.payments)..where((tbl) => tbl.invoiceId.equals(id))).go();
      for (final payment in invoice.payments) {
        await _database.into(_database.payments).insert(
              PaymentsCompanion.insert(
                invoiceId: id,
                amount: payment.amount.cents,
                date: payment.date,
                method: payment.method,
                notes: Value(payment.notes),
                createdAt: Value(payment.createdAt),
              ),
            );
      }

      return id;
    });
  }

  @override
  Stream<List<Invoice>> watchInvoices({
    String search = '',
    InvoiceStatus? status,
    InvoiceDateRange? issuedBetween,
    int? clientId,
    String? currency,
  }) {
    final query = _database.select(_database.invoices)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.issueDate)]);

    if (search.isNotEmpty) {
      final like = '%$search%';
      query.where((tbl) => tbl.invoiceNumber.like(like));
    }
    if (status != null) {
      query.where((tbl) => tbl.status.equals(status.name));
    }
    if (issuedBetween != null) {
      query.where(
        (tbl) => tbl.issueDate.isBiggerOrEqualValue(issuedBetween.start) &
            tbl.issueDate.isSmallerOrEqualValue(issuedBetween.end),
      );
    }
    if (clientId != null) {
      query.where((tbl) => tbl.clientId.equals(clientId));
    }
    if (currency != null) {
      query.where((tbl) => tbl.currency.equals(currency));
    }

    return query.watch().asyncMap((rows) async {
      final invoices = await Future.wait(rows.map(_mapAggregate));
      return invoices.toList();
    });
  }

  Future<Invoice> _mapAggregate(InvoicesData row) async {
    final lines = await (_database.select(_database.invoiceLines)..where((tbl) => tbl.invoiceId.equals(row.id))).get();
    final payments = await (_database.select(_database.payments)..where((tbl) => tbl.invoiceId.equals(row.id))).get();
    return Invoice(
      id: row.id,
      invoiceNumber: row.invoiceNumber,
      clientId: row.clientId,
      issueDate: row.issueDate,
      dueDate: row.dueDate,
      currency: row.currency,
      status: InvoiceStatus.values.firstWhereOrNull((element) => element.name == row.status) ?? InvoiceStatus.draft,
      notes: row.notes,
      terms: row.terms,
      subtotal: Money(row.subtotal),
      taxTotal: Money(row.taxTotal),
      discountTotal: Money(row.discountTotal),
      total: Money(row.total),
      balanceDue: Money(row.balanceDue),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lines: lines
          .map(
            (line) => InvoiceLine(
              id: line.id,
              invoiceId: line.invoiceId,
              itemName: line.itemName,
              itemDescription: line.itemDescription,
              quantity: line.quantity,
              unitPriceCents: line.unitPrice,
              discountPercent: line.discountPercent,
              taxCategoryId: line.taxCategoryId,
              lineSubtotalCents: line.lineSubtotal,
              lineTaxCents: line.lineTax,
              lineTotalCents: line.lineTotal,
            ),
          )
          .toList(),
      payments: payments
          .map(
            (payment) => Payment(
              id: payment.id,
              invoiceId: payment.invoiceId,
              amount: Money(payment.amount),
              date: payment.date,
              method: payment.method,
              notes: payment.notes,
              createdAt: payment.createdAt,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<String> nextInvoiceNumber(DateTime date) async {
    final sequence = await _database.nextCounter('$_invoiceCounterKey-${date.year}');
    return 'INV-${date.year}-${sequence.toString().padLeft(4, '0')}';
  }
}
