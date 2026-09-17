import 'package:drift/drift.dart';

import '../../common/ids.dart';
import '../../common/phone.dart';
import '../../platform/storage/database.dart';
import '../../platform/sync/mutations.dart';
import '../../platform/sync/op.dart';

/// Customers are created by taking an order, not by a separate "add customer"
/// chore. The phone number is the identity — one number, one customer.
/// docs/02-domain/customers/hld.md
class CustomerRepository {
  CustomerRepository(this.db, this.mutations);

  final AppDatabase db;
  final Mutations mutations;

  Stream<List<Customer>> watchAll() {
    return (db.select(db.customers)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<Customer?> byPhone(String phoneE164) => (db.select(db.customers)
        ..where((t) => t.phoneE164.equals(phoneE164) & t.deletedAt.isNull()))
      .getSingleOrNull();

  /// Free-text match on name or number, for the order form's picker.
  Future<List<Customer>> search(String term) {
    // A number typed "98765 43210" must find one stored "+919876543210", so a
    // numeric term is matched on its digits rather than literally.
    final digits = Phone.digitsOf(term);
    final like = digits.isNotEmpty && Phone.digitsOf(term) == term.replaceAll(' ', '')
        ? '%$digits%'
        : '%${term.trim()}%';
    return (db.select(db.customers)
          ..where((t) =>
              t.deletedAt.isNull() & (t.name.like(like) | t.phoneE164.like(like)))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(20))
        .get();
  }

  /// Finds by number or creates. Returns the customer id either way, so the
  /// order form never has to care which happened.
  Future<String> findOrCreate({
    required String name,
    required String phoneE164,
    String? countryCode,
    String? allergyNote,
  }) async {
    final existing = await byPhone(phoneE164);
    if (existing != null) {
      if (existing.name != name && name.trim().isNotEmpty) {
        await update(existing.id, name: name);
      }
      return existing.id;
    }
    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.customers).insert(CustomersCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: mutations.lastHlc.toString(),
            name: name,
            phoneE164: phoneE164,
            // Derived when the caller did not split it, so a number stored by
            // an older call site still shows the right code in the form.
            countryCode:
                Value(countryCode ?? Phone.parse(phoneE164).country.code),
            allergyNote: Value(allergyNote),
          ));
      await mutations.record('customers', id, OpKind.upsert, {
        'name': name,
        'phone_e164': phoneE164,
        'country_code': countryCode ?? Phone.parse(phoneE164).country.code,
        'allergy_note': allergyNote,
      });
    });
    return id;
  }

  Future<void> update(
    String id, {
    String? name,
    String? phoneE164,
    String? countryCode,
    String? allergyNote,
    String? notes,
  }) async {
    final fields = <String, Object?>{
      if (name != null) 'name': name,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (phoneE164 != null)
        'country_code': countryCode ?? Phone.parse(phoneE164).country.code,
      if (allergyNote != null) 'allergy_note': allergyNote,
      if (notes != null) 'notes': notes,
    };
    if (fields.isEmpty) return;
    await db.transaction(() async {
      await (db.update(db.customers)..where((t) => t.id.equals(id))).write(
        CustomersCompanion(
          name: name == null ? const Value.absent() : Value(name),
          phoneE164: phoneE164 == null ? const Value.absent() : Value(phoneE164),
          countryCode: phoneE164 == null
              ? const Value.absent()
              : Value(countryCode ?? Phone.parse(phoneE164).country.code),
          allergyNote: allergyNote == null ? const Value.absent() : Value(allergyNote),
          notes: notes == null ? const Value.absent() : Value(notes),
          updatedAtHlc: Value(mutations.lastHlc.toString()),
        ),
      );
      await mutations.record('customers', id, OpKind.upsert, fields);
    });
  }

  // ─────────────────────────────── addresses ──────────────────────────────

  /// One customer, many addresses — home, office, a relative's flat. An order
  /// copies the text and pin it was placed against, so editing an address here
  /// never rewrites where a delivered order actually went.
  Future<List<CustomerAddress>> addresses(String customerId) =>
      (db.select(db.customerAddresses)
            ..where((t) =>
                t.customerId.equals(customerId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.desc(t.isDefault),
              (t) => OrderingTerm.asc(t.label),
            ]))
          .get();

  Stream<List<CustomerAddress>> watchAddresses(String customerId) =>
      (db.select(db.customerAddresses)
            ..where((t) =>
                t.customerId.equals(customerId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.desc(t.isDefault),
              (t) => OrderingTerm.asc(t.label),
            ]))
          .watch();

  Future<String> addAddress({
    required String customerId,
    required String label,
    required String addressText,
    double? pinLat,
    double? pinLng,
    String? pinUrl,
    bool isDefault = false,
  }) async {
    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      if (isDefault) await _clearDefault(customerId);
      await db.into(db.customerAddresses).insert(
            CustomerAddressesCompanion.insert(
              id: id,
              deviceId: mutations.deviceId,
              createdAt: now,
              updatedAtHlc: mutations.lastHlc.toString(),
              customerId: customerId,
              label: label,
              addressText: addressText,
              pinLat: Value(pinLat),
              pinLng: Value(pinLng),
              pinUrl: Value(pinUrl),
              isDefault: Value(isDefault),
            ),
          );
      await mutations.record('customer_addresses', id, OpKind.upsert, {
        'customer_id': customerId,
        'label': label,
        'address_text': addressText,
        'pin_lat': pinLat,
        'pin_lng': pinLng,
        'pin_url': pinUrl,
        'is_default': isDefault,
      });
    });
    return id;
  }

  Future<void> removeAddress(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.customerAddresses)..where((t) => t.id.equals(id)))
          .write(CustomerAddressesCompanion(deletedAt: Value(now)));
      await mutations.record(
          'customer_addresses', id, OpKind.delete, const {});
    });
  }

  /// Only one address per customer can be the default one.
  Future<void> _clearDefault(String customerId) async {
    await (db.update(db.customerAddresses)
          ..where((t) => t.customerId.equals(customerId) & t.isDefault.equals(true)))
        .write(CustomerAddressesCompanion(
      isDefault: const Value(false),
      updatedAtHlc: Value(mutations.lastHlc.toString()),
    ));
  }
}
