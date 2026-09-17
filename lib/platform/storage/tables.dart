import 'package:drift/drift.dart';

// Schema is defined in docs/02-domain/*/schema.md and
// docs/01-platform/*/schema.md. This file is the executable form of those
// documents; if the two disagree, the document is right.

/// Columns every replicated table carries. Not optional.
mixin Common on Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  IntColumn get createdAt => integer()();
  TextColumn get updatedAtHlc => text()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-field HLC, for tables edited from more than one place.
mixin FieldHlc on Table {
  TextColumn get fieldHlcJson => text().nullable()();
}

// ─────────────────────────────── customers ───────────────────────────────

class Customers extends Table with Common, FieldHlc {
  TextColumn get name => text()();

  /// Dialling code, kept apart from the rest of the number so the two can be
  /// entered and changed separately. India by default.
  TextColumn get countryCode => text().withDefault(const Constant('+91'))();

  /// The composed, canonical number — code and national part with nothing
  /// between them. The unique index is on this, so it stays the single thing
  /// that decides whether two records are the same person.
  TextColumn get phoneE164 => text()();
  TextColumn get altPhone => text().nullable()();
  TextColumn get allergyNote => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text().nullable()();
}

/// A customer keeps as many addresses as they order to — home, office, a
/// relative's flat. The order snapshots whichever one was chosen, so editing an
/// address later never rewrites the history of a delivered order.
@DataClassName('CustomerAddress')
class CustomerAddresses extends Table with Common, FieldHlc {
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get label => text()(); // Home, Office, …
  TextColumn get addressText => text()();
  RealColumn get pinLat => real().nullable()();
  RealColumn get pinLng => real().nullable()();
  TextColumn get pinUrl => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
        // a pin is both halves or neither
        'CHECK ((pin_lat IS NULL) = (pin_lng IS NULL))',
      ];
}

// ──────────────────────────────── menu ───────────────────────────────────

class MenuItems extends Table with Common, FieldHlc {
  /// The item *is* the category — "Cake", "Croissant", "Focaccia". What used to
  /// be a separate category column said the same thing twice.
  TextColumn get name => text()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get leadDays => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get seasonFrom => integer().nullable()(); // MMDD
  IntColumn get seasonTo => integer().nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK (lead_days >= 0)',
        'CHECK ((season_from IS NULL) = (season_to IS NULL))',
      ];
}

// ─────────────────────────────── orders ──────────────────────────────────

class Orders extends Table with Common, FieldHlc {
  TextColumn get orderNo => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get status => text()();
  TextColumn get fulfilment => text()();
  IntColumn get deliveryDate => integer()(); // local midnight, epoch ms
  IntColumn get deliveryTime => integer().nullable()(); // minutes from midnight
  TextColumn get deliveryType => text().nullable()(); // local|outstation
  TextColumn get addressText => text().nullable()();
  RealColumn get pinLat => real().nullable()();
  RealColumn get pinLng => real().nullable()();
  TextColumn get pinUrl => text().nullable()();
  TextColumn get trackingUrl => text().nullable()();
  TextColumn get discountType => text().nullable()(); // percent|amount
  IntColumn get discountValue => integer().nullable()(); // bp or paise
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get deliveryCharge => integer().withDefault(const Constant(0))();
  TextColumn get requirements => text().nullable()();
  TextColumn get itemMessage => text().nullable()();
  IntColumn get dietaryFlags => integer().withDefault(const Constant(0))();
  IntColumn get requirementsChangedAt => integer().nullable()();
  IntColumn get requirementsAckAt => integer().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get cancelReason => text().nullable()();
  IntColumn get deliveredAt => integer().nullable()();

  @override
  List<String> get customConstraints => [
        "CHECK (status IN ('created','confirmed','in_production','ready','out','delivered','completed','cancelled'))",
        "CHECK (fulfilment IN ('delivery','pickup'))",
        "CHECK (delivery_type IS NULL OR delivery_type IN ('local','outstation'))",
        "CHECK (discount_type IS NULL OR discount_type IN ('percent','amount'))",
        // a pickup can carry neither a delivery type nor a tracking link
        "CHECK (fulfilment = 'delivery' OR (delivery_type IS NULL AND tracking_url IS NULL))",
      ];
}

