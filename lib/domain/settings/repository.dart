import 'package:drift/drift.dart';

import '../../platform/storage/database.dart';
import '../../platform/storage/tables.dart' show kSharedSettings;
import '../../platform/sync/mutations.dart';
import '../../platform/sync/op.dart';

/// The one settings row, and the line down the middle of it.
///
/// [saveBusiness] is the bakery: both phones must show the same name on a
/// message and charge the same for a delivery, so it records an op.
/// [saveThisDevice] is the handset: its name and its lock belong to the phone
/// in your hand, and sending them would have one phone rename the other.
///
/// The split is `kSharedSettings`, and the applier refuses the same fields on
/// the way in — see `platform/sync/apply.dart`.
/// docs/02-domain/settings/hld.md
class SettingsRepository {
  SettingsRepository(this.db, this.mutations);

  final AppDatabase db;
  final Mutations mutations;

  Stream<Setting> watch() => db.select(db.settings).watchSingle();

  Future<Setting> read() => db.select(db.settings).getSingle();

  /// The bakery's own details. Replicates.
  Future<void> saveBusiness({
    String? businessName,
    String? address,
    String? phone,
    String? invoicePrefix,
    String? upiId,
    String? paymentPhone,
    int? deliveryChargeLocal,
    int? deliveryChargeOutstation,
  }) async {
    // Null means "not being edited" and is skipped; clearing a field is an
    // empty string, which is a value and does travel.
    final fields = <String, Object?>{
      if (businessName != null) 'business_name': businessName,
      if (address != null) 'address': address.isEmpty ? null : address,
      if (phone != null) 'phone': phone.isEmpty ? null : phone,
      if (invoicePrefix != null) 'invoice_prefix': invoicePrefix,
      if (upiId != null) 'upi_id': upiId.isEmpty ? null : upiId,
      if (paymentPhone != null)
        'payment_phone': paymentPhone.isEmpty ? null : paymentPhone,
      if (deliveryChargeLocal != null)
        'delivery_charge_local': deliveryChargeLocal,
      if (deliveryChargeOutstation != null)
        'delivery_charge_outstation': deliveryChargeOutstation,
    };
    if (fields.isEmpty) return;

    // A field that is not shared must never reach this method. Asserting is
    // cheaper than discovering it as one phone renaming another.
    assert(
      fields.keys.every(kSharedSettings.contains),
      'not a shared setting: ${fields.keys.where((k) => !kSharedSettings.contains(k))}',
    );

    await db.transaction(() async {
      await db.update(db.settings).write(SettingsCompanion(
            businessName: _text(businessName),
            address: _nullableText(address),
            phone: _nullableText(phone),
            invoicePrefix: _text(invoicePrefix),
            upiId: _nullableText(upiId),
            paymentPhone: _nullableText(paymentPhone),
            deliveryChargeLocal: _int(deliveryChargeLocal),
            deliveryChargeOutstation: _int(deliveryChargeOutstation),
            updatedAtHlc: Value(mutations.lastHlc.toString()),
          ));
      await mutations.record('settings', 'singleton', OpKind.upsert, fields);
    });
  }

  /// This handset's own. Never leaves it.
  Future<void> saveThisDevice({String? deviceName, bool? appLockEnabled}) async {
    if (deviceName == null && appLockEnabled == null) return;
    await db.update(db.settings).write(SettingsCompanion(
          deviceName: _nullableText(deviceName),
          appLockEnabled: appLockEnabled == null
              ? const Value.absent()
              : Value(appLockEnabled),
        ));
  }

  static Value<String> _text(String? v) =>
      v == null ? const Value.absent() : Value(v);

  static Value<String?> _nullableText(String? v) => v == null
      ? const Value.absent()
      : Value(v.isEmpty ? null : v);

  static Value<int> _int(int? v) =>
      v == null ? const Value.absent() : Value(v);
}
