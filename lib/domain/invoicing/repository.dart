import 'dart:convert';

import 'package:drift/drift.dart';

import '../../common/ids.dart';
import '../../platform/storage/database.dart';
import '../../platform/sync/mutations.dart';
import '../../platform/sync/op.dart';
import '../orders/model.dart';
import 'model.dart';

export 'model.dart';


/// Issuing and voiding the bill.
///
/// One invoice per order, ever. The number is never reused — a void leaves a
/// visible gap in the series, which is the point: a missing number that nobody
/// can explain is worse than one that is explained.
/// docs/02-domain/invoicing/hld.md
class InvoiceRepository {
  InvoiceRepository(this.db, this.mutations);

  final AppDatabase db;
  final Mutations mutations;

  Future<Invoice?> forOrder(String orderId) => (db.select(db.invoices)
        ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Stream<Invoice?> watchForOrder(String orderId) => (db.select(db.invoices)
        ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()))
      .watchSingleOrNull();

  /// Issues the bill for an order, or returns the one already issued.
  ///
  /// Idempotent on purpose: it is called when the last item is delivered, and
  /// that can happen twice — a peer's op replaying, a second tap. A second
  /// invoice for one order would be a second number for one sale.
  Future<Invoice> issue({
    required String orderId,
    required List<OrderLine> lines,
    required OrderTotals totals,
  }) async {
    final existing = await forOrder(orderId);
    if (existing != null) return existing;

    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();

    final frozen = _freeze(lines, totals);
    late Invoice issued;

    await db.transaction(() async {
      final settings = await db.select(db.settings).getSingle();
      final seq = settings.invoiceSeq + 1;
      await db.update(db.settings).write(
            SettingsCompanion(invoiceSeq: Value(seq)),
          );

      final number = invoiceNumber(
        prefix: settings.invoicePrefix,
        seq: seq,
        uuid: id,
        issuedAt: DateTime.fromMillisecondsSinceEpoch(now),
      );

      await db.into(db.invoices).insert(InvoicesCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: hlc,
            orderId: orderId,
            invoiceNo: number,
            issuedAt: now,
            frozenTotalsJson: jsonEncode(frozen.toJson()),
          ));

      // Resolving the percentage once, forever. After this, adding an item
      // does not quietly move a discount the customer already agreed to.
      await (db.update(db.orders)..where((t) => t.id.equals(orderId)))
          .write(OrdersCompanion(
        discountAmount: Value(totals.discount.paise),
        updatedAtHlc: Value(hlc),
      ));

      await mutations.record('invoices', id, OpKind.upsert, {
        'order_id': orderId,
        'invoice_no': number,
        'issued_at': now,
        'frozen_totals_json': jsonEncode(frozen.toJson()),
      });
      await mutations.record('orders', orderId, OpKind.upsert, {
        'discount_amount': totals.discount.paise,
      });

      issued = await (db.select(db.invoices)..where((t) => t.id.equals(id)))
          .getSingle();
    });
    return issued;
  }

  /// Voids an invoice. The number stays spent.
  Future<void> voidInvoice(String invoiceId, String reason) async {
    if (reason.trim().isEmpty) {
      throw StateError('Voiding an invoice needs a reason');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();

    await db.transaction(() async {
      final inv = await (db.select(db.invoices)
            ..where((t) => t.id.equals(invoiceId)))
          .getSingle();
      if (inv.voidedAt != null) return;   // idempotent, like issuing

      await (db.update(db.invoices)..where((t) => t.id.equals(invoiceId)))
          .write(InvoicesCompanion(
        voidedAt: Value(now),
        voidReason: Value(reason.trim()),
        updatedAtHlc: Value(hlc),
      ));
      await mutations.record('invoices', invoiceId, OpKind.upsert, {
        'voided_at': now,
        'void_reason': reason.trim(),
      });
    });
  }

  /// A cancelled item leaves the totals, so it leaves the invoice too.
  FrozenTotals _freeze(List<OrderLine> lines, OrderTotals totals) =>
      FrozenTotals(
        lines: [
          for (final l in lines.where((l) => l.isLive))
            FrozenLine(
              name: l.itemName,
              detail: [
                if (l.flavour != null) l.flavour!,
                if (l.weight != null) l.weight!.label,
              ].join(' · ').ifEmpty(),
              qty: l.qty,
              unitPrice: l.basePrice,
              total: l.total,
              addons: [
                for (final a in l.addons) (name: a.name, price: a.price),
              ],
            ),
        ],
        subtotal: totals.subtotal,
        discount: totals.discount,
        delivery: totals.deliveryCharge,
        total: totals.total,
        discountLabel: switch (totals.discountType) {
          DiscountType.percent => 'Discount ${totals.discountValue ~/ 100}%',
          DiscountType.amount => 'Discount',
          null => null,
        },
      );
}

extension on String {
  /// An empty detail line is absent, not blank — the same rule as everywhere.
  String? ifEmpty() => isEmpty ? null : this;
}