class OrderItems extends Table with Common {
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get menuItemId => text().references(MenuItems, #id)(); // NOT NULL (D16)
  TextColumn get itemNameSnapshot => text()();
  TextColumn get flavour => text().nullable()();
  RealColumn get weightValue => real().nullable()();
  TextColumn get weightUnit => text().nullable()();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  IntColumn get basePrice => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get position => integer()();

  @override
  List<String> get customConstraints => [
        'CHECK (qty > 0)',
        // a weight is both halves or neither
        'CHECK ((weight_value IS NULL) = (weight_unit IS NULL))',
        "CHECK (weight_unit IS NULL OR weight_unit IN ('g','kg','pcs','dozen'))",
        'CHECK (weight_value IS NULL OR weight_value > 0)',
      ];
}

class OrderItemAddons extends Table with Common {
  TextColumn get orderItemId => text().references(OrderItems, #id)();
  TextColumn get name => text()();
  IntColumn get price => integer()(); // for the LINE, not per unit
  IntColumn get position => integer()();
}

class OrderStatusEvents extends Table with Common {
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get fromStatus => text().nullable()();
  TextColumn get toStatus => text()();
  TextColumn get reason => text().nullable()();
  IntColumn get at => integer()();
}

class Attachments extends Table with Common {
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get path => text()();
  TextColumn get kind => text()(); // reference|proof
}

// ─────────────────────────────── money ───────────────────────────────────

class Payments extends Table with Common {
  TextColumn get orderId => text().references(Orders, #id)();
  IntColumn get amount => integer()(); // paise; negative for a refund
  TextColumn get kind => text()(); // advance|balance|refund
  TextColumn get mode => text()(); // upi|cash|transfer
  TextColumn get reference => text().nullable()();
  IntColumn get paidAt => integer()();

  @override
  List<String> get customConstraints => [
        'CHECK (amount <> 0)',
        "CHECK (kind IN ('advance','balance','refund'))",
        "CHECK (mode IN ('upi','cash','transfer'))",
        "CHECK ((kind = 'refund') = (amount < 0))",
      ];
}

class Invoices extends Table with Common {
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get invoiceNo => text()();
  IntColumn get issuedAt => integer()();
  TextColumn get frozenTotalsJson => text()();
  IntColumn get voidedAt => integer().nullable()();
  TextColumn get voidReason => text().nullable()();
  // GST — present and unused until settings.gstEnabled
  TextColumn get hsnCode => text().nullable()();
  IntColumn get taxRate => integer().nullable()();
  IntColumn get cgst => integer().nullable()();
  IntColumn get sgst => integer().nullable()();
  IntColumn get igst => integer().nullable()();
  TextColumn get placeOfSupply => text().nullable()();
}

// ─────────────────────────────── stock ───────────────────────────────────

@DataClassName('RawMaterial')
class Materials extends Table with Common, FieldHlc {
  TextColumn get name => text()();
  TextColumn get category => text()(); // raw|packaging
  TextColumn get unit => text()();
  RealColumn get thresholdQty => real()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  List<String> get customConstraints => [
        "CHECK (category IN ('raw','packaging'))",
        "CHECK (unit IN ('kg','g','L','ml','pcs','box'))",
        'CHECK (threshold_qty >= 0)',
      ];
}

class StockTransactions extends Table with Common {
  TextColumn get materialId => text().references(Materials, #id)();
  TextColumn get kind => text()(); // in|consume|waste|count
  RealColumn get qty => real()(); // delta, except `count` where it is absolute
  IntColumn get amount => integer().nullable()(); // paise, only on `in`
  TextColumn get reason => text().nullable()(); // waste only
  IntColumn get at => integer()();

  @override
  List<String> get customConstraints => [
        "CHECK (kind IN ('in','consume','waste','count'))",
        'CHECK (qty >= 0)',
        "CHECK (amount IS NULL OR kind = 'in')",
        "CHECK (reason IS NULL OR kind = 'waste')",
        "CHECK (reason IS NULL OR reason IN ('expired','spoiled','spilled','failed_bake'))",
      ];
}

// ────────────────────────────── messaging ────────────────────────────────

class ShareLog extends Table with Common {
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get kind => text()();
  IntColumn get composedAt => integer()();
  IntColumn get sharedAt => integer().nullable()(); // launched, NOT sent

  @override
  List<String> get customConstraints => [
        "CHECK (kind IN ('confirmation','out_for_delivery','delivery','payment_received','invoice'))",
      ];
}

// ──────────────────────────────── sync ───────────────────────────────────

class Devices extends Table with Common {
  TextColumn get name => text().nullable()();
  IntColumn get firstSeenAt => integer()();
  IntColumn get lastSeenAt => integer()();
  IntColumn get appVersion => integer().nullable()();
}

class ConflictLog extends Table with Common {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get localValue => text().nullable()();
  TextColumn get remoteValue => text().nullable()();
  TextColumn get winner => text()(); // local|remote
  TextColumn get reason => text()();
  IntColumn get at => integer()();
}

/// Local only — never replicated.
class Outbox extends Table {
  TextColumn get opId => text()();
  IntColumn get seq => integer()();
  TextColumn get hlc => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get kind => text()(); // upsert|delete
  TextColumn get payload => text()();
  IntColumn get schemaV => integer()();
  IntColumn get uploadedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {opId};
}

/// Local only — idempotency guard.
class AppliedOps extends Table {
  TextColumn get opId => text()();
  IntColumn get appliedAt => integer()();

  @override
  Set<Column> get primaryKey => {opId};
}

/// Local only — how far we have read each peer.
class PeerCursors extends Table {
  TextColumn get peerDeviceId => text()();
  IntColumn get lastSeq => integer().withDefault(const Constant(0))();
  IntColumn get lastPulledAt => integer().nullable()();
  BoolColumn get needsUpgrade => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {peerDeviceId};
}

// ─────────────────────────────── settings ────────────────────────────────

class Settings extends Table {
  TextColumn get id => text().withDefault(const Constant('singleton'))();
  TextColumn get businessName => text().withDefault(const Constant('Little Loaf Bakery'))();
  TextColumn get logoPath => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get invoicePrefix => text().withDefault(const Constant('LLB'))();
  TextColumn get termsLine => text().nullable()();
  TextColumn get upiId => text().nullable()();
  TextColumn get paymentPhone => text().nullable()();
  IntColumn get deliveryChargeLocal => integer().withDefault(const Constant(0))();
  IntColumn get deliveryChargeOutstation => integer().withDefault(const Constant(0))();
  TextColumn get gstin => text().nullable()();
  BoolColumn get gstEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get appLockEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get deviceName => text().nullable()();
  // local only — do not survive a snapshot, which is why a restored install
  // takes a new device id (D6)
  IntColumn get orderSeq => integer().withDefault(const Constant(0))();
  IntColumn get invoiceSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ["CHECK (id = 'singleton')"];
}
