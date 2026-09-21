// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldHlcJsonMeta = const VerificationMeta(
    'fieldHlcJson',
  );
  @override
  late final GeneratedColumn<String> fieldHlcJson = GeneratedColumn<String>(
    'field_hlc_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('+91'),
  );
  static const VerificationMeta _phoneE164Meta = const VerificationMeta(
    'phoneE164',
  );
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
    'phone_e164',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altPhoneMeta = const VerificationMeta(
    'altPhone',
  );
  @override
  late final GeneratedColumn<String> altPhone = GeneratedColumn<String>(
    'alt_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergyNoteMeta = const VerificationMeta(
    'allergyNote',
  );
  @override
  late final GeneratedColumn<String> allergyNote = GeneratedColumn<String>(
    'allergy_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    name,
    countryCode,
    phoneE164,
    altPhone,
    allergyNote,
    notes,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('field_hlc_json')) {
      context.handle(
        _fieldHlcJsonMeta,
        fieldHlcJson.isAcceptableOrUnknown(
          data['field_hlc_json']!,
          _fieldHlcJsonMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('phone_e164')) {
      context.handle(
        _phoneE164Meta,
        phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta),
      );
    } else if (isInserting) {
      context.missing(_phoneE164Meta);
    }
    if (data.containsKey('alt_phone')) {
      context.handle(
        _altPhoneMeta,
        altPhone.isAcceptableOrUnknown(data['alt_phone']!, _altPhoneMeta),
      );
    }
    if (data.containsKey('allergy_note')) {
      context.handle(
        _allergyNoteMeta,
        allergyNote.isAcceptableOrUnknown(
          data['allergy_note']!,
          _allergyNoteMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      fieldHlcJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_hlc_json'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      )!,
      phoneE164: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_e164'],
      )!,
      altPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_phone'],
      ),
      allergyNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergy_note'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String? fieldHlcJson;
  final String name;

  /// Dialling code, kept apart from the rest of the number so the two can be
  /// entered and changed separately. India by default.
  final String countryCode;

  /// The composed, canonical number — code and national part with nothing
  /// between them. The unique index is on this, so it stays the single thing
  /// that decides whether two records are the same person.
  final String phoneE164;
  final String? altPhone;
  final String? allergyNote;
  final String? notes;
  final String? tags;
  const Customer({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    this.fieldHlcJson,
    required this.name,
    required this.countryCode,
    required this.phoneE164,
    this.altPhone,
    this.allergyNote,
    this.notes,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || fieldHlcJson != null) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson);
    }
    map['name'] = Variable<String>(name);
    map['country_code'] = Variable<String>(countryCode);
    map['phone_e164'] = Variable<String>(phoneE164);
    if (!nullToAbsent || altPhone != null) {
      map['alt_phone'] = Variable<String>(altPhone);
    }
    if (!nullToAbsent || allergyNote != null) {
      map['allergy_note'] = Variable<String>(allergyNote);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fieldHlcJson: fieldHlcJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldHlcJson),
      name: Value(name),
      countryCode: Value(countryCode),
      phoneE164: Value(phoneE164),
      altPhone: altPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(altPhone),
      allergyNote: allergyNote == null && nullToAbsent
          ? const Value.absent()
          : Value(allergyNote),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      fieldHlcJson: serializer.fromJson<String?>(json['fieldHlcJson']),
      name: serializer.fromJson<String>(json['name']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      phoneE164: serializer.fromJson<String>(json['phoneE164']),
      altPhone: serializer.fromJson<String?>(json['altPhone']),
      allergyNote: serializer.fromJson<String?>(json['allergyNote']),
      notes: serializer.fromJson<String?>(json['notes']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'fieldHlcJson': serializer.toJson<String?>(fieldHlcJson),
      'name': serializer.toJson<String>(name),
      'countryCode': serializer.toJson<String>(countryCode),
      'phoneE164': serializer.toJson<String>(phoneE164),
      'altPhone': serializer.toJson<String?>(altPhone),
      'allergyNote': serializer.toJson<String?>(allergyNote),
      'notes': serializer.toJson<String?>(notes),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  Customer copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> fieldHlcJson = const Value.absent(),
    String? name,
    String? countryCode,
    String? phoneE164,
    Value<String?> altPhone = const Value.absent(),
    Value<String?> allergyNote = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> tags = const Value.absent(),
  }) => Customer(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    fieldHlcJson: fieldHlcJson.present ? fieldHlcJson.value : this.fieldHlcJson,
    name: name ?? this.name,
    countryCode: countryCode ?? this.countryCode,
    phoneE164: phoneE164 ?? this.phoneE164,
    altPhone: altPhone.present ? altPhone.value : this.altPhone,
    allergyNote: allergyNote.present ? allergyNote.value : this.allergyNote,
    notes: notes.present ? notes.value : this.notes,
    tags: tags.present ? tags.value : this.tags,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fieldHlcJson: data.fieldHlcJson.present
          ? data.fieldHlcJson.value
          : this.fieldHlcJson,
      name: data.name.present ? data.name.value : this.name,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      altPhone: data.altPhone.present ? data.altPhone.value : this.altPhone,
      allergyNote: data.allergyNote.present
          ? data.allergyNote.value
          : this.allergyNote,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('name: $name, ')
          ..write('countryCode: $countryCode, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('altPhone: $altPhone, ')
          ..write('allergyNote: $allergyNote, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    name,
    countryCode,
    phoneE164,
    altPhone,
    allergyNote,
    notes,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.fieldHlcJson == this.fieldHlcJson &&
          other.name == this.name &&
          other.countryCode == this.countryCode &&
          other.phoneE164 == this.phoneE164 &&
          other.altPhone == this.altPhone &&
          other.allergyNote == this.allergyNote &&
          other.notes == this.notes &&
          other.tags == this.tags);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String?> fieldHlcJson;
  final Value<String> name;
  final Value<String> countryCode;
  final Value<String> phoneE164;
  final Value<String?> altPhone;
  final Value<String?> allergyNote;
  final Value<String?> notes;
  final Value<String?> tags;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    this.name = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.altPhone = const Value.absent(),
    this.allergyNote = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    required String name,
    this.countryCode = const Value.absent(),
    required String phoneE164,
    this.altPhone = const Value.absent(),
    this.allergyNote = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       name = Value(name),
       phoneE164 = Value(phoneE164);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? fieldHlcJson,
    Expression<String>? name,
    Expression<String>? countryCode,
    Expression<String>? phoneE164,
    Expression<String>? altPhone,
    Expression<String>? allergyNote,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fieldHlcJson != null) 'field_hlc_json': fieldHlcJson,
      if (name != null) 'name': name,
      if (countryCode != null) 'country_code': countryCode,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (altPhone != null) 'alt_phone': altPhone,
      if (allergyNote != null) 'allergy_note': allergyNote,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String?>? fieldHlcJson,
    Value<String>? name,
    Value<String>? countryCode,
    Value<String>? phoneE164,
    Value<String?>? altPhone,
    Value<String?>? allergyNote,
    Value<String?>? notes,
    Value<String?>? tags,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      fieldHlcJson: fieldHlcJson ?? this.fieldHlcJson,
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      phoneE164: phoneE164 ?? this.phoneE164,
      altPhone: altPhone ?? this.altPhone,
      allergyNote: allergyNote ?? this.allergyNote,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (fieldHlcJson.present) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (altPhone.present) {
      map['alt_phone'] = Variable<String>(altPhone.value);
    }
    if (allergyNote.present) {
      map['allergy_note'] = Variable<String>(allergyNote.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('name: $name, ')
          ..write('countryCode: $countryCode, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('altPhone: $altPhone, ')
          ..write('allergyNote: $allergyNote, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerAddressesTable extends CustomerAddresses
    with TableInfo<$CustomerAddressesTable, CustomerAddress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldHlcJsonMeta = const VerificationMeta(
    'fieldHlcJson',
  );
  @override
  late final GeneratedColumn<String> fieldHlcJson = GeneratedColumn<String>(
    'field_hlc_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressTextMeta = const VerificationMeta(
    'addressText',
  );
  @override
  late final GeneratedColumn<String> addressText = GeneratedColumn<String>(
    'address_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinLatMeta = const VerificationMeta('pinLat');
  @override
  late final GeneratedColumn<double> pinLat = GeneratedColumn<double>(
    'pin_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinLngMeta = const VerificationMeta('pinLng');
  @override
  late final GeneratedColumn<double> pinLng = GeneratedColumn<double>(
    'pin_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinUrlMeta = const VerificationMeta('pinUrl');
  @override
  late final GeneratedColumn<String> pinUrl = GeneratedColumn<String>(
    'pin_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    customerId,
    label,
    addressText,
    pinLat,
    pinLng,
    pinUrl,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_addresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerAddress> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('field_hlc_json')) {
      context.handle(
        _fieldHlcJsonMeta,
        fieldHlcJson.isAcceptableOrUnknown(
          data['field_hlc_json']!,
          _fieldHlcJsonMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('address_text')) {
      context.handle(
        _addressTextMeta,
        addressText.isAcceptableOrUnknown(
          data['address_text']!,
          _addressTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addressTextMeta);
    }
    if (data.containsKey('pin_lat')) {
      context.handle(
        _pinLatMeta,
        pinLat.isAcceptableOrUnknown(data['pin_lat']!, _pinLatMeta),
      );
    }
    if (data.containsKey('pin_lng')) {
      context.handle(
        _pinLngMeta,
        pinLng.isAcceptableOrUnknown(data['pin_lng']!, _pinLngMeta),
      );
    }
    if (data.containsKey('pin_url')) {
      context.handle(
        _pinUrlMeta,
        pinUrl.isAcceptableOrUnknown(data['pin_url']!, _pinUrlMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerAddress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerAddress(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      fieldHlcJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_hlc_json'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      addressText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_text'],
      )!,
      pinLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pin_lat'],
      ),
      pinLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pin_lng'],
      ),
      pinUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_url'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $CustomerAddressesTable createAlias(String alias) {
    return $CustomerAddressesTable(attachedDatabase, alias);
  }
}

class CustomerAddress extends DataClass implements Insertable<CustomerAddress> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String? fieldHlcJson;
  final String customerId;
  final String label;
  final String addressText;
  final double? pinLat;
  final double? pinLng;
  final String? pinUrl;
  final bool isDefault;
  const CustomerAddress({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    this.fieldHlcJson,
    required this.customerId,
    required this.label,
    required this.addressText,
    this.pinLat,
    this.pinLng,
    this.pinUrl,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || fieldHlcJson != null) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['label'] = Variable<String>(label);
    map['address_text'] = Variable<String>(addressText);
    if (!nullToAbsent || pinLat != null) {
      map['pin_lat'] = Variable<double>(pinLat);
    }
    if (!nullToAbsent || pinLng != null) {
      map['pin_lng'] = Variable<double>(pinLng);
    }
    if (!nullToAbsent || pinUrl != null) {
      map['pin_url'] = Variable<String>(pinUrl);
    }
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  CustomerAddressesCompanion toCompanion(bool nullToAbsent) {
    return CustomerAddressesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fieldHlcJson: fieldHlcJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldHlcJson),
      customerId: Value(customerId),
      label: Value(label),
      addressText: Value(addressText),
      pinLat: pinLat == null && nullToAbsent
          ? const Value.absent()
          : Value(pinLat),
      pinLng: pinLng == null && nullToAbsent
          ? const Value.absent()
          : Value(pinLng),
      pinUrl: pinUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pinUrl),
      isDefault: Value(isDefault),
    );
  }

  factory CustomerAddress.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerAddress(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      fieldHlcJson: serializer.fromJson<String?>(json['fieldHlcJson']),
      customerId: serializer.fromJson<String>(json['customerId']),
      label: serializer.fromJson<String>(json['label']),
      addressText: serializer.fromJson<String>(json['addressText']),
      pinLat: serializer.fromJson<double?>(json['pinLat']),
      pinLng: serializer.fromJson<double?>(json['pinLng']),
      pinUrl: serializer.fromJson<String?>(json['pinUrl']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'fieldHlcJson': serializer.toJson<String?>(fieldHlcJson),
      'customerId': serializer.toJson<String>(customerId),
      'label': serializer.toJson<String>(label),
      'addressText': serializer.toJson<String>(addressText),
      'pinLat': serializer.toJson<double?>(pinLat),
      'pinLng': serializer.toJson<double?>(pinLng),
      'pinUrl': serializer.toJson<String?>(pinUrl),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  CustomerAddress copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> fieldHlcJson = const Value.absent(),
    String? customerId,
    String? label,
    String? addressText,
    Value<double?> pinLat = const Value.absent(),
    Value<double?> pinLng = const Value.absent(),
    Value<String?> pinUrl = const Value.absent(),
    bool? isDefault,
  }) => CustomerAddress(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    fieldHlcJson: fieldHlcJson.present ? fieldHlcJson.value : this.fieldHlcJson,
    customerId: customerId ?? this.customerId,
    label: label ?? this.label,
    addressText: addressText ?? this.addressText,
    pinLat: pinLat.present ? pinLat.value : this.pinLat,
    pinLng: pinLng.present ? pinLng.value : this.pinLng,
    pinUrl: pinUrl.present ? pinUrl.value : this.pinUrl,
    isDefault: isDefault ?? this.isDefault,
  );
  CustomerAddress copyWithCompanion(CustomerAddressesCompanion data) {
    return CustomerAddress(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fieldHlcJson: data.fieldHlcJson.present
          ? data.fieldHlcJson.value
          : this.fieldHlcJson,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      label: data.label.present ? data.label.value : this.label,
      addressText: data.addressText.present
          ? data.addressText.value
          : this.addressText,
      pinLat: data.pinLat.present ? data.pinLat.value : this.pinLat,
      pinLng: data.pinLng.present ? data.pinLng.value : this.pinLng,
      pinUrl: data.pinUrl.present ? data.pinUrl.value : this.pinUrl,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerAddress(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('customerId: $customerId, ')
          ..write('label: $label, ')
          ..write('addressText: $addressText, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinUrl: $pinUrl, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    customerId,
    label,
    addressText,
    pinLat,
    pinLng,
    pinUrl,
    isDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerAddress &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.fieldHlcJson == this.fieldHlcJson &&
          other.customerId == this.customerId &&
          other.label == this.label &&
          other.addressText == this.addressText &&
          other.pinLat == this.pinLat &&
          other.pinLng == this.pinLng &&
          other.pinUrl == this.pinUrl &&
          other.isDefault == this.isDefault);
}

class CustomerAddressesCompanion extends UpdateCompanion<CustomerAddress> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String?> fieldHlcJson;
  final Value<String> customerId;
  final Value<String> label;
  final Value<String> addressText;
  final Value<double?> pinLat;
  final Value<double?> pinLng;
  final Value<String?> pinUrl;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const CustomerAddressesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    this.customerId = const Value.absent(),
    this.label = const Value.absent(),
    this.addressText = const Value.absent(),
    this.pinLat = const Value.absent(),
    this.pinLng = const Value.absent(),
    this.pinUrl = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerAddressesCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    required String customerId,
    required String label,
    required String addressText,
    this.pinLat = const Value.absent(),
    this.pinLng = const Value.absent(),
    this.pinUrl = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       customerId = Value(customerId),
       label = Value(label),
       addressText = Value(addressText);
  static Insertable<CustomerAddress> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? fieldHlcJson,
    Expression<String>? customerId,
    Expression<String>? label,
    Expression<String>? addressText,
    Expression<double>? pinLat,
    Expression<double>? pinLng,
    Expression<String>? pinUrl,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fieldHlcJson != null) 'field_hlc_json': fieldHlcJson,
      if (customerId != null) 'customer_id': customerId,
      if (label != null) 'label': label,
      if (addressText != null) 'address_text': addressText,
      if (pinLat != null) 'pin_lat': pinLat,
      if (pinLng != null) 'pin_lng': pinLng,
      if (pinUrl != null) 'pin_url': pinUrl,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerAddressesCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String?>? fieldHlcJson,
    Value<String>? customerId,
    Value<String>? label,
    Value<String>? addressText,
    Value<double?>? pinLat,
    Value<double?>? pinLng,
    Value<String?>? pinUrl,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return CustomerAddressesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      fieldHlcJson: fieldHlcJson ?? this.fieldHlcJson,
      customerId: customerId ?? this.customerId,
      label: label ?? this.label,
      addressText: addressText ?? this.addressText,
      pinLat: pinLat ?? this.pinLat,
      pinLng: pinLng ?? this.pinLng,
      pinUrl: pinUrl ?? this.pinUrl,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (fieldHlcJson.present) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (addressText.present) {
      map['address_text'] = Variable<String>(addressText.value);
    }
    if (pinLat.present) {
      map['pin_lat'] = Variable<double>(pinLat.value);
    }
    if (pinLng.present) {
      map['pin_lng'] = Variable<double>(pinLng.value);
    }
    if (pinUrl.present) {
      map['pin_url'] = Variable<String>(pinUrl.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerAddressesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('customerId: $customerId, ')
          ..write('label: $label, ')
          ..write('addressText: $addressText, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinUrl: $pinUrl, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MenuItemsTable extends MenuItems
    with TableInfo<$MenuItemsTable, MenuItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenuItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldHlcJsonMeta = const VerificationMeta(
    'fieldHlcJson',
  );
  @override
  late final GeneratedColumn<String> fieldHlcJson = GeneratedColumn<String>(
    'field_hlc_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leadDaysMeta = const VerificationMeta(
    'leadDays',
  );
  @override
  late final GeneratedColumn<int> leadDays = GeneratedColumn<int>(
    'lead_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seasonFromMeta = const VerificationMeta(
    'seasonFrom',
  );
  @override
  late final GeneratedColumn<int> seasonFrom = GeneratedColumn<int>(
    'season_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonToMeta = const VerificationMeta(
    'seasonTo',
  );
  @override
  late final GeneratedColumn<int> seasonTo = GeneratedColumn<int>(
    'season_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    name,
    photoPath,
    leadDays,
    active,
    seasonFrom,
    seasonTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menu_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MenuItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('field_hlc_json')) {
      context.handle(
        _fieldHlcJsonMeta,
        fieldHlcJson.isAcceptableOrUnknown(
          data['field_hlc_json']!,
          _fieldHlcJsonMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('lead_days')) {
      context.handle(
        _leadDaysMeta,
        leadDays.isAcceptableOrUnknown(data['lead_days']!, _leadDaysMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('season_from')) {
      context.handle(
        _seasonFromMeta,
        seasonFrom.isAcceptableOrUnknown(data['season_from']!, _seasonFromMeta),
      );
    }
    if (data.containsKey('season_to')) {
      context.handle(
        _seasonToMeta,
        seasonTo.isAcceptableOrUnknown(data['season_to']!, _seasonToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MenuItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      fieldHlcJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_hlc_json'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      leadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lead_days'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      seasonFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_from'],
      ),
      seasonTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_to'],
      ),
    );
  }

  @override
  $MenuItemsTable createAlias(String alias) {
    return $MenuItemsTable(attachedDatabase, alias);
  }
}

class MenuItem extends DataClass implements Insertable<MenuItem> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String? fieldHlcJson;

  /// The item *is* the category — "Cake", "Croissant", "Focaccia". What used to
  /// be a separate category column said the same thing twice.
  final String name;
  final String? photoPath;
  final int leadDays;
  final bool active;
  final int? seasonFrom;
  final int? seasonTo;
  const MenuItem({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    this.fieldHlcJson,
    required this.name,
    this.photoPath,
    required this.leadDays,
    required this.active,
    this.seasonFrom,
    this.seasonTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || fieldHlcJson != null) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['lead_days'] = Variable<int>(leadDays);
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || seasonFrom != null) {
      map['season_from'] = Variable<int>(seasonFrom);
    }
    if (!nullToAbsent || seasonTo != null) {
      map['season_to'] = Variable<int>(seasonTo);
    }
    return map;
  }

  MenuItemsCompanion toCompanion(bool nullToAbsent) {
    return MenuItemsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fieldHlcJson: fieldHlcJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldHlcJson),
      name: Value(name),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      leadDays: Value(leadDays),
      active: Value(active),
      seasonFrom: seasonFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonFrom),
      seasonTo: seasonTo == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonTo),
    );
  }

  factory MenuItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuItem(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      fieldHlcJson: serializer.fromJson<String?>(json['fieldHlcJson']),
      name: serializer.fromJson<String>(json['name']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      leadDays: serializer.fromJson<int>(json['leadDays']),
      active: serializer.fromJson<bool>(json['active']),
      seasonFrom: serializer.fromJson<int?>(json['seasonFrom']),
      seasonTo: serializer.fromJson<int?>(json['seasonTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'fieldHlcJson': serializer.toJson<String?>(fieldHlcJson),
      'name': serializer.toJson<String>(name),
      'photoPath': serializer.toJson<String?>(photoPath),
      'leadDays': serializer.toJson<int>(leadDays),
      'active': serializer.toJson<bool>(active),
      'seasonFrom': serializer.toJson<int?>(seasonFrom),
      'seasonTo': serializer.toJson<int?>(seasonTo),
    };
  }

  MenuItem copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> fieldHlcJson = const Value.absent(),
    String? name,
    Value<String?> photoPath = const Value.absent(),
    int? leadDays,
    bool? active,
    Value<int?> seasonFrom = const Value.absent(),
    Value<int?> seasonTo = const Value.absent(),
  }) => MenuItem(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    fieldHlcJson: fieldHlcJson.present ? fieldHlcJson.value : this.fieldHlcJson,
    name: name ?? this.name,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    leadDays: leadDays ?? this.leadDays,
    active: active ?? this.active,
    seasonFrom: seasonFrom.present ? seasonFrom.value : this.seasonFrom,
    seasonTo: seasonTo.present ? seasonTo.value : this.seasonTo,
  );
  MenuItem copyWithCompanion(MenuItemsCompanion data) {
    return MenuItem(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fieldHlcJson: data.fieldHlcJson.present
          ? data.fieldHlcJson.value
          : this.fieldHlcJson,
      name: data.name.present ? data.name.value : this.name,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      leadDays: data.leadDays.present ? data.leadDays.value : this.leadDays,
      active: data.active.present ? data.active.value : this.active,
      seasonFrom: data.seasonFrom.present
          ? data.seasonFrom.value
          : this.seasonFrom,
      seasonTo: data.seasonTo.present ? data.seasonTo.value : this.seasonTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuItem(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('name: $name, ')
          ..write('photoPath: $photoPath, ')
          ..write('leadDays: $leadDays, ')
          ..write('active: $active, ')
          ..write('seasonFrom: $seasonFrom, ')
          ..write('seasonTo: $seasonTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    name,
    photoPath,
    leadDays,
    active,
    seasonFrom,
    seasonTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuItem &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.fieldHlcJson == this.fieldHlcJson &&
          other.name == this.name &&
          other.photoPath == this.photoPath &&
          other.leadDays == this.leadDays &&
          other.active == this.active &&
          other.seasonFrom == this.seasonFrom &&
          other.seasonTo == this.seasonTo);
}

class MenuItemsCompanion extends UpdateCompanion<MenuItem> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String?> fieldHlcJson;
  final Value<String> name;
  final Value<String?> photoPath;
  final Value<int> leadDays;
  final Value<bool> active;
  final Value<int?> seasonFrom;
  final Value<int?> seasonTo;
  final Value<int> rowid;
  const MenuItemsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    this.name = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.leadDays = const Value.absent(),
    this.active = const Value.absent(),
    this.seasonFrom = const Value.absent(),
    this.seasonTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenuItemsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    required String name,
    this.photoPath = const Value.absent(),
    this.leadDays = const Value.absent(),
    this.active = const Value.absent(),
    this.seasonFrom = const Value.absent(),
    this.seasonTo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       name = Value(name);
  static Insertable<MenuItem> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? fieldHlcJson,
    Expression<String>? name,
    Expression<String>? photoPath,
    Expression<int>? leadDays,
    Expression<bool>? active,
    Expression<int>? seasonFrom,
    Expression<int>? seasonTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fieldHlcJson != null) 'field_hlc_json': fieldHlcJson,
      if (name != null) 'name': name,
      if (photoPath != null) 'photo_path': photoPath,
      if (leadDays != null) 'lead_days': leadDays,
      if (active != null) 'active': active,
      if (seasonFrom != null) 'season_from': seasonFrom,
      if (seasonTo != null) 'season_to': seasonTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenuItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String?>? fieldHlcJson,
    Value<String>? name,
    Value<String?>? photoPath,
    Value<int>? leadDays,
    Value<bool>? active,
    Value<int?>? seasonFrom,
    Value<int?>? seasonTo,
    Value<int>? rowid,
  }) {
    return MenuItemsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      fieldHlcJson: fieldHlcJson ?? this.fieldHlcJson,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      leadDays: leadDays ?? this.leadDays,
      active: active ?? this.active,
      seasonFrom: seasonFrom ?? this.seasonFrom,
      seasonTo: seasonTo ?? this.seasonTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (fieldHlcJson.present) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (leadDays.present) {
      map['lead_days'] = Variable<int>(leadDays.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (seasonFrom.present) {
      map['season_from'] = Variable<int>(seasonFrom.value);
    }
    if (seasonTo.present) {
      map['season_to'] = Variable<int>(seasonTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenuItemsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('name: $name, ')
          ..write('photoPath: $photoPath, ')
          ..write('leadDays: $leadDays, ')
          ..write('active: $active, ')
          ..write('seasonFrom: $seasonFrom, ')
          ..write('seasonTo: $seasonTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldHlcJsonMeta = const VerificationMeta(
    'fieldHlcJson',
  );
  @override
  late final GeneratedColumn<String> fieldHlcJson = GeneratedColumn<String>(
    'field_hlc_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderNoMeta = const VerificationMeta(
    'orderNo',
  );
  @override
  late final GeneratedColumn<String> orderNo = GeneratedColumn<String>(
    'order_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fulfilmentMeta = const VerificationMeta(
    'fulfilment',
  );
  @override
  late final GeneratedColumn<String> fulfilment = GeneratedColumn<String>(
    'fulfilment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryDateMeta = const VerificationMeta(
    'deliveryDate',
  );
  @override
  late final GeneratedColumn<int> deliveryDate = GeneratedColumn<int>(
    'delivery_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryTimeMeta = const VerificationMeta(
    'deliveryTime',
  );
  @override
  late final GeneratedColumn<int> deliveryTime = GeneratedColumn<int>(
    'delivery_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryTypeMeta = const VerificationMeta(
    'deliveryType',
  );
  @override
  late final GeneratedColumn<String> deliveryType = GeneratedColumn<String>(
    'delivery_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressTextMeta = const VerificationMeta(
    'addressText',
  );
  @override
  late final GeneratedColumn<String> addressText = GeneratedColumn<String>(
    'address_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinLatMeta = const VerificationMeta('pinLat');
  @override
  late final GeneratedColumn<double> pinLat = GeneratedColumn<double>(
    'pin_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinLngMeta = const VerificationMeta('pinLng');
  @override
  late final GeneratedColumn<double> pinLng = GeneratedColumn<double>(
    'pin_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinUrlMeta = const VerificationMeta('pinUrl');
  @override
  late final GeneratedColumn<String> pinUrl = GeneratedColumn<String>(
    'pin_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackingUrlMeta = const VerificationMeta(
    'trackingUrl',
  );
  @override
  late final GeneratedColumn<String> trackingUrl = GeneratedColumn<String>(
    'tracking_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<int> discountValue = GeneratedColumn<int>(
    'discount_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<int> discountAmount = GeneratedColumn<int>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deliveryChargeMeta = const VerificationMeta(
    'deliveryCharge',
  );
  @override
  late final GeneratedColumn<int> deliveryCharge = GeneratedColumn<int>(
    'delivery_charge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _requirementsMeta = const VerificationMeta(
    'requirements',
  );
  @override
  late final GeneratedColumn<String> requirements = GeneratedColumn<String>(
    'requirements',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemMessageMeta = const VerificationMeta(
    'itemMessage',
  );
  @override
  late final GeneratedColumn<String> itemMessage = GeneratedColumn<String>(
    'item_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dietaryFlagsMeta = const VerificationMeta(
    'dietaryFlags',
  );
  @override
  late final GeneratedColumn<int> dietaryFlags = GeneratedColumn<int>(
    'dietary_flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _requirementsChangedAtMeta =
      const VerificationMeta('requirementsChangedAt');
  @override
  late final GeneratedColumn<int> requirementsChangedAt = GeneratedColumn<int>(
    'requirements_changed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requirementsAckAtMeta = const VerificationMeta(
    'requirementsAckAt',
  );
  @override
  late final GeneratedColumn<int> requirementsAckAt = GeneratedColumn<int>(
    'requirements_ack_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelReasonMeta = const VerificationMeta(
    'cancelReason',
  );
  @override
  late final GeneratedColumn<String> cancelReason = GeneratedColumn<String>(
    'cancel_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<int> deliveredAt = GeneratedColumn<int>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<int> confirmedAt = GeneratedColumn<int>(
    'confirmed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    orderNo,
    customerId,
    status,
    fulfilment,
    deliveryDate,
    deliveryTime,
    deliveryType,
    addressText,
    pinLat,
    pinLng,
    pinUrl,
    trackingUrl,
    discountType,
    discountValue,
    discountAmount,
    deliveryCharge,
    requirements,
    itemMessage,
    dietaryFlags,
    requirementsChangedAt,
    requirementsAckAt,
    source,
    notes,
    cancelReason,
    deliveredAt,
    confirmedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('field_hlc_json')) {
      context.handle(
        _fieldHlcJsonMeta,
        fieldHlcJson.isAcceptableOrUnknown(
          data['field_hlc_json']!,
          _fieldHlcJsonMeta,
        ),
      );
    }
    if (data.containsKey('order_no')) {
      context.handle(
        _orderNoMeta,
        orderNo.isAcceptableOrUnknown(data['order_no']!, _orderNoMeta),
      );
    } else if (isInserting) {
      context.missing(_orderNoMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('fulfilment')) {
      context.handle(
        _fulfilmentMeta,
        fulfilment.isAcceptableOrUnknown(data['fulfilment']!, _fulfilmentMeta),
      );
    } else if (isInserting) {
      context.missing(_fulfilmentMeta);
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
        _deliveryDateMeta,
        deliveryDate.isAcceptableOrUnknown(
          data['delivery_date']!,
          _deliveryDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deliveryDateMeta);
    }
    if (data.containsKey('delivery_time')) {
      context.handle(
        _deliveryTimeMeta,
        deliveryTime.isAcceptableOrUnknown(
          data['delivery_time']!,
          _deliveryTimeMeta,
        ),
      );
    }
    if (data.containsKey('delivery_type')) {
      context.handle(
        _deliveryTypeMeta,
        deliveryType.isAcceptableOrUnknown(
          data['delivery_type']!,
          _deliveryTypeMeta,
        ),
      );
    }
    if (data.containsKey('address_text')) {
      context.handle(
        _addressTextMeta,
        addressText.isAcceptableOrUnknown(
          data['address_text']!,
          _addressTextMeta,
        ),
      );
    }
    if (data.containsKey('pin_lat')) {
      context.handle(
        _pinLatMeta,
        pinLat.isAcceptableOrUnknown(data['pin_lat']!, _pinLatMeta),
      );
    }
    if (data.containsKey('pin_lng')) {
      context.handle(
        _pinLngMeta,
        pinLng.isAcceptableOrUnknown(data['pin_lng']!, _pinLngMeta),
      );
    }
    if (data.containsKey('pin_url')) {
      context.handle(
        _pinUrlMeta,
        pinUrl.isAcceptableOrUnknown(data['pin_url']!, _pinUrlMeta),
      );
    }
    if (data.containsKey('tracking_url')) {
      context.handle(
        _trackingUrlMeta,
        trackingUrl.isAcceptableOrUnknown(
          data['tracking_url']!,
          _trackingUrlMeta,
        ),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('delivery_charge')) {
      context.handle(
        _deliveryChargeMeta,
        deliveryCharge.isAcceptableOrUnknown(
          data['delivery_charge']!,
          _deliveryChargeMeta,
        ),
      );
    }
    if (data.containsKey('requirements')) {
      context.handle(
        _requirementsMeta,
        requirements.isAcceptableOrUnknown(
          data['requirements']!,
          _requirementsMeta,
        ),
      );
    }
    if (data.containsKey('item_message')) {
      context.handle(
        _itemMessageMeta,
        itemMessage.isAcceptableOrUnknown(
          data['item_message']!,
          _itemMessageMeta,
        ),
      );
    }
    if (data.containsKey('dietary_flags')) {
      context.handle(
        _dietaryFlagsMeta,
        dietaryFlags.isAcceptableOrUnknown(
          data['dietary_flags']!,
          _dietaryFlagsMeta,
        ),
      );
    }
    if (data.containsKey('requirements_changed_at')) {
      context.handle(
        _requirementsChangedAtMeta,
        requirementsChangedAt.isAcceptableOrUnknown(
          data['requirements_changed_at']!,
          _requirementsChangedAtMeta,
        ),
      );
    }
    if (data.containsKey('requirements_ack_at')) {
      context.handle(
        _requirementsAckAtMeta,
        requirementsAckAt.isAcceptableOrUnknown(
          data['requirements_ack_at']!,
          _requirementsAckAtMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('cancel_reason')) {
      context.handle(
        _cancelReasonMeta,
        cancelReason.isAcceptableOrUnknown(
          data['cancel_reason']!,
          _cancelReasonMeta,
        ),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      fieldHlcJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_hlc_json'],
      ),
      orderNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_no'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      fulfilment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fulfilment'],
      )!,
      deliveryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_date'],
      )!,
      deliveryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_time'],
      ),
      deliveryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_type'],
      ),
      addressText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_text'],
      ),
      pinLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pin_lat'],
      ),
      pinLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pin_lng'],
      ),
      pinUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_url'],
      ),
      trackingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_url'],
      ),
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      ),
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_value'],
      ),
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_amount'],
      )!,
      deliveryCharge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_charge'],
      )!,
      requirements: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requirements'],
      ),
      itemMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_message'],
      ),
      dietaryFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dietary_flags'],
      )!,
      requirementsChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requirements_changed_at'],
      ),
      requirementsAckAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requirements_ack_at'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      cancelReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancel_reason'],
      ),
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivered_at'],
      ),
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmed_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String? fieldHlcJson;
  final String orderNo;
  final String customerId;
  final String status;
  final String fulfilment;
  final int deliveryDate;
  final int? deliveryTime;
  final String? deliveryType;
  final String? addressText;
  final double? pinLat;
  final double? pinLng;
  final String? pinUrl;
  final String? trackingUrl;
  final String? discountType;
  final int? discountValue;
  final int discountAmount;
  final int deliveryCharge;
  final String? requirements;
  final String? itemMessage;
  final int dietaryFlags;
  final int? requirementsChangedAt;
  final int? requirementsAckAt;
  final String? source;
  final String? notes;
  final String? cancelReason;
  final int? deliveredAt;
  final int? confirmedAt;
  final int? completedAt;
  const Order({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    this.fieldHlcJson,
    required this.orderNo,
    required this.customerId,
    required this.status,
    required this.fulfilment,
    required this.deliveryDate,
    this.deliveryTime,
    this.deliveryType,
    this.addressText,
    this.pinLat,
    this.pinLng,
    this.pinUrl,
    this.trackingUrl,
    this.discountType,
    this.discountValue,
    required this.discountAmount,
    required this.deliveryCharge,
    this.requirements,
    this.itemMessage,
    required this.dietaryFlags,
    this.requirementsChangedAt,
    this.requirementsAckAt,
    this.source,
    this.notes,
    this.cancelReason,
    this.deliveredAt,
    this.confirmedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || fieldHlcJson != null) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson);
    }
    map['order_no'] = Variable<String>(orderNo);
    map['customer_id'] = Variable<String>(customerId);
    map['status'] = Variable<String>(status);
    map['fulfilment'] = Variable<String>(fulfilment);
    map['delivery_date'] = Variable<int>(deliveryDate);
    if (!nullToAbsent || deliveryTime != null) {
      map['delivery_time'] = Variable<int>(deliveryTime);
    }
    if (!nullToAbsent || deliveryType != null) {
      map['delivery_type'] = Variable<String>(deliveryType);
    }
    if (!nullToAbsent || addressText != null) {
      map['address_text'] = Variable<String>(addressText);
    }
    if (!nullToAbsent || pinLat != null) {
      map['pin_lat'] = Variable<double>(pinLat);
    }
    if (!nullToAbsent || pinLng != null) {
      map['pin_lng'] = Variable<double>(pinLng);
    }
    if (!nullToAbsent || pinUrl != null) {
      map['pin_url'] = Variable<String>(pinUrl);
    }
    if (!nullToAbsent || trackingUrl != null) {
      map['tracking_url'] = Variable<String>(trackingUrl);
    }
    if (!nullToAbsent || discountType != null) {
      map['discount_type'] = Variable<String>(discountType);
    }
    if (!nullToAbsent || discountValue != null) {
      map['discount_value'] = Variable<int>(discountValue);
    }
    map['discount_amount'] = Variable<int>(discountAmount);
    map['delivery_charge'] = Variable<int>(deliveryCharge);
    if (!nullToAbsent || requirements != null) {
      map['requirements'] = Variable<String>(requirements);
    }
    if (!nullToAbsent || itemMessage != null) {
      map['item_message'] = Variable<String>(itemMessage);
    }
    map['dietary_flags'] = Variable<int>(dietaryFlags);
    if (!nullToAbsent || requirementsChangedAt != null) {
      map['requirements_changed_at'] = Variable<int>(requirementsChangedAt);
    }
    if (!nullToAbsent || requirementsAckAt != null) {
      map['requirements_ack_at'] = Variable<int>(requirementsAckAt);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || cancelReason != null) {
      map['cancel_reason'] = Variable<String>(cancelReason);
    }
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<int>(deliveredAt);
    }
    if (!nullToAbsent || confirmedAt != null) {
      map['confirmed_at'] = Variable<int>(confirmedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fieldHlcJson: fieldHlcJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldHlcJson),
      orderNo: Value(orderNo),
      customerId: Value(customerId),
      status: Value(status),
      fulfilment: Value(fulfilment),
      deliveryDate: Value(deliveryDate),
      deliveryTime: deliveryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryTime),
      deliveryType: deliveryType == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryType),
      addressText: addressText == null && nullToAbsent
          ? const Value.absent()
          : Value(addressText),
      pinLat: pinLat == null && nullToAbsent
          ? const Value.absent()
          : Value(pinLat),
      pinLng: pinLng == null && nullToAbsent
          ? const Value.absent()
          : Value(pinLng),
      pinUrl: pinUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pinUrl),
      trackingUrl: trackingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingUrl),
      discountType: discountType == null && nullToAbsent
          ? const Value.absent()
          : Value(discountType),
      discountValue: discountValue == null && nullToAbsent
          ? const Value.absent()
          : Value(discountValue),
      discountAmount: Value(discountAmount),
      deliveryCharge: Value(deliveryCharge),
      requirements: requirements == null && nullToAbsent
          ? const Value.absent()
          : Value(requirements),
      itemMessage: itemMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(itemMessage),
      dietaryFlags: Value(dietaryFlags),
      requirementsChangedAt: requirementsChangedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(requirementsChangedAt),
      requirementsAckAt: requirementsAckAt == null && nullToAbsent
          ? const Value.absent()
          : Value(requirementsAckAt),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      cancelReason: cancelReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelReason),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      confirmedAt: confirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      fieldHlcJson: serializer.fromJson<String?>(json['fieldHlcJson']),
      orderNo: serializer.fromJson<String>(json['orderNo']),
      customerId: serializer.fromJson<String>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      fulfilment: serializer.fromJson<String>(json['fulfilment']),
      deliveryDate: serializer.fromJson<int>(json['deliveryDate']),
      deliveryTime: serializer.fromJson<int?>(json['deliveryTime']),
      deliveryType: serializer.fromJson<String?>(json['deliveryType']),
      addressText: serializer.fromJson<String?>(json['addressText']),
      pinLat: serializer.fromJson<double?>(json['pinLat']),
      pinLng: serializer.fromJson<double?>(json['pinLng']),
      pinUrl: serializer.fromJson<String?>(json['pinUrl']),
      trackingUrl: serializer.fromJson<String?>(json['trackingUrl']),
      discountType: serializer.fromJson<String?>(json['discountType']),
      discountValue: serializer.fromJson<int?>(json['discountValue']),
      discountAmount: serializer.fromJson<int>(json['discountAmount']),
      deliveryCharge: serializer.fromJson<int>(json['deliveryCharge']),
      requirements: serializer.fromJson<String?>(json['requirements']),
      itemMessage: serializer.fromJson<String?>(json['itemMessage']),
      dietaryFlags: serializer.fromJson<int>(json['dietaryFlags']),
      requirementsChangedAt: serializer.fromJson<int?>(
        json['requirementsChangedAt'],
      ),
      requirementsAckAt: serializer.fromJson<int?>(json['requirementsAckAt']),
      source: serializer.fromJson<String?>(json['source']),
      notes: serializer.fromJson<String?>(json['notes']),
      cancelReason: serializer.fromJson<String?>(json['cancelReason']),
      deliveredAt: serializer.fromJson<int?>(json['deliveredAt']),
      confirmedAt: serializer.fromJson<int?>(json['confirmedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'fieldHlcJson': serializer.toJson<String?>(fieldHlcJson),
      'orderNo': serializer.toJson<String>(orderNo),
      'customerId': serializer.toJson<String>(customerId),
      'status': serializer.toJson<String>(status),
      'fulfilment': serializer.toJson<String>(fulfilment),
      'deliveryDate': serializer.toJson<int>(deliveryDate),
      'deliveryTime': serializer.toJson<int?>(deliveryTime),
      'deliveryType': serializer.toJson<String?>(deliveryType),
      'addressText': serializer.toJson<String?>(addressText),
      'pinLat': serializer.toJson<double?>(pinLat),
      'pinLng': serializer.toJson<double?>(pinLng),
      'pinUrl': serializer.toJson<String?>(pinUrl),
      'trackingUrl': serializer.toJson<String?>(trackingUrl),
      'discountType': serializer.toJson<String?>(discountType),
      'discountValue': serializer.toJson<int?>(discountValue),
      'discountAmount': serializer.toJson<int>(discountAmount),
      'deliveryCharge': serializer.toJson<int>(deliveryCharge),
      'requirements': serializer.toJson<String?>(requirements),
      'itemMessage': serializer.toJson<String?>(itemMessage),
      'dietaryFlags': serializer.toJson<int>(dietaryFlags),
      'requirementsChangedAt': serializer.toJson<int?>(requirementsChangedAt),
      'requirementsAckAt': serializer.toJson<int?>(requirementsAckAt),
      'source': serializer.toJson<String?>(source),
      'notes': serializer.toJson<String?>(notes),
      'cancelReason': serializer.toJson<String?>(cancelReason),
      'deliveredAt': serializer.toJson<int?>(deliveredAt),
      'confirmedAt': serializer.toJson<int?>(confirmedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }

  Order copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> fieldHlcJson = const Value.absent(),
    String? orderNo,
    String? customerId,
    String? status,
    String? fulfilment,
    int? deliveryDate,
    Value<int?> deliveryTime = const Value.absent(),
    Value<String?> deliveryType = const Value.absent(),
    Value<String?> addressText = const Value.absent(),
    Value<double?> pinLat = const Value.absent(),
    Value<double?> pinLng = const Value.absent(),
    Value<String?> pinUrl = const Value.absent(),
    Value<String?> trackingUrl = const Value.absent(),
    Value<String?> discountType = const Value.absent(),
    Value<int?> discountValue = const Value.absent(),
    int? discountAmount,
    int? deliveryCharge,
    Value<String?> requirements = const Value.absent(),
    Value<String?> itemMessage = const Value.absent(),
    int? dietaryFlags,
    Value<int?> requirementsChangedAt = const Value.absent(),
    Value<int?> requirementsAckAt = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> cancelReason = const Value.absent(),
    Value<int?> deliveredAt = const Value.absent(),
    Value<int?> confirmedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
  }) => Order(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    fieldHlcJson: fieldHlcJson.present ? fieldHlcJson.value : this.fieldHlcJson,
    orderNo: orderNo ?? this.orderNo,
    customerId: customerId ?? this.customerId,
    status: status ?? this.status,
    fulfilment: fulfilment ?? this.fulfilment,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    deliveryTime: deliveryTime.present ? deliveryTime.value : this.deliveryTime,
    deliveryType: deliveryType.present ? deliveryType.value : this.deliveryType,
    addressText: addressText.present ? addressText.value : this.addressText,
    pinLat: pinLat.present ? pinLat.value : this.pinLat,
    pinLng: pinLng.present ? pinLng.value : this.pinLng,
    pinUrl: pinUrl.present ? pinUrl.value : this.pinUrl,
    trackingUrl: trackingUrl.present ? trackingUrl.value : this.trackingUrl,
    discountType: discountType.present ? discountType.value : this.discountType,
    discountValue: discountValue.present
        ? discountValue.value
        : this.discountValue,
    discountAmount: discountAmount ?? this.discountAmount,
    deliveryCharge: deliveryCharge ?? this.deliveryCharge,
    requirements: requirements.present ? requirements.value : this.requirements,
    itemMessage: itemMessage.present ? itemMessage.value : this.itemMessage,
    dietaryFlags: dietaryFlags ?? this.dietaryFlags,
    requirementsChangedAt: requirementsChangedAt.present
        ? requirementsChangedAt.value
        : this.requirementsChangedAt,
    requirementsAckAt: requirementsAckAt.present
        ? requirementsAckAt.value
        : this.requirementsAckAt,
    source: source.present ? source.value : this.source,
    notes: notes.present ? notes.value : this.notes,
    cancelReason: cancelReason.present ? cancelReason.value : this.cancelReason,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    confirmedAt: confirmedAt.present ? confirmedAt.value : this.confirmedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fieldHlcJson: data.fieldHlcJson.present
          ? data.fieldHlcJson.value
          : this.fieldHlcJson,
      orderNo: data.orderNo.present ? data.orderNo.value : this.orderNo,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      fulfilment: data.fulfilment.present
          ? data.fulfilment.value
          : this.fulfilment,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      deliveryTime: data.deliveryTime.present
          ? data.deliveryTime.value
          : this.deliveryTime,
      deliveryType: data.deliveryType.present
          ? data.deliveryType.value
          : this.deliveryType,
      addressText: data.addressText.present
          ? data.addressText.value
          : this.addressText,
      pinLat: data.pinLat.present ? data.pinLat.value : this.pinLat,
      pinLng: data.pinLng.present ? data.pinLng.value : this.pinLng,
      pinUrl: data.pinUrl.present ? data.pinUrl.value : this.pinUrl,
      trackingUrl: data.trackingUrl.present
          ? data.trackingUrl.value
          : this.trackingUrl,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      deliveryCharge: data.deliveryCharge.present
          ? data.deliveryCharge.value
          : this.deliveryCharge,
      requirements: data.requirements.present
          ? data.requirements.value
          : this.requirements,
      itemMessage: data.itemMessage.present
          ? data.itemMessage.value
          : this.itemMessage,
      dietaryFlags: data.dietaryFlags.present
          ? data.dietaryFlags.value
          : this.dietaryFlags,
      requirementsChangedAt: data.requirementsChangedAt.present
          ? data.requirementsChangedAt.value
          : this.requirementsChangedAt,
      requirementsAckAt: data.requirementsAckAt.present
          ? data.requirementsAckAt.value
          : this.requirementsAckAt,
      source: data.source.present ? data.source.value : this.source,
      notes: data.notes.present ? data.notes.value : this.notes,
      cancelReason: data.cancelReason.present
          ? data.cancelReason.value
          : this.cancelReason,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('orderNo: $orderNo, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('fulfilment: $fulfilment, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('addressText: $addressText, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinUrl: $pinUrl, ')
          ..write('trackingUrl: $trackingUrl, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('deliveryCharge: $deliveryCharge, ')
          ..write('requirements: $requirements, ')
          ..write('itemMessage: $itemMessage, ')
          ..write('dietaryFlags: $dietaryFlags, ')
          ..write('requirementsChangedAt: $requirementsChangedAt, ')
          ..write('requirementsAckAt: $requirementsAckAt, ')
          ..write('source: $source, ')
          ..write('notes: $notes, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    orderNo,
    customerId,
    status,
    fulfilment,
    deliveryDate,
    deliveryTime,
    deliveryType,
    addressText,
    pinLat,
    pinLng,
    pinUrl,
    trackingUrl,
    discountType,
    discountValue,
    discountAmount,
    deliveryCharge,
    requirements,
    itemMessage,
    dietaryFlags,
    requirementsChangedAt,
    requirementsAckAt,
    source,
    notes,
    cancelReason,
    deliveredAt,
    confirmedAt,
    completedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.fieldHlcJson == this.fieldHlcJson &&
          other.orderNo == this.orderNo &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.fulfilment == this.fulfilment &&
          other.deliveryDate == this.deliveryDate &&
          other.deliveryTime == this.deliveryTime &&
          other.deliveryType == this.deliveryType &&
          other.addressText == this.addressText &&
          other.pinLat == this.pinLat &&
          other.pinLng == this.pinLng &&
          other.pinUrl == this.pinUrl &&
          other.trackingUrl == this.trackingUrl &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue &&
          other.discountAmount == this.discountAmount &&
          other.deliveryCharge == this.deliveryCharge &&
          other.requirements == this.requirements &&
          other.itemMessage == this.itemMessage &&
          other.dietaryFlags == this.dietaryFlags &&
          other.requirementsChangedAt == this.requirementsChangedAt &&
          other.requirementsAckAt == this.requirementsAckAt &&
          other.source == this.source &&
          other.notes == this.notes &&
          other.cancelReason == this.cancelReason &&
          other.deliveredAt == this.deliveredAt &&
          other.confirmedAt == this.confirmedAt &&
          other.completedAt == this.completedAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String?> fieldHlcJson;
  final Value<String> orderNo;
  final Value<String> customerId;
  final Value<String> status;
  final Value<String> fulfilment;
  final Value<int> deliveryDate;
  final Value<int?> deliveryTime;
  final Value<String?> deliveryType;
  final Value<String?> addressText;
  final Value<double?> pinLat;
  final Value<double?> pinLng;
  final Value<String?> pinUrl;
  final Value<String?> trackingUrl;
  final Value<String?> discountType;
  final Value<int?> discountValue;
  final Value<int> discountAmount;
  final Value<int> deliveryCharge;
  final Value<String?> requirements;
  final Value<String?> itemMessage;
  final Value<int> dietaryFlags;
  final Value<int?> requirementsChangedAt;
  final Value<int?> requirementsAckAt;
  final Value<String?> source;
  final Value<String?> notes;
  final Value<String?> cancelReason;
  final Value<int?> deliveredAt;
  final Value<int?> confirmedAt;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    this.orderNo = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.fulfilment = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.deliveryTime = const Value.absent(),
    this.deliveryType = const Value.absent(),
    this.addressText = const Value.absent(),
    this.pinLat = const Value.absent(),
    this.pinLng = const Value.absent(),
    this.pinUrl = const Value.absent(),
    this.trackingUrl = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.deliveryCharge = const Value.absent(),
    this.requirements = const Value.absent(),
    this.itemMessage = const Value.absent(),
    this.dietaryFlags = const Value.absent(),
    this.requirementsChangedAt = const Value.absent(),
    this.requirementsAckAt = const Value.absent(),
    this.source = const Value.absent(),
    this.notes = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    required String orderNo,
    required String customerId,
    required String status,
    required String fulfilment,
    required int deliveryDate,
    this.deliveryTime = const Value.absent(),
    this.deliveryType = const Value.absent(),
    this.addressText = const Value.absent(),
    this.pinLat = const Value.absent(),
    this.pinLng = const Value.absent(),
    this.pinUrl = const Value.absent(),
    this.trackingUrl = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.deliveryCharge = const Value.absent(),
    this.requirements = const Value.absent(),
    this.itemMessage = const Value.absent(),
    this.dietaryFlags = const Value.absent(),
    this.requirementsChangedAt = const Value.absent(),
    this.requirementsAckAt = const Value.absent(),
    this.source = const Value.absent(),
    this.notes = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderNo = Value(orderNo),
       customerId = Value(customerId),
       status = Value(status),
       fulfilment = Value(fulfilment),
       deliveryDate = Value(deliveryDate);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? fieldHlcJson,
    Expression<String>? orderNo,
    Expression<String>? customerId,
    Expression<String>? status,
    Expression<String>? fulfilment,
    Expression<int>? deliveryDate,
    Expression<int>? deliveryTime,
    Expression<String>? deliveryType,
    Expression<String>? addressText,
    Expression<double>? pinLat,
    Expression<double>? pinLng,
    Expression<String>? pinUrl,
    Expression<String>? trackingUrl,
    Expression<String>? discountType,
    Expression<int>? discountValue,
    Expression<int>? discountAmount,
    Expression<int>? deliveryCharge,
    Expression<String>? requirements,
    Expression<String>? itemMessage,
    Expression<int>? dietaryFlags,
    Expression<int>? requirementsChangedAt,
    Expression<int>? requirementsAckAt,
    Expression<String>? source,
    Expression<String>? notes,
    Expression<String>? cancelReason,
    Expression<int>? deliveredAt,
    Expression<int>? confirmedAt,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fieldHlcJson != null) 'field_hlc_json': fieldHlcJson,
      if (orderNo != null) 'order_no': orderNo,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (fulfilment != null) 'fulfilment': fulfilment,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (deliveryTime != null) 'delivery_time': deliveryTime,
      if (deliveryType != null) 'delivery_type': deliveryType,
      if (addressText != null) 'address_text': addressText,
      if (pinLat != null) 'pin_lat': pinLat,
      if (pinLng != null) 'pin_lng': pinLng,
      if (pinUrl != null) 'pin_url': pinUrl,
      if (trackingUrl != null) 'tracking_url': trackingUrl,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (deliveryCharge != null) 'delivery_charge': deliveryCharge,
      if (requirements != null) 'requirements': requirements,
      if (itemMessage != null) 'item_message': itemMessage,
      if (dietaryFlags != null) 'dietary_flags': dietaryFlags,
      if (requirementsChangedAt != null)
        'requirements_changed_at': requirementsChangedAt,
      if (requirementsAckAt != null) 'requirements_ack_at': requirementsAckAt,
      if (source != null) 'source': source,
      if (notes != null) 'notes': notes,
      if (cancelReason != null) 'cancel_reason': cancelReason,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String?>? fieldHlcJson,
    Value<String>? orderNo,
    Value<String>? customerId,
    Value<String>? status,
    Value<String>? fulfilment,
    Value<int>? deliveryDate,
    Value<int?>? deliveryTime,
    Value<String?>? deliveryType,
    Value<String?>? addressText,
    Value<double?>? pinLat,
    Value<double?>? pinLng,
    Value<String?>? pinUrl,
    Value<String?>? trackingUrl,
    Value<String?>? discountType,
    Value<int?>? discountValue,
    Value<int>? discountAmount,
    Value<int>? deliveryCharge,
    Value<String?>? requirements,
    Value<String?>? itemMessage,
    Value<int>? dietaryFlags,
    Value<int?>? requirementsChangedAt,
    Value<int?>? requirementsAckAt,
    Value<String?>? source,
    Value<String?>? notes,
    Value<String?>? cancelReason,
    Value<int?>? deliveredAt,
    Value<int?>? confirmedAt,
    Value<int?>? completedAt,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      fieldHlcJson: fieldHlcJson ?? this.fieldHlcJson,
      orderNo: orderNo ?? this.orderNo,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      fulfilment: fulfilment ?? this.fulfilment,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryType: deliveryType ?? this.deliveryType,
      addressText: addressText ?? this.addressText,
      pinLat: pinLat ?? this.pinLat,
      pinLng: pinLng ?? this.pinLng,
      pinUrl: pinUrl ?? this.pinUrl,
      trackingUrl: trackingUrl ?? this.trackingUrl,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      requirements: requirements ?? this.requirements,
      itemMessage: itemMessage ?? this.itemMessage,
      dietaryFlags: dietaryFlags ?? this.dietaryFlags,
      requirementsChangedAt:
          requirementsChangedAt ?? this.requirementsChangedAt,
      requirementsAckAt: requirementsAckAt ?? this.requirementsAckAt,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      cancelReason: cancelReason ?? this.cancelReason,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (fieldHlcJson.present) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson.value);
    }
    if (orderNo.present) {
      map['order_no'] = Variable<String>(orderNo.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fulfilment.present) {
      map['fulfilment'] = Variable<String>(fulfilment.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<int>(deliveryDate.value);
    }
    if (deliveryTime.present) {
      map['delivery_time'] = Variable<int>(deliveryTime.value);
    }
    if (deliveryType.present) {
      map['delivery_type'] = Variable<String>(deliveryType.value);
    }
    if (addressText.present) {
      map['address_text'] = Variable<String>(addressText.value);
    }
    if (pinLat.present) {
      map['pin_lat'] = Variable<double>(pinLat.value);
    }
    if (pinLng.present) {
      map['pin_lng'] = Variable<double>(pinLng.value);
    }
    if (pinUrl.present) {
      map['pin_url'] = Variable<String>(pinUrl.value);
    }
    if (trackingUrl.present) {
      map['tracking_url'] = Variable<String>(trackingUrl.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<int>(discountValue.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<int>(discountAmount.value);
    }
    if (deliveryCharge.present) {
      map['delivery_charge'] = Variable<int>(deliveryCharge.value);
    }
    if (requirements.present) {
      map['requirements'] = Variable<String>(requirements.value);
    }
    if (itemMessage.present) {
      map['item_message'] = Variable<String>(itemMessage.value);
    }
    if (dietaryFlags.present) {
      map['dietary_flags'] = Variable<int>(dietaryFlags.value);
    }
    if (requirementsChangedAt.present) {
      map['requirements_changed_at'] = Variable<int>(
        requirementsChangedAt.value,
      );
    }
    if (requirementsAckAt.present) {
      map['requirements_ack_at'] = Variable<int>(requirementsAckAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (cancelReason.present) {
      map['cancel_reason'] = Variable<String>(cancelReason.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<int>(deliveredAt.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<int>(confirmedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('orderNo: $orderNo, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('fulfilment: $fulfilment, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('addressText: $addressText, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinUrl: $pinUrl, ')
          ..write('trackingUrl: $trackingUrl, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('deliveryCharge: $deliveryCharge, ')
          ..write('requirements: $requirements, ')
          ..write('itemMessage: $itemMessage, ')
          ..write('dietaryFlags: $dietaryFlags, ')
          ..write('requirementsChangedAt: $requirementsChangedAt, ')
          ..write('requirementsAckAt: $requirementsAckAt, ')
          ..write('source: $source, ')
          ..write('notes: $notes, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubOrdersTable extends SubOrders
    with TableInfo<$SubOrdersTable, SubOrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id)',
    ),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('created'),
  );
  static const VerificationMeta _deliveryDateMeta = const VerificationMeta(
    'deliveryDate',
  );
  @override
  late final GeneratedColumn<int> deliveryDate = GeneratedColumn<int>(
    'delivery_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryTimeMeta = const VerificationMeta(
    'deliveryTime',
  );
  @override
  late final GeneratedColumn<int> deliveryTime = GeneratedColumn<int>(
    'delivery_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fulfilmentMeta = const VerificationMeta(
    'fulfilment',
  );
  @override
  late final GeneratedColumn<String> fulfilment = GeneratedColumn<String>(
    'fulfilment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryTypeMeta = const VerificationMeta(
    'deliveryType',
  );
  @override
  late final GeneratedColumn<String> deliveryType = GeneratedColumn<String>(
    'delivery_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressTextMeta = const VerificationMeta(
    'addressText',
  );
  @override
  late final GeneratedColumn<String> addressText = GeneratedColumn<String>(
    'address_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinLatMeta = const VerificationMeta('pinLat');
  @override
  late final GeneratedColumn<double> pinLat = GeneratedColumn<double>(
    'pin_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinLngMeta = const VerificationMeta('pinLng');
  @override
  late final GeneratedColumn<double> pinLng = GeneratedColumn<double>(
    'pin_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinUrlMeta = const VerificationMeta('pinUrl');
  @override
  late final GeneratedColumn<String> pinUrl = GeneratedColumn<String>(
    'pin_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryChargeMeta = const VerificationMeta(
    'deliveryCharge',
  );
  @override
  late final GeneratedColumn<int> deliveryCharge = GeneratedColumn<int>(
    'delivery_charge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _trackingUrlMeta = const VerificationMeta(
    'trackingUrl',
  );
  @override
  late final GeneratedColumn<String> trackingUrl = GeneratedColumn<String>(
    'tracking_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<int> deliveredAt = GeneratedColumn<int>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    seq,
    status,
    deliveryDate,
    deliveryTime,
    fulfilment,
    deliveryType,
    addressText,
    pinLat,
    pinLng,
    pinUrl,
    deliveryCharge,
    trackingUrl,
    deliveredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sub_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubOrderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
        _deliveryDateMeta,
        deliveryDate.isAcceptableOrUnknown(
          data['delivery_date']!,
          _deliveryDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deliveryDateMeta);
    }
    if (data.containsKey('delivery_time')) {
      context.handle(
        _deliveryTimeMeta,
        deliveryTime.isAcceptableOrUnknown(
          data['delivery_time']!,
          _deliveryTimeMeta,
        ),
      );
    }
    if (data.containsKey('fulfilment')) {
      context.handle(
        _fulfilmentMeta,
        fulfilment.isAcceptableOrUnknown(data['fulfilment']!, _fulfilmentMeta),
      );
    } else if (isInserting) {
      context.missing(_fulfilmentMeta);
    }
    if (data.containsKey('delivery_type')) {
      context.handle(
        _deliveryTypeMeta,
        deliveryType.isAcceptableOrUnknown(
          data['delivery_type']!,
          _deliveryTypeMeta,
        ),
      );
    }
    if (data.containsKey('address_text')) {
      context.handle(
        _addressTextMeta,
        addressText.isAcceptableOrUnknown(
          data['address_text']!,
          _addressTextMeta,
        ),
      );
    }
    if (data.containsKey('pin_lat')) {
      context.handle(
        _pinLatMeta,
        pinLat.isAcceptableOrUnknown(data['pin_lat']!, _pinLatMeta),
      );
    }
    if (data.containsKey('pin_lng')) {
      context.handle(
        _pinLngMeta,
        pinLng.isAcceptableOrUnknown(data['pin_lng']!, _pinLngMeta),
      );
    }
    if (data.containsKey('pin_url')) {
      context.handle(
        _pinUrlMeta,
        pinUrl.isAcceptableOrUnknown(data['pin_url']!, _pinUrlMeta),
      );
    }
    if (data.containsKey('delivery_charge')) {
      context.handle(
        _deliveryChargeMeta,
        deliveryCharge.isAcceptableOrUnknown(
          data['delivery_charge']!,
          _deliveryChargeMeta,
        ),
      );
    }
    if (data.containsKey('tracking_url')) {
      context.handle(
        _trackingUrlMeta,
        trackingUrl.isAcceptableOrUnknown(
          data['tracking_url']!,
          _trackingUrlMeta,
        ),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubOrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubOrderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      deliveryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_date'],
      )!,
      deliveryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_time'],
      ),
      fulfilment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fulfilment'],
      )!,
      deliveryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_type'],
      ),
      addressText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_text'],
      ),
      pinLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pin_lat'],
      ),
      pinLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pin_lng'],
      ),
      pinUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_url'],
      ),
      deliveryCharge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_charge'],
      )!,
      trackingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_url'],
      ),
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivered_at'],
      ),
    );
  }

  @override
  $SubOrdersTable createAlias(String alias) {
    return $SubOrdersTable(attachedDatabase, alias);
  }
}

class SubOrderRow extends DataClass implements Insertable<SubOrderRow> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderId;

  /// 1, 2, 3 … within the order, so the kitchen can say "LLB-0001-67FR-2".
  ///
  /// **Spent, never reused.** A sub-order that empties takes its number with
  /// it: a number that comes back meaning something else is worse than a gap.
  /// It never appears in a customer message — the customer bought one order.
  final int seq;
  final String status;
  final int deliveryDate;
  final int? deliveryTime;
  final String fulfilment;
  final String? deliveryType;
  final String? addressText;
  final double? pinLat;
  final double? pinLng;
  final String? pinUrl;

  /// One journey, one charge, however many boxes are in it. The order's own
  /// charge is the sum across its sub-orders.
  final int deliveryCharge;
  final String? trackingUrl;
  final int? deliveredAt;
  const SubOrderRow({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderId,
    required this.seq,
    required this.status,
    required this.deliveryDate,
    this.deliveryTime,
    required this.fulfilment,
    this.deliveryType,
    this.addressText,
    this.pinLat,
    this.pinLng,
    this.pinUrl,
    required this.deliveryCharge,
    this.trackingUrl,
    this.deliveredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['seq'] = Variable<int>(seq);
    map['status'] = Variable<String>(status);
    map['delivery_date'] = Variable<int>(deliveryDate);
    if (!nullToAbsent || deliveryTime != null) {
      map['delivery_time'] = Variable<int>(deliveryTime);
    }
    map['fulfilment'] = Variable<String>(fulfilment);
    if (!nullToAbsent || deliveryType != null) {
      map['delivery_type'] = Variable<String>(deliveryType);
    }
    if (!nullToAbsent || addressText != null) {
      map['address_text'] = Variable<String>(addressText);
    }
    if (!nullToAbsent || pinLat != null) {
      map['pin_lat'] = Variable<double>(pinLat);
    }
    if (!nullToAbsent || pinLng != null) {
      map['pin_lng'] = Variable<double>(pinLng);
    }
    if (!nullToAbsent || pinUrl != null) {
      map['pin_url'] = Variable<String>(pinUrl);
    }
    map['delivery_charge'] = Variable<int>(deliveryCharge);
    if (!nullToAbsent || trackingUrl != null) {
      map['tracking_url'] = Variable<String>(trackingUrl);
    }
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<int>(deliveredAt);
    }
    return map;
  }

  SubOrdersCompanion toCompanion(bool nullToAbsent) {
    return SubOrdersCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      seq: Value(seq),
      status: Value(status),
      deliveryDate: Value(deliveryDate),
      deliveryTime: deliveryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryTime),
      fulfilment: Value(fulfilment),
      deliveryType: deliveryType == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryType),
      addressText: addressText == null && nullToAbsent
          ? const Value.absent()
          : Value(addressText),
      pinLat: pinLat == null && nullToAbsent
          ? const Value.absent()
          : Value(pinLat),
      pinLng: pinLng == null && nullToAbsent
          ? const Value.absent()
          : Value(pinLng),
      pinUrl: pinUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pinUrl),
      deliveryCharge: Value(deliveryCharge),
      trackingUrl: trackingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingUrl),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
    );
  }

  factory SubOrderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubOrderRow(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      seq: serializer.fromJson<int>(json['seq']),
      status: serializer.fromJson<String>(json['status']),
      deliveryDate: serializer.fromJson<int>(json['deliveryDate']),
      deliveryTime: serializer.fromJson<int?>(json['deliveryTime']),
      fulfilment: serializer.fromJson<String>(json['fulfilment']),
      deliveryType: serializer.fromJson<String?>(json['deliveryType']),
      addressText: serializer.fromJson<String?>(json['addressText']),
      pinLat: serializer.fromJson<double?>(json['pinLat']),
      pinLng: serializer.fromJson<double?>(json['pinLng']),
      pinUrl: serializer.fromJson<String?>(json['pinUrl']),
      deliveryCharge: serializer.fromJson<int>(json['deliveryCharge']),
      trackingUrl: serializer.fromJson<String?>(json['trackingUrl']),
      deliveredAt: serializer.fromJson<int?>(json['deliveredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'seq': serializer.toJson<int>(seq),
      'status': serializer.toJson<String>(status),
      'deliveryDate': serializer.toJson<int>(deliveryDate),
      'deliveryTime': serializer.toJson<int?>(deliveryTime),
      'fulfilment': serializer.toJson<String>(fulfilment),
      'deliveryType': serializer.toJson<String?>(deliveryType),
      'addressText': serializer.toJson<String?>(addressText),
      'pinLat': serializer.toJson<double?>(pinLat),
      'pinLng': serializer.toJson<double?>(pinLng),
      'pinUrl': serializer.toJson<String?>(pinUrl),
      'deliveryCharge': serializer.toJson<int>(deliveryCharge),
      'trackingUrl': serializer.toJson<String?>(trackingUrl),
      'deliveredAt': serializer.toJson<int?>(deliveredAt),
    };
  }

  SubOrderRow copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderId,
    int? seq,
    String? status,
    int? deliveryDate,
    Value<int?> deliveryTime = const Value.absent(),
    String? fulfilment,
    Value<String?> deliveryType = const Value.absent(),
    Value<String?> addressText = const Value.absent(),
    Value<double?> pinLat = const Value.absent(),
    Value<double?> pinLng = const Value.absent(),
    Value<String?> pinUrl = const Value.absent(),
    int? deliveryCharge,
    Value<String?> trackingUrl = const Value.absent(),
    Value<int?> deliveredAt = const Value.absent(),
  }) => SubOrderRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    seq: seq ?? this.seq,
    status: status ?? this.status,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    deliveryTime: deliveryTime.present ? deliveryTime.value : this.deliveryTime,
    fulfilment: fulfilment ?? this.fulfilment,
    deliveryType: deliveryType.present ? deliveryType.value : this.deliveryType,
    addressText: addressText.present ? addressText.value : this.addressText,
    pinLat: pinLat.present ? pinLat.value : this.pinLat,
    pinLng: pinLng.present ? pinLng.value : this.pinLng,
    pinUrl: pinUrl.present ? pinUrl.value : this.pinUrl,
    deliveryCharge: deliveryCharge ?? this.deliveryCharge,
    trackingUrl: trackingUrl.present ? trackingUrl.value : this.trackingUrl,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
  );
  SubOrderRow copyWithCompanion(SubOrdersCompanion data) {
    return SubOrderRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      seq: data.seq.present ? data.seq.value : this.seq,
      status: data.status.present ? data.status.value : this.status,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      deliveryTime: data.deliveryTime.present
          ? data.deliveryTime.value
          : this.deliveryTime,
      fulfilment: data.fulfilment.present
          ? data.fulfilment.value
          : this.fulfilment,
      deliveryType: data.deliveryType.present
          ? data.deliveryType.value
          : this.deliveryType,
      addressText: data.addressText.present
          ? data.addressText.value
          : this.addressText,
      pinLat: data.pinLat.present ? data.pinLat.value : this.pinLat,
      pinLng: data.pinLng.present ? data.pinLng.value : this.pinLng,
      pinUrl: data.pinUrl.present ? data.pinUrl.value : this.pinUrl,
      deliveryCharge: data.deliveryCharge.present
          ? data.deliveryCharge.value
          : this.deliveryCharge,
      trackingUrl: data.trackingUrl.present
          ? data.trackingUrl.value
          : this.trackingUrl,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubOrderRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('seq: $seq, ')
          ..write('status: $status, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('fulfilment: $fulfilment, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('addressText: $addressText, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinUrl: $pinUrl, ')
          ..write('deliveryCharge: $deliveryCharge, ')
          ..write('trackingUrl: $trackingUrl, ')
          ..write('deliveredAt: $deliveredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    seq,
    status,
    deliveryDate,
    deliveryTime,
    fulfilment,
    deliveryType,
    addressText,
    pinLat,
    pinLng,
    pinUrl,
    deliveryCharge,
    trackingUrl,
    deliveredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubOrderRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.seq == this.seq &&
          other.status == this.status &&
          other.deliveryDate == this.deliveryDate &&
          other.deliveryTime == this.deliveryTime &&
          other.fulfilment == this.fulfilment &&
          other.deliveryType == this.deliveryType &&
          other.addressText == this.addressText &&
          other.pinLat == this.pinLat &&
          other.pinLng == this.pinLng &&
          other.pinUrl == this.pinUrl &&
          other.deliveryCharge == this.deliveryCharge &&
          other.trackingUrl == this.trackingUrl &&
          other.deliveredAt == this.deliveredAt);
}

class SubOrdersCompanion extends UpdateCompanion<SubOrderRow> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderId;
  final Value<int> seq;
  final Value<String> status;
  final Value<int> deliveryDate;
  final Value<int?> deliveryTime;
  final Value<String> fulfilment;
  final Value<String?> deliveryType;
  final Value<String?> addressText;
  final Value<double?> pinLat;
  final Value<double?> pinLng;
  final Value<String?> pinUrl;
  final Value<int> deliveryCharge;
  final Value<String?> trackingUrl;
  final Value<int?> deliveredAt;
  final Value<int> rowid;
  const SubOrdersCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.seq = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.deliveryTime = const Value.absent(),
    this.fulfilment = const Value.absent(),
    this.deliveryType = const Value.absent(),
    this.addressText = const Value.absent(),
    this.pinLat = const Value.absent(),
    this.pinLng = const Value.absent(),
    this.pinUrl = const Value.absent(),
    this.deliveryCharge = const Value.absent(),
    this.trackingUrl = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubOrdersCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderId,
    required int seq,
    this.status = const Value.absent(),
    required int deliveryDate,
    this.deliveryTime = const Value.absent(),
    required String fulfilment,
    this.deliveryType = const Value.absent(),
    this.addressText = const Value.absent(),
    this.pinLat = const Value.absent(),
    this.pinLng = const Value.absent(),
    this.pinUrl = const Value.absent(),
    this.deliveryCharge = const Value.absent(),
    this.trackingUrl = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderId = Value(orderId),
       seq = Value(seq),
       deliveryDate = Value(deliveryDate),
       fulfilment = Value(fulfilment);
  static Insertable<SubOrderRow> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderId,
    Expression<int>? seq,
    Expression<String>? status,
    Expression<int>? deliveryDate,
    Expression<int>? deliveryTime,
    Expression<String>? fulfilment,
    Expression<String>? deliveryType,
    Expression<String>? addressText,
    Expression<double>? pinLat,
    Expression<double>? pinLng,
    Expression<String>? pinUrl,
    Expression<int>? deliveryCharge,
    Expression<String>? trackingUrl,
    Expression<int>? deliveredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (seq != null) 'seq': seq,
      if (status != null) 'status': status,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (deliveryTime != null) 'delivery_time': deliveryTime,
      if (fulfilment != null) 'fulfilment': fulfilment,
      if (deliveryType != null) 'delivery_type': deliveryType,
      if (addressText != null) 'address_text': addressText,
      if (pinLat != null) 'pin_lat': pinLat,
      if (pinLng != null) 'pin_lng': pinLng,
      if (pinUrl != null) 'pin_url': pinUrl,
      if (deliveryCharge != null) 'delivery_charge': deliveryCharge,
      if (trackingUrl != null) 'tracking_url': trackingUrl,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderId,
    Value<int>? seq,
    Value<String>? status,
    Value<int>? deliveryDate,
    Value<int?>? deliveryTime,
    Value<String>? fulfilment,
    Value<String?>? deliveryType,
    Value<String?>? addressText,
    Value<double?>? pinLat,
    Value<double?>? pinLng,
    Value<String?>? pinUrl,
    Value<int>? deliveryCharge,
    Value<String?>? trackingUrl,
    Value<int?>? deliveredAt,
    Value<int>? rowid,
  }) {
    return SubOrdersCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      seq: seq ?? this.seq,
      status: status ?? this.status,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      fulfilment: fulfilment ?? this.fulfilment,
      deliveryType: deliveryType ?? this.deliveryType,
      addressText: addressText ?? this.addressText,
      pinLat: pinLat ?? this.pinLat,
      pinLng: pinLng ?? this.pinLng,
      pinUrl: pinUrl ?? this.pinUrl,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      trackingUrl: trackingUrl ?? this.trackingUrl,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<int>(deliveryDate.value);
    }
    if (deliveryTime.present) {
      map['delivery_time'] = Variable<int>(deliveryTime.value);
    }
    if (fulfilment.present) {
      map['fulfilment'] = Variable<String>(fulfilment.value);
    }
    if (deliveryType.present) {
      map['delivery_type'] = Variable<String>(deliveryType.value);
    }
    if (addressText.present) {
      map['address_text'] = Variable<String>(addressText.value);
    }
    if (pinLat.present) {
      map['pin_lat'] = Variable<double>(pinLat.value);
    }
    if (pinLng.present) {
      map['pin_lng'] = Variable<double>(pinLng.value);
    }
    if (pinUrl.present) {
      map['pin_url'] = Variable<String>(pinUrl.value);
    }
    if (deliveryCharge.present) {
      map['delivery_charge'] = Variable<int>(deliveryCharge.value);
    }
    if (trackingUrl.present) {
      map['tracking_url'] = Variable<String>(trackingUrl.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<int>(deliveredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubOrdersCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('seq: $seq, ')
          ..write('status: $status, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('fulfilment: $fulfilment, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('addressText: $addressText, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinUrl: $pinUrl, ')
          ..write('deliveryCharge: $deliveryCharge, ')
          ..write('trackingUrl: $trackingUrl, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id)',
    ),
  );
  static const VerificationMeta _menuItemIdMeta = const VerificationMeta(
    'menuItemId',
  );
  @override
  late final GeneratedColumn<String> menuItemId = GeneratedColumn<String>(
    'menu_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES menu_items (id)',
    ),
  );
  static const VerificationMeta _itemNameSnapshotMeta = const VerificationMeta(
    'itemNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> itemNameSnapshot = GeneratedColumn<String>(
    'item_name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flavourMeta = const VerificationMeta(
    'flavour',
  );
  @override
  late final GeneratedColumn<String> flavour = GeneratedColumn<String>(
    'flavour',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightValueMeta = const VerificationMeta(
    'weightValue',
  );
  @override
  late final GeneratedColumn<double> weightValue = GeneratedColumn<double>(
    'weight_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightUnitMeta = const VerificationMeta(
    'weightUnit',
  );
  @override
  late final GeneratedColumn<String> weightUnit = GeneratedColumn<String>(
    'weight_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _basePriceMeta = const VerificationMeta(
    'basePrice',
  );
  @override
  late final GeneratedColumn<int> basePrice = GeneratedColumn<int>(
    'base_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subOrderIdMeta = const VerificationMeta(
    'subOrderId',
  );
  @override
  late final GeneratedColumn<String> subOrderId = GeneratedColumn<String>(
    'sub_order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sub_orders (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('created'),
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<int> deliveredAt = GeneratedColumn<int>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelReasonMeta = const VerificationMeta(
    'cancelReason',
  );
  @override
  late final GeneratedColumn<String> cancelReason = GeneratedColumn<String>(
    'cancel_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemMessageMeta = const VerificationMeta(
    'itemMessage',
  );
  @override
  late final GeneratedColumn<String> itemMessage = GeneratedColumn<String>(
    'item_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requirementsMeta = const VerificationMeta(
    'requirements',
  );
  @override
  late final GeneratedColumn<String> requirements = GeneratedColumn<String>(
    'requirements',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dietaryFlagsMeta = const VerificationMeta(
    'dietaryFlags',
  );
  @override
  late final GeneratedColumn<int> dietaryFlags = GeneratedColumn<int>(
    'dietary_flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<int> discountValue = GeneratedColumn<int>(
    'discount_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    menuItemId,
    itemNameSnapshot,
    flavour,
    weightValue,
    weightUnit,
    qty,
    basePrice,
    note,
    position,
    subOrderId,
    status,
    deliveredAt,
    cancelReason,
    itemMessage,
    requirements,
    dietaryFlags,
    discountType,
    discountValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('menu_item_id')) {
      context.handle(
        _menuItemIdMeta,
        menuItemId.isAcceptableOrUnknown(
          data['menu_item_id']!,
          _menuItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_menuItemIdMeta);
    }
    if (data.containsKey('item_name_snapshot')) {
      context.handle(
        _itemNameSnapshotMeta,
        itemNameSnapshot.isAcceptableOrUnknown(
          data['item_name_snapshot']!,
          _itemNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_itemNameSnapshotMeta);
    }
    if (data.containsKey('flavour')) {
      context.handle(
        _flavourMeta,
        flavour.isAcceptableOrUnknown(data['flavour']!, _flavourMeta),
      );
    }
    if (data.containsKey('weight_value')) {
      context.handle(
        _weightValueMeta,
        weightValue.isAcceptableOrUnknown(
          data['weight_value']!,
          _weightValueMeta,
        ),
      );
    }
    if (data.containsKey('weight_unit')) {
      context.handle(
        _weightUnitMeta,
        weightUnit.isAcceptableOrUnknown(data['weight_unit']!, _weightUnitMeta),
      );
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('base_price')) {
      context.handle(
        _basePriceMeta,
        basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_basePriceMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('sub_order_id')) {
      context.handle(
        _subOrderIdMeta,
        subOrderId.isAcceptableOrUnknown(
          data['sub_order_id']!,
          _subOrderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subOrderIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('cancel_reason')) {
      context.handle(
        _cancelReasonMeta,
        cancelReason.isAcceptableOrUnknown(
          data['cancel_reason']!,
          _cancelReasonMeta,
        ),
      );
    }
    if (data.containsKey('item_message')) {
      context.handle(
        _itemMessageMeta,
        itemMessage.isAcceptableOrUnknown(
          data['item_message']!,
          _itemMessageMeta,
        ),
      );
    }
    if (data.containsKey('requirements')) {
      context.handle(
        _requirementsMeta,
        requirements.isAcceptableOrUnknown(
          data['requirements']!,
          _requirementsMeta,
        ),
      );
    }
    if (data.containsKey('dietary_flags')) {
      context.handle(
        _dietaryFlagsMeta,
        dietaryFlags.isAcceptableOrUnknown(
          data['dietary_flags']!,
          _dietaryFlagsMeta,
        ),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      menuItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_item_id'],
      )!,
      itemNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name_snapshot'],
      )!,
      flavour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavour'],
      ),
      weightValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_value'],
      ),
      weightUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_unit'],
      ),
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      basePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_price'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      subOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_order_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivered_at'],
      ),
      cancelReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancel_reason'],
      ),
      itemMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_message'],
      ),
      requirements: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requirements'],
      ),
      dietaryFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dietary_flags'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      ),
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_value'],
      )!,
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItem extends DataClass implements Insertable<OrderItem> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderId;
  final String menuItemId;
  final String itemNameSnapshot;
  final String? flavour;
  final double? weightValue;
  final String? weightUnit;
  final int qty;
  final int basePrice;
  final String? note;
  final int position;
  final String subOrderId;
  final String status;
  final int? deliveredAt;
  final String? cancelReason;
  final String? itemMessage;
  final String? requirements;
  final int dietaryFlags;
  final String? discountType;
  final int discountValue;
  const OrderItem({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderId,
    required this.menuItemId,
    required this.itemNameSnapshot,
    this.flavour,
    this.weightValue,
    this.weightUnit,
    required this.qty,
    required this.basePrice,
    this.note,
    required this.position,
    required this.subOrderId,
    required this.status,
    this.deliveredAt,
    this.cancelReason,
    this.itemMessage,
    this.requirements,
    required this.dietaryFlags,
    this.discountType,
    required this.discountValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['menu_item_id'] = Variable<String>(menuItemId);
    map['item_name_snapshot'] = Variable<String>(itemNameSnapshot);
    if (!nullToAbsent || flavour != null) {
      map['flavour'] = Variable<String>(flavour);
    }
    if (!nullToAbsent || weightValue != null) {
      map['weight_value'] = Variable<double>(weightValue);
    }
    if (!nullToAbsent || weightUnit != null) {
      map['weight_unit'] = Variable<String>(weightUnit);
    }
    map['qty'] = Variable<int>(qty);
    map['base_price'] = Variable<int>(basePrice);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['position'] = Variable<int>(position);
    map['sub_order_id'] = Variable<String>(subOrderId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<int>(deliveredAt);
    }
    if (!nullToAbsent || cancelReason != null) {
      map['cancel_reason'] = Variable<String>(cancelReason);
    }
    if (!nullToAbsent || itemMessage != null) {
      map['item_message'] = Variable<String>(itemMessage);
    }
    if (!nullToAbsent || requirements != null) {
      map['requirements'] = Variable<String>(requirements);
    }
    map['dietary_flags'] = Variable<int>(dietaryFlags);
    if (!nullToAbsent || discountType != null) {
      map['discount_type'] = Variable<String>(discountType);
    }
    map['discount_value'] = Variable<int>(discountValue);
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      menuItemId: Value(menuItemId),
      itemNameSnapshot: Value(itemNameSnapshot),
      flavour: flavour == null && nullToAbsent
          ? const Value.absent()
          : Value(flavour),
      weightValue: weightValue == null && nullToAbsent
          ? const Value.absent()
          : Value(weightValue),
      weightUnit: weightUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(weightUnit),
      qty: Value(qty),
      basePrice: Value(basePrice),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      position: Value(position),
      subOrderId: Value(subOrderId),
      status: Value(status),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      cancelReason: cancelReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelReason),
      itemMessage: itemMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(itemMessage),
      requirements: requirements == null && nullToAbsent
          ? const Value.absent()
          : Value(requirements),
      dietaryFlags: Value(dietaryFlags),
      discountType: discountType == null && nullToAbsent
          ? const Value.absent()
          : Value(discountType),
      discountValue: Value(discountValue),
    );
  }

  factory OrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItem(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      menuItemId: serializer.fromJson<String>(json['menuItemId']),
      itemNameSnapshot: serializer.fromJson<String>(json['itemNameSnapshot']),
      flavour: serializer.fromJson<String?>(json['flavour']),
      weightValue: serializer.fromJson<double?>(json['weightValue']),
      weightUnit: serializer.fromJson<String?>(json['weightUnit']),
      qty: serializer.fromJson<int>(json['qty']),
      basePrice: serializer.fromJson<int>(json['basePrice']),
      note: serializer.fromJson<String?>(json['note']),
      position: serializer.fromJson<int>(json['position']),
      subOrderId: serializer.fromJson<String>(json['subOrderId']),
      status: serializer.fromJson<String>(json['status']),
      deliveredAt: serializer.fromJson<int?>(json['deliveredAt']),
      cancelReason: serializer.fromJson<String?>(json['cancelReason']),
      itemMessage: serializer.fromJson<String?>(json['itemMessage']),
      requirements: serializer.fromJson<String?>(json['requirements']),
      dietaryFlags: serializer.fromJson<int>(json['dietaryFlags']),
      discountType: serializer.fromJson<String?>(json['discountType']),
      discountValue: serializer.fromJson<int>(json['discountValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'menuItemId': serializer.toJson<String>(menuItemId),
      'itemNameSnapshot': serializer.toJson<String>(itemNameSnapshot),
      'flavour': serializer.toJson<String?>(flavour),
      'weightValue': serializer.toJson<double?>(weightValue),
      'weightUnit': serializer.toJson<String?>(weightUnit),
      'qty': serializer.toJson<int>(qty),
      'basePrice': serializer.toJson<int>(basePrice),
      'note': serializer.toJson<String?>(note),
      'position': serializer.toJson<int>(position),
      'subOrderId': serializer.toJson<String>(subOrderId),
      'status': serializer.toJson<String>(status),
      'deliveredAt': serializer.toJson<int?>(deliveredAt),
      'cancelReason': serializer.toJson<String?>(cancelReason),
      'itemMessage': serializer.toJson<String?>(itemMessage),
      'requirements': serializer.toJson<String?>(requirements),
      'dietaryFlags': serializer.toJson<int>(dietaryFlags),
      'discountType': serializer.toJson<String?>(discountType),
      'discountValue': serializer.toJson<int>(discountValue),
    };
  }

  OrderItem copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderId,
    String? menuItemId,
    String? itemNameSnapshot,
    Value<String?> flavour = const Value.absent(),
    Value<double?> weightValue = const Value.absent(),
    Value<String?> weightUnit = const Value.absent(),
    int? qty,
    int? basePrice,
    Value<String?> note = const Value.absent(),
    int? position,
    String? subOrderId,
    String? status,
    Value<int?> deliveredAt = const Value.absent(),
    Value<String?> cancelReason = const Value.absent(),
    Value<String?> itemMessage = const Value.absent(),
    Value<String?> requirements = const Value.absent(),
    int? dietaryFlags,
    Value<String?> discountType = const Value.absent(),
    int? discountValue,
  }) => OrderItem(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    menuItemId: menuItemId ?? this.menuItemId,
    itemNameSnapshot: itemNameSnapshot ?? this.itemNameSnapshot,
    flavour: flavour.present ? flavour.value : this.flavour,
    weightValue: weightValue.present ? weightValue.value : this.weightValue,
    weightUnit: weightUnit.present ? weightUnit.value : this.weightUnit,
    qty: qty ?? this.qty,
    basePrice: basePrice ?? this.basePrice,
    note: note.present ? note.value : this.note,
    position: position ?? this.position,
    subOrderId: subOrderId ?? this.subOrderId,
    status: status ?? this.status,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    cancelReason: cancelReason.present ? cancelReason.value : this.cancelReason,
    itemMessage: itemMessage.present ? itemMessage.value : this.itemMessage,
    requirements: requirements.present ? requirements.value : this.requirements,
    dietaryFlags: dietaryFlags ?? this.dietaryFlags,
    discountType: discountType.present ? discountType.value : this.discountType,
    discountValue: discountValue ?? this.discountValue,
  );
  OrderItem copyWithCompanion(OrderItemsCompanion data) {
    return OrderItem(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      menuItemId: data.menuItemId.present
          ? data.menuItemId.value
          : this.menuItemId,
      itemNameSnapshot: data.itemNameSnapshot.present
          ? data.itemNameSnapshot.value
          : this.itemNameSnapshot,
      flavour: data.flavour.present ? data.flavour.value : this.flavour,
      weightValue: data.weightValue.present
          ? data.weightValue.value
          : this.weightValue,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      qty: data.qty.present ? data.qty.value : this.qty,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      note: data.note.present ? data.note.value : this.note,
      position: data.position.present ? data.position.value : this.position,
      subOrderId: data.subOrderId.present
          ? data.subOrderId.value
          : this.subOrderId,
      status: data.status.present ? data.status.value : this.status,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      cancelReason: data.cancelReason.present
          ? data.cancelReason.value
          : this.cancelReason,
      itemMessage: data.itemMessage.present
          ? data.itemMessage.value
          : this.itemMessage,
      requirements: data.requirements.present
          ? data.requirements.value
          : this.requirements,
      dietaryFlags: data.dietaryFlags.present
          ? data.dietaryFlags.value
          : this.dietaryFlags,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItem(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('itemNameSnapshot: $itemNameSnapshot, ')
          ..write('flavour: $flavour, ')
          ..write('weightValue: $weightValue, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('qty: $qty, ')
          ..write('basePrice: $basePrice, ')
          ..write('note: $note, ')
          ..write('position: $position, ')
          ..write('subOrderId: $subOrderId, ')
          ..write('status: $status, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('itemMessage: $itemMessage, ')
          ..write('requirements: $requirements, ')
          ..write('dietaryFlags: $dietaryFlags, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    menuItemId,
    itemNameSnapshot,
    flavour,
    weightValue,
    weightUnit,
    qty,
    basePrice,
    note,
    position,
    subOrderId,
    status,
    deliveredAt,
    cancelReason,
    itemMessage,
    requirements,
    dietaryFlags,
    discountType,
    discountValue,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItem &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.menuItemId == this.menuItemId &&
          other.itemNameSnapshot == this.itemNameSnapshot &&
          other.flavour == this.flavour &&
          other.weightValue == this.weightValue &&
          other.weightUnit == this.weightUnit &&
          other.qty == this.qty &&
          other.basePrice == this.basePrice &&
          other.note == this.note &&
          other.position == this.position &&
          other.subOrderId == this.subOrderId &&
          other.status == this.status &&
          other.deliveredAt == this.deliveredAt &&
          other.cancelReason == this.cancelReason &&
          other.itemMessage == this.itemMessage &&
          other.requirements == this.requirements &&
          other.dietaryFlags == this.dietaryFlags &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItem> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderId;
  final Value<String> menuItemId;
  final Value<String> itemNameSnapshot;
  final Value<String?> flavour;
  final Value<double?> weightValue;
  final Value<String?> weightUnit;
  final Value<int> qty;
  final Value<int> basePrice;
  final Value<String?> note;
  final Value<int> position;
  final Value<String> subOrderId;
  final Value<String> status;
  final Value<int?> deliveredAt;
  final Value<String?> cancelReason;
  final Value<String?> itemMessage;
  final Value<String?> requirements;
  final Value<int> dietaryFlags;
  final Value<String?> discountType;
  final Value<int> discountValue;
  final Value<int> rowid;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.menuItemId = const Value.absent(),
    this.itemNameSnapshot = const Value.absent(),
    this.flavour = const Value.absent(),
    this.weightValue = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.qty = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.note = const Value.absent(),
    this.position = const Value.absent(),
    this.subOrderId = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.itemMessage = const Value.absent(),
    this.requirements = const Value.absent(),
    this.dietaryFlags = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderId,
    required String menuItemId,
    required String itemNameSnapshot,
    this.flavour = const Value.absent(),
    this.weightValue = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.qty = const Value.absent(),
    required int basePrice,
    this.note = const Value.absent(),
    required int position,
    required String subOrderId,
    this.status = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.itemMessage = const Value.absent(),
    this.requirements = const Value.absent(),
    this.dietaryFlags = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderId = Value(orderId),
       menuItemId = Value(menuItemId),
       itemNameSnapshot = Value(itemNameSnapshot),
       basePrice = Value(basePrice),
       position = Value(position),
       subOrderId = Value(subOrderId);
  static Insertable<OrderItem> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? menuItemId,
    Expression<String>? itemNameSnapshot,
    Expression<String>? flavour,
    Expression<double>? weightValue,
    Expression<String>? weightUnit,
    Expression<int>? qty,
    Expression<int>? basePrice,
    Expression<String>? note,
    Expression<int>? position,
    Expression<String>? subOrderId,
    Expression<String>? status,
    Expression<int>? deliveredAt,
    Expression<String>? cancelReason,
    Expression<String>? itemMessage,
    Expression<String>? requirements,
    Expression<int>? dietaryFlags,
    Expression<String>? discountType,
    Expression<int>? discountValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (menuItemId != null) 'menu_item_id': menuItemId,
      if (itemNameSnapshot != null) 'item_name_snapshot': itemNameSnapshot,
      if (flavour != null) 'flavour': flavour,
      if (weightValue != null) 'weight_value': weightValue,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (qty != null) 'qty': qty,
      if (basePrice != null) 'base_price': basePrice,
      if (note != null) 'note': note,
      if (position != null) 'position': position,
      if (subOrderId != null) 'sub_order_id': subOrderId,
      if (status != null) 'status': status,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (cancelReason != null) 'cancel_reason': cancelReason,
      if (itemMessage != null) 'item_message': itemMessage,
      if (requirements != null) 'requirements': requirements,
      if (dietaryFlags != null) 'dietary_flags': dietaryFlags,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderId,
    Value<String>? menuItemId,
    Value<String>? itemNameSnapshot,
    Value<String?>? flavour,
    Value<double?>? weightValue,
    Value<String?>? weightUnit,
    Value<int>? qty,
    Value<int>? basePrice,
    Value<String?>? note,
    Value<int>? position,
    Value<String>? subOrderId,
    Value<String>? status,
    Value<int?>? deliveredAt,
    Value<String?>? cancelReason,
    Value<String?>? itemMessage,
    Value<String?>? requirements,
    Value<int>? dietaryFlags,
    Value<String?>? discountType,
    Value<int>? discountValue,
    Value<int>? rowid,
  }) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      itemNameSnapshot: itemNameSnapshot ?? this.itemNameSnapshot,
      flavour: flavour ?? this.flavour,
      weightValue: weightValue ?? this.weightValue,
      weightUnit: weightUnit ?? this.weightUnit,
      qty: qty ?? this.qty,
      basePrice: basePrice ?? this.basePrice,
      note: note ?? this.note,
      position: position ?? this.position,
      subOrderId: subOrderId ?? this.subOrderId,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelReason: cancelReason ?? this.cancelReason,
      itemMessage: itemMessage ?? this.itemMessage,
      requirements: requirements ?? this.requirements,
      dietaryFlags: dietaryFlags ?? this.dietaryFlags,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (menuItemId.present) {
      map['menu_item_id'] = Variable<String>(menuItemId.value);
    }
    if (itemNameSnapshot.present) {
      map['item_name_snapshot'] = Variable<String>(itemNameSnapshot.value);
    }
    if (flavour.present) {
      map['flavour'] = Variable<String>(flavour.value);
    }
    if (weightValue.present) {
      map['weight_value'] = Variable<double>(weightValue.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(weightUnit.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<int>(basePrice.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (subOrderId.present) {
      map['sub_order_id'] = Variable<String>(subOrderId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<int>(deliveredAt.value);
    }
    if (cancelReason.present) {
      map['cancel_reason'] = Variable<String>(cancelReason.value);
    }
    if (itemMessage.present) {
      map['item_message'] = Variable<String>(itemMessage.value);
    }
    if (requirements.present) {
      map['requirements'] = Variable<String>(requirements.value);
    }
    if (dietaryFlags.present) {
      map['dietary_flags'] = Variable<int>(dietaryFlags.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<int>(discountValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('itemNameSnapshot: $itemNameSnapshot, ')
          ..write('flavour: $flavour, ')
          ..write('weightValue: $weightValue, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('qty: $qty, ')
          ..write('basePrice: $basePrice, ')
          ..write('note: $note, ')
          ..write('position: $position, ')
          ..write('subOrderId: $subOrderId, ')
          ..write('status: $status, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('itemMessage: $itemMessage, ')
          ..write('requirements: $requirements, ')
          ..write('dietaryFlags: $dietaryFlags, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemStatusEventsTable extends OrderItemStatusEvents
    with TableInfo<$OrderItemStatusEventsTable, OrderItemStatusEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemStatusEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderItemIdMeta = const VerificationMeta(
    'orderItemId',
  );
  @override
  late final GeneratedColumn<String> orderItemId = GeneratedColumn<String>(
    'order_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES order_items (id)',
    ),
  );
  static const VerificationMeta _fromStatusMeta = const VerificationMeta(
    'fromStatus',
  );
  @override
  late final GeneratedColumn<String> fromStatus = GeneratedColumn<String>(
    'from_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toStatusMeta = const VerificationMeta(
    'toStatus',
  );
  @override
  late final GeneratedColumn<String> toStatus = GeneratedColumn<String>(
    'to_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderItemId,
    fromStatus,
    toStatus,
    reason,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_item_status_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderItemStatusEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_item_id')) {
      context.handle(
        _orderItemIdMeta,
        orderItemId.isAcceptableOrUnknown(
          data['order_item_id']!,
          _orderItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderItemIdMeta);
    }
    if (data.containsKey('from_status')) {
      context.handle(
        _fromStatusMeta,
        fromStatus.isAcceptableOrUnknown(data['from_status']!, _fromStatusMeta),
      );
    }
    if (data.containsKey('to_status')) {
      context.handle(
        _toStatusMeta,
        toStatus.isAcceptableOrUnknown(data['to_status']!, _toStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_toStatusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItemStatusEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItemStatusEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_item_id'],
      )!,
      fromStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_status'],
      ),
      toStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $OrderItemStatusEventsTable createAlias(String alias) {
    return $OrderItemStatusEventsTable(attachedDatabase, alias);
  }
}

class OrderItemStatusEvent extends DataClass
    implements Insertable<OrderItemStatusEvent> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderItemId;
  final String? fromStatus;
  final String toStatus;
  final String? reason;
  final int at;
  const OrderItemStatusEvent({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderItemId,
    this.fromStatus,
    required this.toStatus,
    this.reason,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_item_id'] = Variable<String>(orderItemId);
    if (!nullToAbsent || fromStatus != null) {
      map['from_status'] = Variable<String>(fromStatus);
    }
    map['to_status'] = Variable<String>(toStatus);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['at'] = Variable<int>(at);
    return map;
  }

  OrderItemStatusEventsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemStatusEventsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderItemId: Value(orderItemId),
      fromStatus: fromStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fromStatus),
      toStatus: Value(toStatus),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      at: Value(at),
    );
  }

  factory OrderItemStatusEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItemStatusEvent(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderItemId: serializer.fromJson<String>(json['orderItemId']),
      fromStatus: serializer.fromJson<String?>(json['fromStatus']),
      toStatus: serializer.fromJson<String>(json['toStatus']),
      reason: serializer.fromJson<String?>(json['reason']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderItemId': serializer.toJson<String>(orderItemId),
      'fromStatus': serializer.toJson<String?>(fromStatus),
      'toStatus': serializer.toJson<String>(toStatus),
      'reason': serializer.toJson<String?>(reason),
      'at': serializer.toJson<int>(at),
    };
  }

  OrderItemStatusEvent copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderItemId,
    Value<String?> fromStatus = const Value.absent(),
    String? toStatus,
    Value<String?> reason = const Value.absent(),
    int? at,
  }) => OrderItemStatusEvent(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderItemId: orderItemId ?? this.orderItemId,
    fromStatus: fromStatus.present ? fromStatus.value : this.fromStatus,
    toStatus: toStatus ?? this.toStatus,
    reason: reason.present ? reason.value : this.reason,
    at: at ?? this.at,
  );
  OrderItemStatusEvent copyWithCompanion(OrderItemStatusEventsCompanion data) {
    return OrderItemStatusEvent(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderItemId: data.orderItemId.present
          ? data.orderItemId.value
          : this.orderItemId,
      fromStatus: data.fromStatus.present
          ? data.fromStatus.value
          : this.fromStatus,
      toStatus: data.toStatus.present ? data.toStatus.value : this.toStatus,
      reason: data.reason.present ? data.reason.value : this.reason,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemStatusEvent(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderItemId: $orderItemId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('reason: $reason, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderItemId,
    fromStatus,
    toStatus,
    reason,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItemStatusEvent &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderItemId == this.orderItemId &&
          other.fromStatus == this.fromStatus &&
          other.toStatus == this.toStatus &&
          other.reason == this.reason &&
          other.at == this.at);
}

class OrderItemStatusEventsCompanion
    extends UpdateCompanion<OrderItemStatusEvent> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderItemId;
  final Value<String?> fromStatus;
  final Value<String> toStatus;
  final Value<String?> reason;
  final Value<int> at;
  final Value<int> rowid;
  const OrderItemStatusEventsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderItemId = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.reason = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemStatusEventsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderItemId,
    this.fromStatus = const Value.absent(),
    required String toStatus,
    this.reason = const Value.absent(),
    required int at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderItemId = Value(orderItemId),
       toStatus = Value(toStatus),
       at = Value(at);
  static Insertable<OrderItemStatusEvent> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderItemId,
    Expression<String>? fromStatus,
    Expression<String>? toStatus,
    Expression<String>? reason,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderItemId != null) 'order_item_id': orderItemId,
      if (fromStatus != null) 'from_status': fromStatus,
      if (toStatus != null) 'to_status': toStatus,
      if (reason != null) 'reason': reason,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemStatusEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderItemId,
    Value<String?>? fromStatus,
    Value<String>? toStatus,
    Value<String?>? reason,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return OrderItemStatusEventsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderItemId: orderItemId ?? this.orderItemId,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      reason: reason ?? this.reason,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderItemId.present) {
      map['order_item_id'] = Variable<String>(orderItemId.value);
    }
    if (fromStatus.present) {
      map['from_status'] = Variable<String>(fromStatus.value);
    }
    if (toStatus.present) {
      map['to_status'] = Variable<String>(toStatus.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemStatusEventsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderItemId: $orderItemId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('reason: $reason, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemAddonsTable extends OrderItemAddons
    with TableInfo<$OrderItemAddonsTable, OrderItemAddon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemAddonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderItemIdMeta = const VerificationMeta(
    'orderItemId',
  );
  @override
  late final GeneratedColumn<String> orderItemId = GeneratedColumn<String>(
    'order_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES order_items (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderItemId,
    name,
    price,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_item_addons';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderItemAddon> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_item_id')) {
      context.handle(
        _orderItemIdMeta,
        orderItemId.isAcceptableOrUnknown(
          data['order_item_id']!,
          _orderItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderItemIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItemAddon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItemAddon(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_item_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $OrderItemAddonsTable createAlias(String alias) {
    return $OrderItemAddonsTable(attachedDatabase, alias);
  }
}

class OrderItemAddon extends DataClass implements Insertable<OrderItemAddon> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderItemId;
  final String name;
  final int price;
  final int position;
  const OrderItemAddon({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderItemId,
    required this.name,
    required this.price,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_item_id'] = Variable<String>(orderItemId);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<int>(price);
    map['position'] = Variable<int>(position);
    return map;
  }

  OrderItemAddonsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemAddonsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderItemId: Value(orderItemId),
      name: Value(name),
      price: Value(price),
      position: Value(position),
    );
  }

  factory OrderItemAddon.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItemAddon(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderItemId: serializer.fromJson<String>(json['orderItemId']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<int>(json['price']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderItemId': serializer.toJson<String>(orderItemId),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<int>(price),
      'position': serializer.toJson<int>(position),
    };
  }

  OrderItemAddon copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderItemId,
    String? name,
    int? price,
    int? position,
  }) => OrderItemAddon(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderItemId: orderItemId ?? this.orderItemId,
    name: name ?? this.name,
    price: price ?? this.price,
    position: position ?? this.position,
  );
  OrderItemAddon copyWithCompanion(OrderItemAddonsCompanion data) {
    return OrderItemAddon(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderItemId: data.orderItemId.present
          ? data.orderItemId.value
          : this.orderItemId,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemAddon(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderItemId: $orderItemId, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderItemId,
    name,
    price,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItemAddon &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderItemId == this.orderItemId &&
          other.name == this.name &&
          other.price == this.price &&
          other.position == this.position);
}

class OrderItemAddonsCompanion extends UpdateCompanion<OrderItemAddon> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderItemId;
  final Value<String> name;
  final Value<int> price;
  final Value<int> position;
  final Value<int> rowid;
  const OrderItemAddonsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderItemId = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemAddonsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderItemId,
    required String name,
    required int price,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderItemId = Value(orderItemId),
       name = Value(name),
       price = Value(price),
       position = Value(position);
  static Insertable<OrderItemAddon> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderItemId,
    Expression<String>? name,
    Expression<int>? price,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderItemId != null) 'order_item_id': orderItemId,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemAddonsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderItemId,
    Value<String>? name,
    Value<int>? price,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return OrderItemAddonsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderItemId: orderItemId ?? this.orderItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderItemId.present) {
      map['order_item_id'] = Variable<String>(orderItemId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemAddonsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderItemId: $orderItemId, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderStatusEventsTable extends OrderStatusEvents
    with TableInfo<$OrderStatusEventsTable, OrderStatusEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderStatusEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id)',
    ),
  );
  static const VerificationMeta _fromStatusMeta = const VerificationMeta(
    'fromStatus',
  );
  @override
  late final GeneratedColumn<String> fromStatus = GeneratedColumn<String>(
    'from_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toStatusMeta = const VerificationMeta(
    'toStatus',
  );
  @override
  late final GeneratedColumn<String> toStatus = GeneratedColumn<String>(
    'to_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    fromStatus,
    toStatus,
    reason,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_status_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderStatusEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('from_status')) {
      context.handle(
        _fromStatusMeta,
        fromStatus.isAcceptableOrUnknown(data['from_status']!, _fromStatusMeta),
      );
    }
    if (data.containsKey('to_status')) {
      context.handle(
        _toStatusMeta,
        toStatus.isAcceptableOrUnknown(data['to_status']!, _toStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_toStatusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderStatusEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderStatusEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      fromStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_status'],
      ),
      toStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $OrderStatusEventsTable createAlias(String alias) {
    return $OrderStatusEventsTable(attachedDatabase, alias);
  }
}

class OrderStatusEvent extends DataClass
    implements Insertable<OrderStatusEvent> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderId;
  final String? fromStatus;
  final String toStatus;
  final String? reason;
  final int at;
  const OrderStatusEvent({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderId,
    this.fromStatus,
    required this.toStatus,
    this.reason,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    if (!nullToAbsent || fromStatus != null) {
      map['from_status'] = Variable<String>(fromStatus);
    }
    map['to_status'] = Variable<String>(toStatus);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['at'] = Variable<int>(at);
    return map;
  }

  OrderStatusEventsCompanion toCompanion(bool nullToAbsent) {
    return OrderStatusEventsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      fromStatus: fromStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fromStatus),
      toStatus: Value(toStatus),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      at: Value(at),
    );
  }

  factory OrderStatusEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderStatusEvent(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      fromStatus: serializer.fromJson<String?>(json['fromStatus']),
      toStatus: serializer.fromJson<String>(json['toStatus']),
      reason: serializer.fromJson<String?>(json['reason']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'fromStatus': serializer.toJson<String?>(fromStatus),
      'toStatus': serializer.toJson<String>(toStatus),
      'reason': serializer.toJson<String?>(reason),
      'at': serializer.toJson<int>(at),
    };
  }

  OrderStatusEvent copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderId,
    Value<String?> fromStatus = const Value.absent(),
    String? toStatus,
    Value<String?> reason = const Value.absent(),
    int? at,
  }) => OrderStatusEvent(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    fromStatus: fromStatus.present ? fromStatus.value : this.fromStatus,
    toStatus: toStatus ?? this.toStatus,
    reason: reason.present ? reason.value : this.reason,
    at: at ?? this.at,
  );
  OrderStatusEvent copyWithCompanion(OrderStatusEventsCompanion data) {
    return OrderStatusEvent(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      fromStatus: data.fromStatus.present
          ? data.fromStatus.value
          : this.fromStatus,
      toStatus: data.toStatus.present ? data.toStatus.value : this.toStatus,
      reason: data.reason.present ? data.reason.value : this.reason,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusEvent(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('reason: $reason, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    fromStatus,
    toStatus,
    reason,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderStatusEvent &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.fromStatus == this.fromStatus &&
          other.toStatus == this.toStatus &&
          other.reason == this.reason &&
          other.at == this.at);
}

class OrderStatusEventsCompanion extends UpdateCompanion<OrderStatusEvent> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderId;
  final Value<String?> fromStatus;
  final Value<String> toStatus;
  final Value<String?> reason;
  final Value<int> at;
  final Value<int> rowid;
  const OrderStatusEventsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.reason = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderStatusEventsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderId,
    this.fromStatus = const Value.absent(),
    required String toStatus,
    this.reason = const Value.absent(),
    required int at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderId = Value(orderId),
       toStatus = Value(toStatus),
       at = Value(at);
  static Insertable<OrderStatusEvent> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? fromStatus,
    Expression<String>? toStatus,
    Expression<String>? reason,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (fromStatus != null) 'from_status': fromStatus,
      if (toStatus != null) 'to_status': toStatus,
      if (reason != null) 'reason': reason,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderStatusEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderId,
    Value<String?>? fromStatus,
    Value<String>? toStatus,
    Value<String?>? reason,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return OrderStatusEventsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      reason: reason ?? this.reason,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (fromStatus.present) {
      map['from_status'] = Variable<String>(fromStatus.value);
    }
    if (toStatus.present) {
      map['to_status'] = Variable<String>(toStatus.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusEventsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('reason: $reason, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id)',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    path,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderId;
  final String path;
  final String kind;
  const Attachment({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderId,
    required this.path,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['path'] = Variable<String>(path);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      path: Value(path),
      kind: Value(kind),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      path: serializer.fromJson<String>(json['path']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'path': serializer.toJson<String>(path),
      'kind': serializer.toJson<String>(kind),
    };
  }

  Attachment copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderId,
    String? path,
    String? kind,
  }) => Attachment(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    path: path ?? this.path,
    kind: kind ?? this.kind,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      path: data.path.present ? data.path.value : this.path,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('path: $path, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    path,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.path == this.path &&
          other.kind == this.kind);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderId;
  final Value<String> path;
  final Value<String> kind;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.path = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderId,
    required String path,
    required String kind,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderId = Value(orderId),
       path = Value(path),
       kind = Value(kind);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? path,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (path != null) 'path': path,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderId,
    Value<String>? path,
    Value<String>? kind,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      path: path ?? this.path,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('path: $path, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<int> paidAt = GeneratedColumn<int>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    amount,
    kind,
    mode,
    reference,
    paidAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderId;
  final int amount;
  final String kind;
  final String mode;
  final String? reference;
  final int paidAt;
  const Payment({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderId,
    required this.amount,
    required this.kind,
    required this.mode,
    this.reference,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['amount'] = Variable<int>(amount);
    map['kind'] = Variable<String>(kind);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['paid_at'] = Variable<int>(paidAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      amount: Value(amount),
      kind: Value(kind),
      mode: Value(mode),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      paidAt: Value(paidAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      amount: serializer.fromJson<int>(json['amount']),
      kind: serializer.fromJson<String>(json['kind']),
      mode: serializer.fromJson<String>(json['mode']),
      reference: serializer.fromJson<String?>(json['reference']),
      paidAt: serializer.fromJson<int>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'amount': serializer.toJson<int>(amount),
      'kind': serializer.toJson<String>(kind),
      'mode': serializer.toJson<String>(mode),
      'reference': serializer.toJson<String?>(reference),
      'paidAt': serializer.toJson<int>(paidAt),
    };
  }

  Payment copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderId,
    int? amount,
    String? kind,
    String? mode,
    Value<String?> reference = const Value.absent(),
    int? paidAt,
  }) => Payment(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    amount: amount ?? this.amount,
    kind: kind ?? this.kind,
    mode: mode ?? this.mode,
    reference: reference.present ? reference.value : this.reference,
    paidAt: paidAt ?? this.paidAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      amount: data.amount.present ? data.amount.value : this.amount,
      kind: data.kind.present ? data.kind.value : this.kind,
      mode: data.mode.present ? data.mode.value : this.mode,
      reference: data.reference.present ? data.reference.value : this.reference,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('amount: $amount, ')
          ..write('kind: $kind, ')
          ..write('mode: $mode, ')
          ..write('reference: $reference, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    amount,
    kind,
    mode,
    reference,
    paidAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.amount == this.amount &&
          other.kind == this.kind &&
          other.mode == this.mode &&
          other.reference == this.reference &&
          other.paidAt == this.paidAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderId;
  final Value<int> amount;
  final Value<String> kind;
  final Value<String> mode;
  final Value<String?> reference;
  final Value<int> paidAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.amount = const Value.absent(),
    this.kind = const Value.absent(),
    this.mode = const Value.absent(),
    this.reference = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderId,
    required int amount,
    required String kind,
    required String mode,
    this.reference = const Value.absent(),
    required int paidAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderId = Value(orderId),
       amount = Value(amount),
       kind = Value(kind),
       mode = Value(mode),
       paidAt = Value(paidAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderId,
    Expression<int>? amount,
    Expression<String>? kind,
    Expression<String>? mode,
    Expression<String>? reference,
    Expression<int>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (amount != null) 'amount': amount,
      if (kind != null) 'kind': kind,
      if (mode != null) 'mode': mode,
      if (reference != null) 'reference': reference,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderId,
    Value<int>? amount,
    Value<String>? kind,
    Value<String>? mode,
    Value<String?>? reference,
    Value<int>? paidAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      kind: kind ?? this.kind,
      mode: mode ?? this.mode,
      reference: reference ?? this.reference,
      paidAt: paidAt ?? this.paidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<int>(paidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('amount: $amount, ')
          ..write('kind: $kind, ')
          ..write('mode: $mode, ')
          ..write('reference: $reference, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialsTable extends Materials
    with TableInfo<$MaterialsTable, RawMaterial> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldHlcJsonMeta = const VerificationMeta(
    'fieldHlcJson',
  );
  @override
  late final GeneratedColumn<String> fieldHlcJson = GeneratedColumn<String>(
    'field_hlc_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdQtyMeta = const VerificationMeta(
    'thresholdQty',
  );
  @override
  late final GeneratedColumn<double> thresholdQty = GeneratedColumn<double>(
    'threshold_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    name,
    category,
    unit,
    thresholdQty,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawMaterial> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('field_hlc_json')) {
      context.handle(
        _fieldHlcJsonMeta,
        fieldHlcJson.isAcceptableOrUnknown(
          data['field_hlc_json']!,
          _fieldHlcJsonMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('threshold_qty')) {
      context.handle(
        _thresholdQtyMeta,
        thresholdQty.isAcceptableOrUnknown(
          data['threshold_qty']!,
          _thresholdQtyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thresholdQtyMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawMaterial map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawMaterial(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      fieldHlcJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_hlc_json'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      thresholdQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}threshold_qty'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $MaterialsTable createAlias(String alias) {
    return $MaterialsTable(attachedDatabase, alias);
  }
}

class RawMaterial extends DataClass implements Insertable<RawMaterial> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String? fieldHlcJson;
  final String name;
  final String category;
  final String unit;
  final double thresholdQty;
  final bool active;
  const RawMaterial({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    this.fieldHlcJson,
    required this.name,
    required this.category,
    required this.unit,
    required this.thresholdQty,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || fieldHlcJson != null) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson);
    }
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['unit'] = Variable<String>(unit);
    map['threshold_qty'] = Variable<double>(thresholdQty);
    map['active'] = Variable<bool>(active);
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fieldHlcJson: fieldHlcJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldHlcJson),
      name: Value(name),
      category: Value(category),
      unit: Value(unit),
      thresholdQty: Value(thresholdQty),
      active: Value(active),
    );
  }

  factory RawMaterial.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawMaterial(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      fieldHlcJson: serializer.fromJson<String?>(json['fieldHlcJson']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      thresholdQty: serializer.fromJson<double>(json['thresholdQty']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'fieldHlcJson': serializer.toJson<String?>(fieldHlcJson),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'unit': serializer.toJson<String>(unit),
      'thresholdQty': serializer.toJson<double>(thresholdQty),
      'active': serializer.toJson<bool>(active),
    };
  }

  RawMaterial copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> fieldHlcJson = const Value.absent(),
    String? name,
    String? category,
    String? unit,
    double? thresholdQty,
    bool? active,
  }) => RawMaterial(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    fieldHlcJson: fieldHlcJson.present ? fieldHlcJson.value : this.fieldHlcJson,
    name: name ?? this.name,
    category: category ?? this.category,
    unit: unit ?? this.unit,
    thresholdQty: thresholdQty ?? this.thresholdQty,
    active: active ?? this.active,
  );
  RawMaterial copyWithCompanion(MaterialsCompanion data) {
    return RawMaterial(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fieldHlcJson: data.fieldHlcJson.present
          ? data.fieldHlcJson.value
          : this.fieldHlcJson,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      thresholdQty: data.thresholdQty.present
          ? data.thresholdQty.value
          : this.thresholdQty,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawMaterial(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('thresholdQty: $thresholdQty, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    fieldHlcJson,
    name,
    category,
    unit,
    thresholdQty,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawMaterial &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.fieldHlcJson == this.fieldHlcJson &&
          other.name == this.name &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.thresholdQty == this.thresholdQty &&
          other.active == this.active);
}

class MaterialsCompanion extends UpdateCompanion<RawMaterial> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String?> fieldHlcJson;
  final Value<String> name;
  final Value<String> category;
  final Value<String> unit;
  final Value<double> thresholdQty;
  final Value<bool> active;
  final Value<int> rowid;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.thresholdQty = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    this.fieldHlcJson = const Value.absent(),
    required String name,
    required String category,
    required String unit,
    required double thresholdQty,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       name = Value(name),
       category = Value(category),
       unit = Value(unit),
       thresholdQty = Value(thresholdQty);
  static Insertable<RawMaterial> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? fieldHlcJson,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<double>? thresholdQty,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fieldHlcJson != null) 'field_hlc_json': fieldHlcJson,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (thresholdQty != null) 'threshold_qty': thresholdQty,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String?>? fieldHlcJson,
    Value<String>? name,
    Value<String>? category,
    Value<String>? unit,
    Value<double>? thresholdQty,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      fieldHlcJson: fieldHlcJson ?? this.fieldHlcJson,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      thresholdQty: thresholdQty ?? this.thresholdQty,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (fieldHlcJson.present) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (thresholdQty.present) {
      map['threshold_qty'] = Variable<double>(thresholdQty.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('thresholdQty: $thresholdQty, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockTransactionsTable extends StockTransactions
    with TableInfo<$StockTransactionsTable, StockTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
    'material_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES materials (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    materialId,
    kind,
    qty,
    amount,
    reason,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $StockTransactionsTable createAlias(String alias) {
    return $StockTransactionsTable(attachedDatabase, alias);
  }
}

class StockTransaction extends DataClass
    implements Insertable<StockTransaction> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String materialId;
  final String kind;
  final double qty;
  final int? amount;
  final String? reason;
  final int at;
  const StockTransaction({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.materialId,
    required this.kind,
    required this.qty,
    this.amount,
    this.reason,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['material_id'] = Variable<String>(materialId);
    map['kind'] = Variable<String>(kind);
    map['qty'] = Variable<double>(qty);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['at'] = Variable<int>(at);
    return map;
  }

  StockTransactionsCompanion toCompanion(bool nullToAbsent) {
    return StockTransactionsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      materialId: Value(materialId),
      kind: Value(kind),
      qty: Value(qty),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      at: Value(at),
    );
  }

  factory StockTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTransaction(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      materialId: serializer.fromJson<String>(json['materialId']),
      kind: serializer.fromJson<String>(json['kind']),
      qty: serializer.fromJson<double>(json['qty']),
      amount: serializer.fromJson<int?>(json['amount']),
      reason: serializer.fromJson<String?>(json['reason']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'materialId': serializer.toJson<String>(materialId),
      'kind': serializer.toJson<String>(kind),
      'qty': serializer.toJson<double>(qty),
      'amount': serializer.toJson<int?>(amount),
      'reason': serializer.toJson<String?>(reason),
      'at': serializer.toJson<int>(at),
    };
  }

  StockTransaction copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? materialId,
    String? kind,
    double? qty,
    Value<int?> amount = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    int? at,
  }) => StockTransaction(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    materialId: materialId ?? this.materialId,
    kind: kind ?? this.kind,
    qty: qty ?? this.qty,
    amount: amount.present ? amount.value : this.amount,
    reason: reason.present ? reason.value : this.reason,
    at: at ?? this.at,
  );
  StockTransaction copyWithCompanion(StockTransactionsCompanion data) {
    return StockTransaction(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
      kind: data.kind.present ? data.kind.value : this.kind,
      qty: data.qty.present ? data.qty.value : this.qty,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTransaction(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('materialId: $materialId, ')
          ..write('kind: $kind, ')
          ..write('qty: $qty, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    materialId,
    kind,
    qty,
    amount,
    reason,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTransaction &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.materialId == this.materialId &&
          other.kind == this.kind &&
          other.qty == this.qty &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.at == this.at);
}

class StockTransactionsCompanion extends UpdateCompanion<StockTransaction> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> materialId;
  final Value<String> kind;
  final Value<double> qty;
  final Value<int?> amount;
  final Value<String?> reason;
  final Value<int> at;
  final Value<int> rowid;
  const StockTransactionsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.materialId = const Value.absent(),
    this.kind = const Value.absent(),
    this.qty = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockTransactionsCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String materialId,
    required String kind,
    required double qty,
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    required int at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       materialId = Value(materialId),
       kind = Value(kind),
       qty = Value(qty),
       at = Value(at);
  static Insertable<StockTransaction> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? materialId,
    Expression<String>? kind,
    Expression<double>? qty,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (materialId != null) 'material_id': materialId,
      if (kind != null) 'kind': kind,
      if (qty != null) 'qty': qty,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? materialId,
    Value<String>? kind,
    Value<double>? qty,
    Value<int?>? amount,
    Value<String?>? reason,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return StockTransactionsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      materialId: materialId ?? this.materialId,
      kind: kind ?? this.kind,
      qty: qty ?? this.qty,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('materialId: $materialId, ')
          ..write('kind: $kind, ')
          ..write('qty: $qty, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShareLogTable extends ShareLog
    with TableInfo<$ShareLogTable, ShareLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShareLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _composedAtMeta = const VerificationMeta(
    'composedAt',
  );
  @override
  late final GeneratedColumn<int> composedAt = GeneratedColumn<int>(
    'composed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sharedAtMeta = const VerificationMeta(
    'sharedAt',
  );
  @override
  late final GeneratedColumn<int> sharedAt = GeneratedColumn<int>(
    'shared_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    kind,
    composedAt,
    sharedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'share_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShareLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('composed_at')) {
      context.handle(
        _composedAtMeta,
        composedAt.isAcceptableOrUnknown(data['composed_at']!, _composedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_composedAtMeta);
    }
    if (data.containsKey('shared_at')) {
      context.handle(
        _sharedAtMeta,
        sharedAt.isAcceptableOrUnknown(data['shared_at']!, _sharedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShareLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShareLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      composedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}composed_at'],
      )!,
      sharedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shared_at'],
      ),
    );
  }

  @override
  $ShareLogTable createAlias(String alias) {
    return $ShareLogTable(attachedDatabase, alias);
  }
}

class ShareLogData extends DataClass implements Insertable<ShareLogData> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String orderId;
  final String kind;
  final int composedAt;
  final int? sharedAt;
  const ShareLogData({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.orderId,
    required this.kind,
    required this.composedAt,
    this.sharedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['kind'] = Variable<String>(kind);
    map['composed_at'] = Variable<int>(composedAt);
    if (!nullToAbsent || sharedAt != null) {
      map['shared_at'] = Variable<int>(sharedAt);
    }
    return map;
  }

  ShareLogCompanion toCompanion(bool nullToAbsent) {
    return ShareLogCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      kind: Value(kind),
      composedAt: Value(composedAt),
      sharedAt: sharedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedAt),
    );
  }

  factory ShareLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShareLogData(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      kind: serializer.fromJson<String>(json['kind']),
      composedAt: serializer.fromJson<int>(json['composedAt']),
      sharedAt: serializer.fromJson<int?>(json['sharedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'kind': serializer.toJson<String>(kind),
      'composedAt': serializer.toJson<int>(composedAt),
      'sharedAt': serializer.toJson<int?>(sharedAt),
    };
  }

  ShareLogData copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? orderId,
    String? kind,
    int? composedAt,
    Value<int?> sharedAt = const Value.absent(),
  }) => ShareLogData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    kind: kind ?? this.kind,
    composedAt: composedAt ?? this.composedAt,
    sharedAt: sharedAt.present ? sharedAt.value : this.sharedAt,
  );
  ShareLogData copyWithCompanion(ShareLogCompanion data) {
    return ShareLogData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      kind: data.kind.present ? data.kind.value : this.kind,
      composedAt: data.composedAt.present
          ? data.composedAt.value
          : this.composedAt,
      sharedAt: data.sharedAt.present ? data.sharedAt.value : this.sharedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShareLogData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('kind: $kind, ')
          ..write('composedAt: $composedAt, ')
          ..write('sharedAt: $sharedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    orderId,
    kind,
    composedAt,
    sharedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShareLogData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.kind == this.kind &&
          other.composedAt == this.composedAt &&
          other.sharedAt == this.sharedAt);
}

class ShareLogCompanion extends UpdateCompanion<ShareLogData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> orderId;
  final Value<String> kind;
  final Value<int> composedAt;
  final Value<int?> sharedAt;
  final Value<int> rowid;
  const ShareLogCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.kind = const Value.absent(),
    this.composedAt = const Value.absent(),
    this.sharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShareLogCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String orderId,
    required String kind,
    required int composedAt,
    this.sharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       orderId = Value(orderId),
       kind = Value(kind),
       composedAt = Value(composedAt);
  static Insertable<ShareLogData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? kind,
    Expression<int>? composedAt,
    Expression<int>? sharedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (kind != null) 'kind': kind,
      if (composedAt != null) 'composed_at': composedAt,
      if (sharedAt != null) 'shared_at': sharedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShareLogCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? orderId,
    Value<String>? kind,
    Value<int>? composedAt,
    Value<int?>? sharedAt,
    Value<int>? rowid,
  }) {
    return ShareLogCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      kind: kind ?? this.kind,
      composedAt: composedAt ?? this.composedAt,
      sharedAt: sharedAt ?? this.sharedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (composedAt.present) {
      map['composed_at'] = Variable<int>(composedAt.value);
    }
    if (sharedAt.present) {
      map['shared_at'] = Variable<int>(sharedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShareLogCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('kind: $kind, ')
          ..write('composedAt: $composedAt, ')
          ..write('sharedAt: $sharedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<int> firstSeenAt = GeneratedColumn<int>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<int> appVersion = GeneratedColumn<int>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    name,
    firstSeenAt,
    lastSeenAt,
    appVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}app_version'],
      ),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String? name;
  final int firstSeenAt;
  final int lastSeenAt;
  final int? appVersion;
  const Device({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    this.name,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.appVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['first_seen_at'] = Variable<int>(firstSeenAt);
    map['last_seen_at'] = Variable<int>(lastSeenAt);
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<int>(appVersion);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      firstSeenAt: Value(firstSeenAt),
      lastSeenAt: Value(lastSeenAt),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String?>(json['name']),
      firstSeenAt: serializer.fromJson<int>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<int>(json['lastSeenAt']),
      appVersion: serializer.fromJson<int?>(json['appVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String?>(name),
      'firstSeenAt': serializer.toJson<int>(firstSeenAt),
      'lastSeenAt': serializer.toJson<int>(lastSeenAt),
      'appVersion': serializer.toJson<int?>(appVersion),
    };
  }

  Device copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> name = const Value.absent(),
    int? firstSeenAt,
    int? lastSeenAt,
    Value<int?> appVersion = const Value.absent(),
  }) => Device(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name.present ? name.value : this.name,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('appVersion: $appVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    name,
    firstSeenAt,
    lastSeenAt,
    appVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.appVersion == this.appVersion);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String?> name;
  final Value<int> firstSeenAt;
  final Value<int> lastSeenAt;
  final Value<int?> appVersion;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    required int firstSeenAt,
    required int lastSeenAt,
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       firstSeenAt = Value(firstSeenAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<int>? firstSeenAt,
    Expression<int>? lastSeenAt,
    Expression<int>? appVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (appVersion != null) 'app_version': appVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String?>? name,
    Value<int>? firstSeenAt,
    Value<int>? lastSeenAt,
    Value<int?>? appVersion,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      appVersion: appVersion ?? this.appVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<int>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<int>(appVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('appVersion: $appVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictLogTable extends ConflictLog
    with TableInfo<$ConflictLogTable, ConflictLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localValueMeta = const VerificationMeta(
    'localValue',
  );
  @override
  late final GeneratedColumn<String> localValue = GeneratedColumn<String>(
    'local_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteValueMeta = const VerificationMeta(
    'remoteValue',
  );
  @override
  late final GeneratedColumn<String> remoteValue = GeneratedColumn<String>(
    'remote_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
    'winner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    entity,
    entityId,
    field,
    localValue,
    remoteValue,
    winner,
    reason,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflict_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('local_value')) {
      context.handle(
        _localValueMeta,
        localValue.isAcceptableOrUnknown(data['local_value']!, _localValueMeta),
      );
    }
    if (data.containsKey('remote_value')) {
      context.handle(
        _remoteValueMeta,
        remoteValue.isAcceptableOrUnknown(
          data['remote_value']!,
          _remoteValueMeta,
        ),
      );
    }
    if (data.containsKey('winner')) {
      context.handle(
        _winnerMeta,
        winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta),
      );
    } else if (isInserting) {
      context.missing(_winnerMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      localValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_value'],
      ),
      remoteValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_value'],
      ),
      winner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $ConflictLogTable createAlias(String alias) {
    return $ConflictLogTable(attachedDatabase, alias);
  }
}

class ConflictLogData extends DataClass implements Insertable<ConflictLogData> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String entity;
  final String entityId;
  final String field;
  final String? localValue;
  final String? remoteValue;
  final String winner;
  final String reason;
  final int at;
  const ConflictLogData({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.entity,
    required this.entityId,
    required this.field,
    this.localValue,
    this.remoteValue,
    required this.winner,
    required this.reason,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || localValue != null) {
      map['local_value'] = Variable<String>(localValue);
    }
    if (!nullToAbsent || remoteValue != null) {
      map['remote_value'] = Variable<String>(remoteValue);
    }
    map['winner'] = Variable<String>(winner);
    map['reason'] = Variable<String>(reason);
    map['at'] = Variable<int>(at);
    return map;
  }

  ConflictLogCompanion toCompanion(bool nullToAbsent) {
    return ConflictLogCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      entity: Value(entity),
      entityId: Value(entityId),
      field: Value(field),
      localValue: localValue == null && nullToAbsent
          ? const Value.absent()
          : Value(localValue),
      remoteValue: remoteValue == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteValue),
      winner: Value(winner),
      reason: Value(reason),
      at: Value(at),
    );
  }

  factory ConflictLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictLogData(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      localValue: serializer.fromJson<String?>(json['localValue']),
      remoteValue: serializer.fromJson<String?>(json['remoteValue']),
      winner: serializer.fromJson<String>(json['winner']),
      reason: serializer.fromJson<String>(json['reason']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'localValue': serializer.toJson<String?>(localValue),
      'remoteValue': serializer.toJson<String?>(remoteValue),
      'winner': serializer.toJson<String>(winner),
      'reason': serializer.toJson<String>(reason),
      'at': serializer.toJson<int>(at),
    };
  }

  ConflictLogData copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? entity,
    String? entityId,
    String? field,
    Value<String?> localValue = const Value.absent(),
    Value<String?> remoteValue = const Value.absent(),
    String? winner,
    String? reason,
    int? at,
  }) => ConflictLogData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    localValue: localValue.present ? localValue.value : this.localValue,
    remoteValue: remoteValue.present ? remoteValue.value : this.remoteValue,
    winner: winner ?? this.winner,
    reason: reason ?? this.reason,
    at: at ?? this.at,
  );
  ConflictLogData copyWithCompanion(ConflictLogCompanion data) {
    return ConflictLogData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      localValue: data.localValue.present
          ? data.localValue.value
          : this.localValue,
      remoteValue: data.remoteValue.present
          ? data.remoteValue.value
          : this.remoteValue,
      winner: data.winner.present ? data.winner.value : this.winner,
      reason: data.reason.present ? data.reason.value : this.reason,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictLogData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('localValue: $localValue, ')
          ..write('remoteValue: $remoteValue, ')
          ..write('winner: $winner, ')
          ..write('reason: $reason, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    entity,
    entityId,
    field,
    localValue,
    remoteValue,
    winner,
    reason,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictLogData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.localValue == this.localValue &&
          other.remoteValue == this.remoteValue &&
          other.winner == this.winner &&
          other.reason == this.reason &&
          other.at == this.at);
}

class ConflictLogCompanion extends UpdateCompanion<ConflictLogData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String?> localValue;
  final Value<String?> remoteValue;
  final Value<String> winner;
  final Value<String> reason;
  final Value<int> at;
  final Value<int> rowid;
  const ConflictLogCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.localValue = const Value.absent(),
    this.remoteValue = const Value.absent(),
    this.winner = const Value.absent(),
    this.reason = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictLogCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    required String updatedAtHlc,
    this.deletedAt = const Value.absent(),
    required String entity,
    required String entityId,
    required String field,
    this.localValue = const Value.absent(),
    this.remoteValue = const Value.absent(),
    required String winner,
    required String reason,
    required int at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAtHlc = Value(updatedAtHlc),
       entity = Value(entity),
       entityId = Value(entityId),
       field = Value(field),
       winner = Value(winner),
       reason = Value(reason),
       at = Value(at);
  static Insertable<ConflictLogData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? localValue,
    Expression<String>? remoteValue,
    Expression<String>? winner,
    Expression<String>? reason,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (localValue != null) 'local_value': localValue,
      if (remoteValue != null) 'remote_value': remoteValue,
      if (winner != null) 'winner': winner,
      if (reason != null) 'reason': reason,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictLogCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? field,
    Value<String?>? localValue,
    Value<String?>? remoteValue,
    Value<String>? winner,
    Value<String>? reason,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return ConflictLogCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      localValue: localValue ?? this.localValue,
      remoteValue: remoteValue ?? this.remoteValue,
      winner: winner ?? this.winner,
      reason: reason ?? this.reason,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (localValue.present) {
      map['local_value'] = Variable<String>(localValue.value);
    }
    if (remoteValue.present) {
      map['remote_value'] = Variable<String>(remoteValue.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictLogCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('localValue: $localValue, ')
          ..write('remoteValue: $remoteValue, ')
          ..write('winner: $winner, ')
          ..write('reason: $reason, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVMeta = const VerificationMeta(
    'schemaV',
  );
  @override
  late final GeneratedColumn<int> schemaV = GeneratedColumn<int>(
    'schema_v',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedAtMeta = const VerificationMeta(
    'uploadedAt',
  );
  @override
  late final GeneratedColumn<int> uploadedAt = GeneratedColumn<int>(
    'uploaded_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    seq,
    hlc,
    entity,
    entityId,
    kind,
    payload,
    schemaV,
    uploadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('schema_v')) {
      context.handle(
        _schemaVMeta,
        schemaV.isAcceptableOrUnknown(data['schema_v']!, _schemaVMeta),
      );
    } else if (isInserting) {
      context.missing(_schemaVMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
        _uploadedAtMeta,
        uploadedAt.isAcceptableOrUnknown(data['uploaded_at']!, _uploadedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      schemaV: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_v'],
      )!,
      uploadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uploaded_at'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final String opId;
  final int seq;
  final String hlc;
  final String entity;
  final String entityId;
  final String kind;
  final String payload;
  final int schemaV;
  final int? uploadedAt;
  const OutboxData({
    required this.opId,
    required this.seq,
    required this.hlc,
    required this.entity,
    required this.entityId,
    required this.kind,
    required this.payload,
    required this.schemaV,
    this.uploadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['seq'] = Variable<int>(seq);
    map['hlc'] = Variable<String>(hlc);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    map['schema_v'] = Variable<int>(schemaV);
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<int>(uploadedAt);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      opId: Value(opId),
      seq: Value(seq),
      hlc: Value(hlc),
      entity: Value(entity),
      entityId: Value(entityId),
      kind: Value(kind),
      payload: Value(payload),
      schemaV: Value(schemaV),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      opId: serializer.fromJson<String>(json['opId']),
      seq: serializer.fromJson<int>(json['seq']),
      hlc: serializer.fromJson<String>(json['hlc']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
      schemaV: serializer.fromJson<int>(json['schemaV']),
      uploadedAt: serializer.fromJson<int?>(json['uploadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'seq': serializer.toJson<int>(seq),
      'hlc': serializer.toJson<String>(hlc),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
      'schemaV': serializer.toJson<int>(schemaV),
      'uploadedAt': serializer.toJson<int?>(uploadedAt),
    };
  }

  OutboxData copyWith({
    String? opId,
    int? seq,
    String? hlc,
    String? entity,
    String? entityId,
    String? kind,
    String? payload,
    int? schemaV,
    Value<int?> uploadedAt = const Value.absent(),
  }) => OutboxData(
    opId: opId ?? this.opId,
    seq: seq ?? this.seq,
    hlc: hlc ?? this.hlc,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    schemaV: schemaV ?? this.schemaV,
    uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      opId: data.opId.present ? data.opId.value : this.opId,
      seq: data.seq.present ? data.seq.value : this.seq,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
      schemaV: data.schemaV.present ? data.schemaV.value : this.schemaV,
      uploadedAt: data.uploadedAt.present
          ? data.uploadedAt.value
          : this.uploadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('opId: $opId, ')
          ..write('seq: $seq, ')
          ..write('hlc: $hlc, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('schemaV: $schemaV, ')
          ..write('uploadedAt: $uploadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    seq,
    hlc,
    entity,
    entityId,
    kind,
    payload,
    schemaV,
    uploadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.opId == this.opId &&
          other.seq == this.seq &&
          other.hlc == this.hlc &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.kind == this.kind &&
          other.payload == this.payload &&
          other.schemaV == this.schemaV &&
          other.uploadedAt == this.uploadedAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> opId;
  final Value<int> seq;
  final Value<String> hlc;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> kind;
  final Value<String> payload;
  final Value<int> schemaV;
  final Value<int?> uploadedAt;
  final Value<int> rowid;
  const OutboxCompanion({
    this.opId = const Value.absent(),
    this.seq = const Value.absent(),
    this.hlc = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.schemaV = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String opId,
    required int seq,
    required String hlc,
    required String entity,
    required String entityId,
    required String kind,
    required String payload,
    required int schemaV,
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       seq = Value(seq),
       hlc = Value(hlc),
       entity = Value(entity),
       entityId = Value(entityId),
       kind = Value(kind),
       payload = Value(payload),
       schemaV = Value(schemaV);
  static Insertable<OutboxData> custom({
    Expression<String>? opId,
    Expression<int>? seq,
    Expression<String>? hlc,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<int>? schemaV,
    Expression<int>? uploadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (seq != null) 'seq': seq,
      if (hlc != null) 'hlc': hlc,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (schemaV != null) 'schema_v': schemaV,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? opId,
    Value<int>? seq,
    Value<String>? hlc,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? kind,
    Value<String>? payload,
    Value<int>? schemaV,
    Value<int?>? uploadedAt,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      opId: opId ?? this.opId,
      seq: seq ?? this.seq,
      hlc: hlc ?? this.hlc,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      schemaV: schemaV ?? this.schemaV,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (schemaV.present) {
      map['schema_v'] = Variable<int>(schemaV.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<int>(uploadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('opId: $opId, ')
          ..write('seq: $seq, ')
          ..write('hlc: $hlc, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('schemaV: $schemaV, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppliedOpsTable extends AppliedOps
    with TableInfo<$AppliedOpsTable, AppliedOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppliedOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<int> appliedAt = GeneratedColumn<int>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [opId, appliedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applied_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppliedOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  AppliedOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppliedOp(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_at'],
      )!,
    );
  }

  @override
  $AppliedOpsTable createAlias(String alias) {
    return $AppliedOpsTable(attachedDatabase, alias);
  }
}

class AppliedOp extends DataClass implements Insertable<AppliedOp> {
  final String opId;
  final int appliedAt;
  const AppliedOp({required this.opId, required this.appliedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['applied_at'] = Variable<int>(appliedAt);
    return map;
  }

  AppliedOpsCompanion toCompanion(bool nullToAbsent) {
    return AppliedOpsCompanion(opId: Value(opId), appliedAt: Value(appliedAt));
  }

  factory AppliedOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppliedOp(
      opId: serializer.fromJson<String>(json['opId']),
      appliedAt: serializer.fromJson<int>(json['appliedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'appliedAt': serializer.toJson<int>(appliedAt),
    };
  }

  AppliedOp copyWith({String? opId, int? appliedAt}) => AppliedOp(
    opId: opId ?? this.opId,
    appliedAt: appliedAt ?? this.appliedAt,
  );
  AppliedOp copyWithCompanion(AppliedOpsCompanion data) {
    return AppliedOp(
      opId: data.opId.present ? data.opId.value : this.opId,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppliedOp(')
          ..write('opId: $opId, ')
          ..write('appliedAt: $appliedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(opId, appliedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppliedOp &&
          other.opId == this.opId &&
          other.appliedAt == this.appliedAt);
}

class AppliedOpsCompanion extends UpdateCompanion<AppliedOp> {
  final Value<String> opId;
  final Value<int> appliedAt;
  final Value<int> rowid;
  const AppliedOpsCompanion({
    this.opId = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppliedOpsCompanion.insert({
    required String opId,
    required int appliedAt,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       appliedAt = Value(appliedAt);
  static Insertable<AppliedOp> custom({
    Expression<String>? opId,
    Expression<int>? appliedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppliedOpsCompanion copyWith({
    Value<String>? opId,
    Value<int>? appliedAt,
    Value<int>? rowid,
  }) {
    return AppliedOpsCompanion(
      opId: opId ?? this.opId,
      appliedAt: appliedAt ?? this.appliedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<int>(appliedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppliedOpsCompanion(')
          ..write('opId: $opId, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeerCursorsTable extends PeerCursors
    with TableInfo<$PeerCursorsTable, PeerCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeerCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerDeviceIdMeta = const VerificationMeta(
    'peerDeviceId',
  );
  @override
  late final GeneratedColumn<String> peerDeviceId = GeneratedColumn<String>(
    'peer_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeqMeta = const VerificationMeta(
    'lastSeq',
  );
  @override
  late final GeneratedColumn<int> lastSeq = GeneratedColumn<int>(
    'last_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  @override
  late final GeneratedColumn<int> lastPulledAt = GeneratedColumn<int>(
    'last_pulled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsUpgradeMeta = const VerificationMeta(
    'needsUpgrade',
  );
  @override
  late final GeneratedColumn<bool> needsUpgrade = GeneratedColumn<bool>(
    'needs_upgrade',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_upgrade" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    peerDeviceId,
    lastSeq,
    lastPulledAt,
    needsUpgrade,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'peer_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeerCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_device_id')) {
      context.handle(
        _peerDeviceIdMeta,
        peerDeviceId.isAcceptableOrUnknown(
          data['peer_device_id']!,
          _peerDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peerDeviceIdMeta);
    }
    if (data.containsKey('last_seq')) {
      context.handle(
        _lastSeqMeta,
        lastSeq.isAcceptableOrUnknown(data['last_seq']!, _lastSeqMeta),
      );
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_upgrade')) {
      context.handle(
        _needsUpgradeMeta,
        needsUpgrade.isAcceptableOrUnknown(
          data['needs_upgrade']!,
          _needsUpgradeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerDeviceId};
  @override
  PeerCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeerCursor(
      peerDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_device_id'],
      )!,
      lastSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seq'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pulled_at'],
      ),
      needsUpgrade: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_upgrade'],
      )!,
    );
  }

  @override
  $PeerCursorsTable createAlias(String alias) {
    return $PeerCursorsTable(attachedDatabase, alias);
  }
}

class PeerCursor extends DataClass implements Insertable<PeerCursor> {
  final String peerDeviceId;
  final int lastSeq;
  final int? lastPulledAt;
  final bool needsUpgrade;
  const PeerCursor({
    required this.peerDeviceId,
    required this.lastSeq,
    this.lastPulledAt,
    required this.needsUpgrade,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_device_id'] = Variable<String>(peerDeviceId);
    map['last_seq'] = Variable<int>(lastSeq);
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt);
    }
    map['needs_upgrade'] = Variable<bool>(needsUpgrade);
    return map;
  }

  PeerCursorsCompanion toCompanion(bool nullToAbsent) {
    return PeerCursorsCompanion(
      peerDeviceId: Value(peerDeviceId),
      lastSeq: Value(lastSeq),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      needsUpgrade: Value(needsUpgrade),
    );
  }

  factory PeerCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeerCursor(
      peerDeviceId: serializer.fromJson<String>(json['peerDeviceId']),
      lastSeq: serializer.fromJson<int>(json['lastSeq']),
      lastPulledAt: serializer.fromJson<int?>(json['lastPulledAt']),
      needsUpgrade: serializer.fromJson<bool>(json['needsUpgrade']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerDeviceId': serializer.toJson<String>(peerDeviceId),
      'lastSeq': serializer.toJson<int>(lastSeq),
      'lastPulledAt': serializer.toJson<int?>(lastPulledAt),
      'needsUpgrade': serializer.toJson<bool>(needsUpgrade),
    };
  }

  PeerCursor copyWith({
    String? peerDeviceId,
    int? lastSeq,
    Value<int?> lastPulledAt = const Value.absent(),
    bool? needsUpgrade,
  }) => PeerCursor(
    peerDeviceId: peerDeviceId ?? this.peerDeviceId,
    lastSeq: lastSeq ?? this.lastSeq,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
    needsUpgrade: needsUpgrade ?? this.needsUpgrade,
  );
  PeerCursor copyWithCompanion(PeerCursorsCompanion data) {
    return PeerCursor(
      peerDeviceId: data.peerDeviceId.present
          ? data.peerDeviceId.value
          : this.peerDeviceId,
      lastSeq: data.lastSeq.present ? data.lastSeq.value : this.lastSeq,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
      needsUpgrade: data.needsUpgrade.present
          ? data.needsUpgrade.value
          : this.needsUpgrade,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeerCursor(')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('lastSeq: $lastSeq, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('needsUpgrade: $needsUpgrade')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(peerDeviceId, lastSeq, lastPulledAt, needsUpgrade);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeerCursor &&
          other.peerDeviceId == this.peerDeviceId &&
          other.lastSeq == this.lastSeq &&
          other.lastPulledAt == this.lastPulledAt &&
          other.needsUpgrade == this.needsUpgrade);
}

class PeerCursorsCompanion extends UpdateCompanion<PeerCursor> {
  final Value<String> peerDeviceId;
  final Value<int> lastSeq;
  final Value<int?> lastPulledAt;
  final Value<bool> needsUpgrade;
  final Value<int> rowid;
  const PeerCursorsCompanion({
    this.peerDeviceId = const Value.absent(),
    this.lastSeq = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.needsUpgrade = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeerCursorsCompanion.insert({
    required String peerDeviceId,
    this.lastSeq = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.needsUpgrade = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : peerDeviceId = Value(peerDeviceId);
  static Insertable<PeerCursor> custom({
    Expression<String>? peerDeviceId,
    Expression<int>? lastSeq,
    Expression<int>? lastPulledAt,
    Expression<bool>? needsUpgrade,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerDeviceId != null) 'peer_device_id': peerDeviceId,
      if (lastSeq != null) 'last_seq': lastSeq,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (needsUpgrade != null) 'needs_upgrade': needsUpgrade,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeerCursorsCompanion copyWith({
    Value<String>? peerDeviceId,
    Value<int>? lastSeq,
    Value<int?>? lastPulledAt,
    Value<bool>? needsUpgrade,
    Value<int>? rowid,
  }) {
    return PeerCursorsCompanion(
      peerDeviceId: peerDeviceId ?? this.peerDeviceId,
      lastSeq: lastSeq ?? this.lastSeq,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      needsUpgrade: needsUpgrade ?? this.needsUpgrade,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerDeviceId.present) {
      map['peer_device_id'] = Variable<String>(peerDeviceId.value);
    }
    if (lastSeq.present) {
      map['last_seq'] = Variable<int>(lastSeq.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt.value);
    }
    if (needsUpgrade.present) {
      map['needs_upgrade'] = Variable<bool>(needsUpgrade.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeerCursorsCompanion(')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('lastSeq: $lastSeq, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('needsUpgrade: $needsUpgrade, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fieldHlcJsonMeta = const VerificationMeta(
    'fieldHlcJson',
  );
  @override
  late final GeneratedColumn<String> fieldHlcJson = GeneratedColumn<String>(
    'field_hlc_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('singleton'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('seed'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0:0:seed'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Little Loaf Bakery'),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoicePrefixMeta = const VerificationMeta(
    'invoicePrefix',
  );
  @override
  late final GeneratedColumn<String> invoicePrefix = GeneratedColumn<String>(
    'invoice_prefix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LLB'),
  );
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
    'upi_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentPhoneMeta = const VerificationMeta(
    'paymentPhone',
  );
  @override
  late final GeneratedColumn<String> paymentPhone = GeneratedColumn<String>(
    'payment_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryChargeLocalMeta =
      const VerificationMeta('deliveryChargeLocal');
  @override
  late final GeneratedColumn<int> deliveryChargeLocal = GeneratedColumn<int>(
    'delivery_charge_local',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deliveryChargeOutstationMeta =
      const VerificationMeta('deliveryChargeOutstation');
  @override
  late final GeneratedColumn<int> deliveryChargeOutstation =
      GeneratedColumn<int>(
        'delivery_charge_outstation',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _appLockEnabledMeta = const VerificationMeta(
    'appLockEnabled',
  );
  @override
  late final GeneratedColumn<bool> appLockEnabled = GeneratedColumn<bool>(
    'app_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderSeqMeta = const VerificationMeta(
    'orderSeq',
  );
  @override
  late final GeneratedColumn<int> orderSeq = GeneratedColumn<int>(
    'order_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    fieldHlcJson,
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    businessName,
    address,
    phone,
    invoicePrefix,
    upiId,
    paymentPhone,
    deliveryChargeLocal,
    deliveryChargeOutstation,
    appLockEnabled,
    deviceName,
    orderSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('field_hlc_json')) {
      context.handle(
        _fieldHlcJsonMeta,
        fieldHlcJson.isAcceptableOrUnknown(
          data['field_hlc_json']!,
          _fieldHlcJsonMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('invoice_prefix')) {
      context.handle(
        _invoicePrefixMeta,
        invoicePrefix.isAcceptableOrUnknown(
          data['invoice_prefix']!,
          _invoicePrefixMeta,
        ),
      );
    }
    if (data.containsKey('upi_id')) {
      context.handle(
        _upiIdMeta,
        upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta),
      );
    }
    if (data.containsKey('payment_phone')) {
      context.handle(
        _paymentPhoneMeta,
        paymentPhone.isAcceptableOrUnknown(
          data['payment_phone']!,
          _paymentPhoneMeta,
        ),
      );
    }
    if (data.containsKey('delivery_charge_local')) {
      context.handle(
        _deliveryChargeLocalMeta,
        deliveryChargeLocal.isAcceptableOrUnknown(
          data['delivery_charge_local']!,
          _deliveryChargeLocalMeta,
        ),
      );
    }
    if (data.containsKey('delivery_charge_outstation')) {
      context.handle(
        _deliveryChargeOutstationMeta,
        deliveryChargeOutstation.isAcceptableOrUnknown(
          data['delivery_charge_outstation']!,
          _deliveryChargeOutstationMeta,
        ),
      );
    }
    if (data.containsKey('app_lock_enabled')) {
      context.handle(
        _appLockEnabledMeta,
        appLockEnabled.isAcceptableOrUnknown(
          data['app_lock_enabled']!,
          _appLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    }
    if (data.containsKey('order_seq')) {
      context.handle(
        _orderSeqMeta,
        orderSeq.isAcceptableOrUnknown(data['order_seq']!, _orderSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      fieldHlcJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_hlc_json'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      invoicePrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_prefix'],
      )!,
      upiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_id'],
      ),
      paymentPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_phone'],
      ),
      deliveryChargeLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_charge_local'],
      )!,
      deliveryChargeOutstation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_charge_outstation'],
      )!,
      appLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_enabled'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      ),
      orderSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_seq'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String? fieldHlcJson;
  final String id;
  final String deviceId;
  final int createdAt;
  final String updatedAtHlc;
  final int? deletedAt;
  final String businessName;
  final String? address;
  final String? phone;

  /// The **order** number's prefix, despite the name — the one thing that
  /// outlived invoicing.
  final String invoicePrefix;
  final String? upiId;
  final String? paymentPhone;
  final int deliveryChargeLocal;
  final int deliveryChargeOutstation;
  final bool appLockEnabled;
  final String? deviceName;
  final int orderSeq;
  const Setting({
    this.fieldHlcJson,
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAtHlc,
    this.deletedAt,
    required this.businessName,
    this.address,
    this.phone,
    required this.invoicePrefix,
    this.upiId,
    this.paymentPhone,
    required this.deliveryChargeLocal,
    required this.deliveryChargeOutstation,
    required this.appLockEnabled,
    this.deviceName,
    required this.orderSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || fieldHlcJson != null) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson);
    }
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['business_name'] = Variable<String>(businessName);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['invoice_prefix'] = Variable<String>(invoicePrefix);
    if (!nullToAbsent || upiId != null) {
      map['upi_id'] = Variable<String>(upiId);
    }
    if (!nullToAbsent || paymentPhone != null) {
      map['payment_phone'] = Variable<String>(paymentPhone);
    }
    map['delivery_charge_local'] = Variable<int>(deliveryChargeLocal);
    map['delivery_charge_outstation'] = Variable<int>(deliveryChargeOutstation);
    map['app_lock_enabled'] = Variable<bool>(appLockEnabled);
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    map['order_seq'] = Variable<int>(orderSeq);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      fieldHlcJson: fieldHlcJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldHlcJson),
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAtHlc: Value(updatedAtHlc),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      businessName: Value(businessName),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      invoicePrefix: Value(invoicePrefix),
      upiId: upiId == null && nullToAbsent
          ? const Value.absent()
          : Value(upiId),
      paymentPhone: paymentPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentPhone),
      deliveryChargeLocal: Value(deliveryChargeLocal),
      deliveryChargeOutstation: Value(deliveryChargeOutstation),
      appLockEnabled: Value(appLockEnabled),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      orderSeq: Value(orderSeq),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      fieldHlcJson: serializer.fromJson<String?>(json['fieldHlcJson']),
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      businessName: serializer.fromJson<String>(json['businessName']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      invoicePrefix: serializer.fromJson<String>(json['invoicePrefix']),
      upiId: serializer.fromJson<String?>(json['upiId']),
      paymentPhone: serializer.fromJson<String?>(json['paymentPhone']),
      deliveryChargeLocal: serializer.fromJson<int>(
        json['deliveryChargeLocal'],
      ),
      deliveryChargeOutstation: serializer.fromJson<int>(
        json['deliveryChargeOutstation'],
      ),
      appLockEnabled: serializer.fromJson<bool>(json['appLockEnabled']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      orderSeq: serializer.fromJson<int>(json['orderSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fieldHlcJson': serializer.toJson<String?>(fieldHlcJson),
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'businessName': serializer.toJson<String>(businessName),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'invoicePrefix': serializer.toJson<String>(invoicePrefix),
      'upiId': serializer.toJson<String?>(upiId),
      'paymentPhone': serializer.toJson<String?>(paymentPhone),
      'deliveryChargeLocal': serializer.toJson<int>(deliveryChargeLocal),
      'deliveryChargeOutstation': serializer.toJson<int>(
        deliveryChargeOutstation,
      ),
      'appLockEnabled': serializer.toJson<bool>(appLockEnabled),
      'deviceName': serializer.toJson<String?>(deviceName),
      'orderSeq': serializer.toJson<int>(orderSeq),
    };
  }

  Setting copyWith({
    Value<String?> fieldHlcJson = const Value.absent(),
    String? id,
    String? deviceId,
    int? createdAt,
    String? updatedAtHlc,
    Value<int?> deletedAt = const Value.absent(),
    String? businessName,
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? invoicePrefix,
    Value<String?> upiId = const Value.absent(),
    Value<String?> paymentPhone = const Value.absent(),
    int? deliveryChargeLocal,
    int? deliveryChargeOutstation,
    bool? appLockEnabled,
    Value<String?> deviceName = const Value.absent(),
    int? orderSeq,
  }) => Setting(
    fieldHlcJson: fieldHlcJson.present ? fieldHlcJson.value : this.fieldHlcJson,
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    businessName: businessName ?? this.businessName,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    invoicePrefix: invoicePrefix ?? this.invoicePrefix,
    upiId: upiId.present ? upiId.value : this.upiId,
    paymentPhone: paymentPhone.present ? paymentPhone.value : this.paymentPhone,
    deliveryChargeLocal: deliveryChargeLocal ?? this.deliveryChargeLocal,
    deliveryChargeOutstation:
        deliveryChargeOutstation ?? this.deliveryChargeOutstation,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    deviceName: deviceName.present ? deviceName.value : this.deviceName,
    orderSeq: orderSeq ?? this.orderSeq,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      fieldHlcJson: data.fieldHlcJson.present
          ? data.fieldHlcJson.value
          : this.fieldHlcJson,
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      invoicePrefix: data.invoicePrefix.present
          ? data.invoicePrefix.value
          : this.invoicePrefix,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      paymentPhone: data.paymentPhone.present
          ? data.paymentPhone.value
          : this.paymentPhone,
      deliveryChargeLocal: data.deliveryChargeLocal.present
          ? data.deliveryChargeLocal.value
          : this.deliveryChargeLocal,
      deliveryChargeOutstation: data.deliveryChargeOutstation.present
          ? data.deliveryChargeOutstation.value
          : this.deliveryChargeOutstation,
      appLockEnabled: data.appLockEnabled.present
          ? data.appLockEnabled.value
          : this.appLockEnabled,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      orderSeq: data.orderSeq.present ? data.orderSeq.value : this.orderSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('businessName: $businessName, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('invoicePrefix: $invoicePrefix, ')
          ..write('upiId: $upiId, ')
          ..write('paymentPhone: $paymentPhone, ')
          ..write('deliveryChargeLocal: $deliveryChargeLocal, ')
          ..write('deliveryChargeOutstation: $deliveryChargeOutstation, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('deviceName: $deviceName, ')
          ..write('orderSeq: $orderSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    fieldHlcJson,
    id,
    deviceId,
    createdAt,
    updatedAtHlc,
    deletedAt,
    businessName,
    address,
    phone,
    invoicePrefix,
    upiId,
    paymentPhone,
    deliveryChargeLocal,
    deliveryChargeOutstation,
    appLockEnabled,
    deviceName,
    orderSeq,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.fieldHlcJson == this.fieldHlcJson &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.deletedAt == this.deletedAt &&
          other.businessName == this.businessName &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.invoicePrefix == this.invoicePrefix &&
          other.upiId == this.upiId &&
          other.paymentPhone == this.paymentPhone &&
          other.deliveryChargeLocal == this.deliveryChargeLocal &&
          other.deliveryChargeOutstation == this.deliveryChargeOutstation &&
          other.appLockEnabled == this.appLockEnabled &&
          other.deviceName == this.deviceName &&
          other.orderSeq == this.orderSeq);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String?> fieldHlcJson;
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String> updatedAtHlc;
  final Value<int?> deletedAt;
  final Value<String> businessName;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String> invoicePrefix;
  final Value<String?> upiId;
  final Value<String?> paymentPhone;
  final Value<int> deliveryChargeLocal;
  final Value<int> deliveryChargeOutstation;
  final Value<bool> appLockEnabled;
  final Value<String?> deviceName;
  final Value<int> orderSeq;
  final Value<int> rowid;
  const SettingsCompanion({
    this.fieldHlcJson = const Value.absent(),
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.businessName = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.invoicePrefix = const Value.absent(),
    this.upiId = const Value.absent(),
    this.paymentPhone = const Value.absent(),
    this.deliveryChargeLocal = const Value.absent(),
    this.deliveryChargeOutstation = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.orderSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.fieldHlcJson = const Value.absent(),
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.businessName = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.invoicePrefix = const Value.absent(),
    this.upiId = const Value.absent(),
    this.paymentPhone = const Value.absent(),
    this.deliveryChargeLocal = const Value.absent(),
    this.deliveryChargeOutstation = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.orderSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<String>? fieldHlcJson,
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? updatedAtHlc,
    Expression<int>? deletedAt,
    Expression<String>? businessName,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? invoicePrefix,
    Expression<String>? upiId,
    Expression<String>? paymentPhone,
    Expression<int>? deliveryChargeLocal,
    Expression<int>? deliveryChargeOutstation,
    Expression<bool>? appLockEnabled,
    Expression<String>? deviceName,
    Expression<int>? orderSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fieldHlcJson != null) 'field_hlc_json': fieldHlcJson,
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (businessName != null) 'business_name': businessName,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (invoicePrefix != null) 'invoice_prefix': invoicePrefix,
      if (upiId != null) 'upi_id': upiId,
      if (paymentPhone != null) 'payment_phone': paymentPhone,
      if (deliveryChargeLocal != null)
        'delivery_charge_local': deliveryChargeLocal,
      if (deliveryChargeOutstation != null)
        'delivery_charge_outstation': deliveryChargeOutstation,
      if (appLockEnabled != null) 'app_lock_enabled': appLockEnabled,
      if (deviceName != null) 'device_name': deviceName,
      if (orderSeq != null) 'order_seq': orderSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String?>? fieldHlcJson,
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String>? updatedAtHlc,
    Value<int?>? deletedAt,
    Value<String>? businessName,
    Value<String?>? address,
    Value<String?>? phone,
    Value<String>? invoicePrefix,
    Value<String?>? upiId,
    Value<String?>? paymentPhone,
    Value<int>? deliveryChargeLocal,
    Value<int>? deliveryChargeOutstation,
    Value<bool>? appLockEnabled,
    Value<String?>? deviceName,
    Value<int>? orderSeq,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      fieldHlcJson: fieldHlcJson ?? this.fieldHlcJson,
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      upiId: upiId ?? this.upiId,
      paymentPhone: paymentPhone ?? this.paymentPhone,
      deliveryChargeLocal: deliveryChargeLocal ?? this.deliveryChargeLocal,
      deliveryChargeOutstation:
          deliveryChargeOutstation ?? this.deliveryChargeOutstation,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      deviceName: deviceName ?? this.deviceName,
      orderSeq: orderSeq ?? this.orderSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fieldHlcJson.present) {
      map['field_hlc_json'] = Variable<String>(fieldHlcJson.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (invoicePrefix.present) {
      map['invoice_prefix'] = Variable<String>(invoicePrefix.value);
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (paymentPhone.present) {
      map['payment_phone'] = Variable<String>(paymentPhone.value);
    }
    if (deliveryChargeLocal.present) {
      map['delivery_charge_local'] = Variable<int>(deliveryChargeLocal.value);
    }
    if (deliveryChargeOutstation.present) {
      map['delivery_charge_outstation'] = Variable<int>(
        deliveryChargeOutstation.value,
      );
    }
    if (appLockEnabled.present) {
      map['app_lock_enabled'] = Variable<bool>(appLockEnabled.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (orderSeq.present) {
      map['order_seq'] = Variable<int>(orderSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('fieldHlcJson: $fieldHlcJson, ')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('businessName: $businessName, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('invoicePrefix: $invoicePrefix, ')
          ..write('upiId: $upiId, ')
          ..write('paymentPhone: $paymentPhone, ')
          ..write('deliveryChargeLocal: $deliveryChargeLocal, ')
          ..write('deliveryChargeOutstation: $deliveryChargeOutstation, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('deviceName: $deviceName, ')
          ..write('orderSeq: $orderSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $CustomerAddressesTable customerAddresses =
      $CustomerAddressesTable(this);
  late final $MenuItemsTable menuItems = $MenuItemsTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $SubOrdersTable subOrders = $SubOrdersTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $OrderItemStatusEventsTable orderItemStatusEvents =
      $OrderItemStatusEventsTable(this);
  late final $OrderItemAddonsTable orderItemAddons = $OrderItemAddonsTable(
    this,
  );
  late final $OrderStatusEventsTable orderStatusEvents =
      $OrderStatusEventsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $StockTransactionsTable stockTransactions =
      $StockTransactionsTable(this);
  late final $ShareLogTable shareLog = $ShareLogTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $ConflictLogTable conflictLog = $ConflictLogTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $AppliedOpsTable appliedOps = $AppliedOpsTable(this);
  late final $PeerCursorsTable peerCursors = $PeerCursorsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    customerAddresses,
    menuItems,
    orders,
    subOrders,
    orderItems,
    orderItemStatusEvents,
    orderItemAddons,
    orderStatusEvents,
    attachments,
    payments,
    materials,
    stockTransactions,
    shareLog,
    devices,
    conflictLog,
    outbox,
    appliedOps,
    peerCursors,
    settings,
  ];
}

typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      required String name,
      Value<String> countryCode,
      required String phoneE164,
      Value<String?> altPhone,
      Value<String?> allergyNote,
      Value<String?> notes,
      Value<String?> tags,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      Value<String> name,
      Value<String> countryCode,
      Value<String> phoneE164,
      Value<String?> altPhone,
      Value<String?> allergyNote,
      Value<String?> notes,
      Value<String?> tags,
      Value<int> rowid,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomerAddressesTable, List<CustomerAddress>>
  _customerAddressesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerAddresses,
        aliasName: 'customers__id__customer_addresses__customer_id',
      );

  $$CustomerAddressesTableProcessedTableManager get customerAddressesRefs {
    final manager = $$CustomerAddressesTableTableManager(
      $_db,
      $_db.customerAddresses,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerAddressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'customers__id__orders__customer_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altPhone => $composableBuilder(
    column: $table.altPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergyNote => $composableBuilder(
    column: $table.allergyNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customerAddressesRefs(
    Expression<bool> Function($$CustomerAddressesTableFilterComposer f) f,
  ) {
    final $$CustomerAddressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerAddresses,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerAddressesTableFilterComposer(
            $db: $db,
            $table: $db.customerAddresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altPhone => $composableBuilder(
    column: $table.altPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergyNote => $composableBuilder(
    column: $table.allergyNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumn<String> get altPhone =>
      $composableBuilder(column: $table.altPhone, builder: (column) => column);

  GeneratedColumn<String> get allergyNote => $composableBuilder(
    column: $table.allergyNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> customerAddressesRefs<T extends Object>(
    Expression<T> Function($$CustomerAddressesTableAnnotationComposer a) f,
  ) {
    final $$CustomerAddressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerAddresses,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerAddressesTableAnnotationComposer(
                $db: $db,
                $table: $db.customerAddresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({bool customerAddressesRefs, bool ordersRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<String> phoneE164 = const Value.absent(),
                Value<String?> altPhone = const Value.absent(),
                Value<String?> allergyNote = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                name: name,
                countryCode: countryCode,
                phoneE164: phoneE164,
                altPhone: altPhone,
                allergyNote: allergyNote,
                notes: notes,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                required String name,
                Value<String> countryCode = const Value.absent(),
                required String phoneE164,
                Value<String?> altPhone = const Value.absent(),
                Value<String?> allergyNote = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                name: name,
                countryCode: countryCode,
                phoneE164: phoneE164,
                altPhone: altPhone,
                allergyNote: allergyNote,
                notes: notes,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerAddressesRefs = false, ordersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (customerAddressesRefs) db.customerAddresses,
                    if (ordersRefs) db.orders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (customerAddressesRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          CustomerAddress
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerAddressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerAddressesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ordersRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          Order
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({bool customerAddressesRefs, bool ordersRefs})
    >;
typedef $$CustomerAddressesTableCreateCompanionBuilder =
    CustomerAddressesCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      required String customerId,
      required String label,
      required String addressText,
      Value<double?> pinLat,
      Value<double?> pinLng,
      Value<String?> pinUrl,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$CustomerAddressesTableUpdateCompanionBuilder =
    CustomerAddressesCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      Value<String> customerId,
      Value<String> label,
      Value<String> addressText,
      Value<double?> pinLat,
      Value<double?> pinLng,
      Value<String?> pinUrl,
      Value<bool> isDefault,
      Value<int> rowid,
    });

final class $$CustomerAddressesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerAddressesTable,
          CustomerAddress
        > {
  $$CustomerAddressesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) => db.customers
      .createAlias('customer_addresses__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerAddressesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerAddressesTable> {
  $$CustomerAddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pinLat => $composableBuilder(
    column: $table.pinLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pinLng => $composableBuilder(
    column: $table.pinLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinUrl => $composableBuilder(
    column: $table.pinUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerAddressesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerAddressesTable> {
  $$CustomerAddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pinLat => $composableBuilder(
    column: $table.pinLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pinLng => $composableBuilder(
    column: $table.pinLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinUrl => $composableBuilder(
    column: $table.pinUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerAddressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerAddressesTable> {
  $$CustomerAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pinLat =>
      $composableBuilder(column: $table.pinLat, builder: (column) => column);

  GeneratedColumn<double> get pinLng =>
      $composableBuilder(column: $table.pinLng, builder: (column) => column);

  GeneratedColumn<String> get pinUrl =>
      $composableBuilder(column: $table.pinUrl, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerAddressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerAddressesTable,
          CustomerAddress,
          $$CustomerAddressesTableFilterComposer,
          $$CustomerAddressesTableOrderingComposer,
          $$CustomerAddressesTableAnnotationComposer,
          $$CustomerAddressesTableCreateCompanionBuilder,
          $$CustomerAddressesTableUpdateCompanionBuilder,
          (CustomerAddress, $$CustomerAddressesTableReferences),
          CustomerAddress,
          PrefetchHooks Function({bool customerId})
        > {
  $$CustomerAddressesTableTableManager(
    _$AppDatabase db,
    $CustomerAddressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerAddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerAddressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> addressText = const Value.absent(),
                Value<double?> pinLat = const Value.absent(),
                Value<double?> pinLng = const Value.absent(),
                Value<String?> pinUrl = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerAddressesCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                customerId: customerId,
                label: label,
                addressText: addressText,
                pinLat: pinLat,
                pinLng: pinLng,
                pinUrl: pinUrl,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                required String customerId,
                required String label,
                required String addressText,
                Value<double?> pinLat = const Value.absent(),
                Value<double?> pinLng = const Value.absent(),
                Value<String?> pinUrl = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerAddressesCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                customerId: customerId,
                label: label,
                addressText: addressText,
                pinLat: pinLat,
                pinLng: pinLng,
                pinUrl: pinUrl,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerAddressesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable:
                                    $$CustomerAddressesTableReferences
                                        ._customerIdTable(db),
                                referencedColumn:
                                    $$CustomerAddressesTableReferences
                                        ._customerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerAddressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerAddressesTable,
      CustomerAddress,
      $$CustomerAddressesTableFilterComposer,
      $$CustomerAddressesTableOrderingComposer,
      $$CustomerAddressesTableAnnotationComposer,
      $$CustomerAddressesTableCreateCompanionBuilder,
      $$CustomerAddressesTableUpdateCompanionBuilder,
      (CustomerAddress, $$CustomerAddressesTableReferences),
      CustomerAddress,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$MenuItemsTableCreateCompanionBuilder =
    MenuItemsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      required String name,
      Value<String?> photoPath,
      Value<int> leadDays,
      Value<bool> active,
      Value<int?> seasonFrom,
      Value<int?> seasonTo,
      Value<int> rowid,
    });
typedef $$MenuItemsTableUpdateCompanionBuilder =
    MenuItemsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      Value<String> name,
      Value<String?> photoPath,
      Value<int> leadDays,
      Value<bool> active,
      Value<int?> seasonFrom,
      Value<int?> seasonTo,
      Value<int> rowid,
    });

final class $$MenuItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MenuItemsTable, MenuItem> {
  $$MenuItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
  _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderItems,
    aliasName: 'menu_items__id__order_items__menu_item_id',
  );

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager(
      $_db,
      $_db.orderItems,
    ).filter((f) => f.menuItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MenuItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MenuItemsTable> {
  $$MenuItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leadDays => $composableBuilder(
    column: $table.leadDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonFrom => $composableBuilder(
    column: $table.seasonFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonTo => $composableBuilder(
    column: $table.seasonTo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> orderItemsRefs(
    Expression<bool> Function($$OrderItemsTableFilterComposer f) f,
  ) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.menuItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MenuItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MenuItemsTable> {
  $$MenuItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leadDays => $composableBuilder(
    column: $table.leadDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonFrom => $composableBuilder(
    column: $table.seasonFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonTo => $composableBuilder(
    column: $table.seasonTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MenuItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MenuItemsTable> {
  $$MenuItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get leadDays =>
      $composableBuilder(column: $table.leadDays, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get seasonFrom => $composableBuilder(
    column: $table.seasonFrom,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seasonTo =>
      $composableBuilder(column: $table.seasonTo, builder: (column) => column);

  Expression<T> orderItemsRefs<T extends Object>(
    Expression<T> Function($$OrderItemsTableAnnotationComposer a) f,
  ) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.menuItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MenuItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MenuItemsTable,
          MenuItem,
          $$MenuItemsTableFilterComposer,
          $$MenuItemsTableOrderingComposer,
          $$MenuItemsTableAnnotationComposer,
          $$MenuItemsTableCreateCompanionBuilder,
          $$MenuItemsTableUpdateCompanionBuilder,
          (MenuItem, $$MenuItemsTableReferences),
          MenuItem,
          PrefetchHooks Function({bool orderItemsRefs})
        > {
  $$MenuItemsTableTableManager(_$AppDatabase db, $MenuItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenuItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenuItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenuItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> leadDays = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int?> seasonFrom = const Value.absent(),
                Value<int?> seasonTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MenuItemsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                name: name,
                photoPath: photoPath,
                leadDays: leadDays,
                active: active,
                seasonFrom: seasonFrom,
                seasonTo: seasonTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                required String name,
                Value<String?> photoPath = const Value.absent(),
                Value<int> leadDays = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int?> seasonFrom = const Value.absent(),
                Value<int?> seasonTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MenuItemsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                name: name,
                photoPath: photoPath,
                leadDays: leadDays,
                active: active,
                seasonFrom: seasonFrom,
                seasonTo: seasonTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MenuItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (orderItemsRefs) db.orderItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsRefs)
                    await $_getPrefetchedData<
                      MenuItem,
                      $MenuItemsTable,
                      OrderItem
                    >(
                      currentTable: table,
                      referencedTable: $$MenuItemsTableReferences
                          ._orderItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MenuItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).orderItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.menuItemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MenuItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MenuItemsTable,
      MenuItem,
      $$MenuItemsTableFilterComposer,
      $$MenuItemsTableOrderingComposer,
      $$MenuItemsTableAnnotationComposer,
      $$MenuItemsTableCreateCompanionBuilder,
      $$MenuItemsTableUpdateCompanionBuilder,
      (MenuItem, $$MenuItemsTableReferences),
      MenuItem,
      PrefetchHooks Function({bool orderItemsRefs})
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      required String orderNo,
      required String customerId,
      required String status,
      required String fulfilment,
      required int deliveryDate,
      Value<int?> deliveryTime,
      Value<String?> deliveryType,
      Value<String?> addressText,
      Value<double?> pinLat,
      Value<double?> pinLng,
      Value<String?> pinUrl,
      Value<String?> trackingUrl,
      Value<String?> discountType,
      Value<int?> discountValue,
      Value<int> discountAmount,
      Value<int> deliveryCharge,
      Value<String?> requirements,
      Value<String?> itemMessage,
      Value<int> dietaryFlags,
      Value<int?> requirementsChangedAt,
      Value<int?> requirementsAckAt,
      Value<String?> source,
      Value<String?> notes,
      Value<String?> cancelReason,
      Value<int?> deliveredAt,
      Value<int?> confirmedAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });
typedef $$OrdersTableUpdateCompanionBuilder =
    OrdersCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      Value<String> orderNo,
      Value<String> customerId,
      Value<String> status,
      Value<String> fulfilment,
      Value<int> deliveryDate,
      Value<int?> deliveryTime,
      Value<String?> deliveryType,
      Value<String?> addressText,
      Value<double?> pinLat,
      Value<double?> pinLng,
      Value<String?> pinUrl,
      Value<String?> trackingUrl,
      Value<String?> discountType,
      Value<int?> discountValue,
      Value<int> discountAmount,
      Value<int> deliveryCharge,
      Value<String?> requirements,
      Value<String?> itemMessage,
      Value<int> dietaryFlags,
      Value<int?> requirementsChangedAt,
      Value<int?> requirementsAckAt,
      Value<String?> source,
      Value<String?> notes,
      Value<String?> cancelReason,
      Value<int?> deliveredAt,
      Value<int?> confirmedAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, Order> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('orders__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SubOrdersTable, List<SubOrderRow>>
  _subOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subOrders,
    aliasName: 'orders__id__sub_orders__order_id',
  );

  $$SubOrdersTableProcessedTableManager get subOrdersRefs {
    final manager = $$SubOrdersTableTableManager(
      $_db,
      $_db.subOrders,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
  _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderItems,
    aliasName: 'orders__id__order_items__order_id',
  );

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager(
      $_db,
      $_db.orderItems,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrderStatusEventsTable, List<OrderStatusEvent>>
  _orderStatusEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.orderStatusEvents,
        aliasName: 'orders__id__order_status_events__order_id',
      );

  $$OrderStatusEventsTableProcessedTableManager get orderStatusEventsRefs {
    final manager = $$OrderStatusEventsTableTableManager(
      $_db,
      $_db.orderStatusEvents,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _orderStatusEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'orders__id__attachments__order_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'orders__id__payments__order_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShareLogTable, List<ShareLogData>>
  _shareLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shareLog,
    aliasName: 'orders__id__share_log__order_id',
  );

  $$ShareLogTableProcessedTableManager get shareLogRefs {
    final manager = $$ShareLogTableTableManager(
      $_db,
      $_db.shareLog,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shareLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNo => $composableBuilder(
    column: $table.orderNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fulfilment => $composableBuilder(
    column: $table.fulfilment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pinLat => $composableBuilder(
    column: $table.pinLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pinLng => $composableBuilder(
    column: $table.pinLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinUrl => $composableBuilder(
    column: $table.pinUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingUrl => $composableBuilder(
    column: $table.trackingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryCharge => $composableBuilder(
    column: $table.deliveryCharge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requirements => $composableBuilder(
    column: $table.requirements,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemMessage => $composableBuilder(
    column: $table.itemMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requirementsChangedAt => $composableBuilder(
    column: $table.requirementsChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requirementsAckAt => $composableBuilder(
    column: $table.requirementsAckAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> subOrdersRefs(
    Expression<bool> Function($$SubOrdersTableFilterComposer f) f,
  ) {
    final $$SubOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subOrders,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubOrdersTableFilterComposer(
            $db: $db,
            $table: $db.subOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orderItemsRefs(
    Expression<bool> Function($$OrderItemsTableFilterComposer f) f,
  ) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orderStatusEventsRefs(
    Expression<bool> Function($$OrderStatusEventsTableFilterComposer f) f,
  ) {
    final $$OrderStatusEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderStatusEvents,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderStatusEventsTableFilterComposer(
            $db: $db,
            $table: $db.orderStatusEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shareLogRefs(
    Expression<bool> Function($$ShareLogTableFilterComposer f) f,
  ) {
    final $$ShareLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareLog,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareLogTableFilterComposer(
            $db: $db,
            $table: $db.shareLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNo => $composableBuilder(
    column: $table.orderNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fulfilment => $composableBuilder(
    column: $table.fulfilment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pinLat => $composableBuilder(
    column: $table.pinLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pinLng => $composableBuilder(
    column: $table.pinLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinUrl => $composableBuilder(
    column: $table.pinUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingUrl => $composableBuilder(
    column: $table.trackingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryCharge => $composableBuilder(
    column: $table.deliveryCharge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requirements => $composableBuilder(
    column: $table.requirements,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemMessage => $composableBuilder(
    column: $table.itemMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requirementsChangedAt => $composableBuilder(
    column: $table.requirementsChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requirementsAckAt => $composableBuilder(
    column: $table.requirementsAckAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderNo =>
      $composableBuilder(column: $table.orderNo, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get fulfilment => $composableBuilder(
    column: $table.fulfilment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pinLat =>
      $composableBuilder(column: $table.pinLat, builder: (column) => column);

  GeneratedColumn<double> get pinLng =>
      $composableBuilder(column: $table.pinLng, builder: (column) => column);

  GeneratedColumn<String> get pinUrl =>
      $composableBuilder(column: $table.pinUrl, builder: (column) => column);

  GeneratedColumn<String> get trackingUrl => $composableBuilder(
    column: $table.trackingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryCharge => $composableBuilder(
    column: $table.deliveryCharge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requirements => $composableBuilder(
    column: $table.requirements,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemMessage => $composableBuilder(
    column: $table.itemMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requirementsChangedAt => $composableBuilder(
    column: $table.requirementsChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requirementsAckAt => $composableBuilder(
    column: $table.requirementsAckAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> subOrdersRefs<T extends Object>(
    Expression<T> Function($$SubOrdersTableAnnotationComposer a) f,
  ) {
    final $$SubOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subOrders,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.subOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> orderItemsRefs<T extends Object>(
    Expression<T> Function($$OrderItemsTableAnnotationComposer a) f,
  ) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> orderStatusEventsRefs<T extends Object>(
    Expression<T> Function($$OrderStatusEventsTableAnnotationComposer a) f,
  ) {
    final $$OrderStatusEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.orderStatusEvents,
          getReferencedColumn: (t) => t.orderId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrderStatusEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.orderStatusEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shareLogRefs<T extends Object>(
    Expression<T> Function($$ShareLogTableAnnotationComposer a) f,
  ) {
    final $$ShareLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareLog,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareLogTableAnnotationComposer(
            $db: $db,
            $table: $db.shareLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, $$OrdersTableReferences),
          Order,
          PrefetchHooks Function({
            bool customerId,
            bool subOrdersRefs,
            bool orderItemsRefs,
            bool orderStatusEventsRefs,
            bool attachmentsRefs,
            bool paymentsRefs,
            bool shareLogRefs,
          })
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                Value<String> orderNo = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> fulfilment = const Value.absent(),
                Value<int> deliveryDate = const Value.absent(),
                Value<int?> deliveryTime = const Value.absent(),
                Value<String?> deliveryType = const Value.absent(),
                Value<String?> addressText = const Value.absent(),
                Value<double?> pinLat = const Value.absent(),
                Value<double?> pinLng = const Value.absent(),
                Value<String?> pinUrl = const Value.absent(),
                Value<String?> trackingUrl = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<int?> discountValue = const Value.absent(),
                Value<int> discountAmount = const Value.absent(),
                Value<int> deliveryCharge = const Value.absent(),
                Value<String?> requirements = const Value.absent(),
                Value<String?> itemMessage = const Value.absent(),
                Value<int> dietaryFlags = const Value.absent(),
                Value<int?> requirementsChangedAt = const Value.absent(),
                Value<int?> requirementsAckAt = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<int?> confirmedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                orderNo: orderNo,
                customerId: customerId,
                status: status,
                fulfilment: fulfilment,
                deliveryDate: deliveryDate,
                deliveryTime: deliveryTime,
                deliveryType: deliveryType,
                addressText: addressText,
                pinLat: pinLat,
                pinLng: pinLng,
                pinUrl: pinUrl,
                trackingUrl: trackingUrl,
                discountType: discountType,
                discountValue: discountValue,
                discountAmount: discountAmount,
                deliveryCharge: deliveryCharge,
                requirements: requirements,
                itemMessage: itemMessage,
                dietaryFlags: dietaryFlags,
                requirementsChangedAt: requirementsChangedAt,
                requirementsAckAt: requirementsAckAt,
                source: source,
                notes: notes,
                cancelReason: cancelReason,
                deliveredAt: deliveredAt,
                confirmedAt: confirmedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                required String orderNo,
                required String customerId,
                required String status,
                required String fulfilment,
                required int deliveryDate,
                Value<int?> deliveryTime = const Value.absent(),
                Value<String?> deliveryType = const Value.absent(),
                Value<String?> addressText = const Value.absent(),
                Value<double?> pinLat = const Value.absent(),
                Value<double?> pinLng = const Value.absent(),
                Value<String?> pinUrl = const Value.absent(),
                Value<String?> trackingUrl = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<int?> discountValue = const Value.absent(),
                Value<int> discountAmount = const Value.absent(),
                Value<int> deliveryCharge = const Value.absent(),
                Value<String?> requirements = const Value.absent(),
                Value<String?> itemMessage = const Value.absent(),
                Value<int> dietaryFlags = const Value.absent(),
                Value<int?> requirementsChangedAt = const Value.absent(),
                Value<int?> requirementsAckAt = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<int?> confirmedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                orderNo: orderNo,
                customerId: customerId,
                status: status,
                fulfilment: fulfilment,
                deliveryDate: deliveryDate,
                deliveryTime: deliveryTime,
                deliveryType: deliveryType,
                addressText: addressText,
                pinLat: pinLat,
                pinLng: pinLng,
                pinUrl: pinUrl,
                trackingUrl: trackingUrl,
                discountType: discountType,
                discountValue: discountValue,
                discountAmount: discountAmount,
                deliveryCharge: deliveryCharge,
                requirements: requirements,
                itemMessage: itemMessage,
                dietaryFlags: dietaryFlags,
                requirementsChangedAt: requirementsChangedAt,
                requirementsAckAt: requirementsAckAt,
                source: source,
                notes: notes,
                cancelReason: cancelReason,
                deliveredAt: deliveredAt,
                confirmedAt: confirmedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$OrdersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                subOrdersRefs = false,
                orderItemsRefs = false,
                orderStatusEventsRefs = false,
                attachmentsRefs = false,
                paymentsRefs = false,
                shareLogRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (subOrdersRefs) db.subOrders,
                    if (orderItemsRefs) db.orderItems,
                    if (orderStatusEventsRefs) db.orderStatusEvents,
                    if (attachmentsRefs) db.attachments,
                    if (paymentsRefs) db.payments,
                    if (shareLogRefs) db.shareLog,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$OrdersTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subOrdersRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          SubOrderRow
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._subOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).subOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (orderItemsRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          OrderItem
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._orderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).orderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (orderStatusEventsRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          OrderStatusEvent
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._orderStatusEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).orderStatusEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          Attachment
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<Order, $OrdersTable, Payment>(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shareLogRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          ShareLogData
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._shareLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).shareLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, $$OrdersTableReferences),
      Order,
      PrefetchHooks Function({
        bool customerId,
        bool subOrdersRefs,
        bool orderItemsRefs,
        bool orderStatusEventsRefs,
        bool attachmentsRefs,
        bool paymentsRefs,
        bool shareLogRefs,
      })
    >;
typedef $$SubOrdersTableCreateCompanionBuilder =
    SubOrdersCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderId,
      required int seq,
      Value<String> status,
      required int deliveryDate,
      Value<int?> deliveryTime,
      required String fulfilment,
      Value<String?> deliveryType,
      Value<String?> addressText,
      Value<double?> pinLat,
      Value<double?> pinLng,
      Value<String?> pinUrl,
      Value<int> deliveryCharge,
      Value<String?> trackingUrl,
      Value<int?> deliveredAt,
      Value<int> rowid,
    });
typedef $$SubOrdersTableUpdateCompanionBuilder =
    SubOrdersCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderId,
      Value<int> seq,
      Value<String> status,
      Value<int> deliveryDate,
      Value<int?> deliveryTime,
      Value<String> fulfilment,
      Value<String?> deliveryType,
      Value<String?> addressText,
      Value<double?> pinLat,
      Value<double?> pinLng,
      Value<String?> pinUrl,
      Value<int> deliveryCharge,
      Value<String?> trackingUrl,
      Value<int?> deliveredAt,
      Value<int> rowid,
    });

final class $$SubOrdersTableReferences
    extends BaseReferences<_$AppDatabase, $SubOrdersTable, SubOrderRow> {
  $$SubOrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('sub_orders__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
  _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderItems,
    aliasName: 'sub_orders__id__order_items__sub_order_id',
  );

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager(
      $_db,
      $_db.orderItems,
    ).filter((f) => f.subOrderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $SubOrdersTable> {
  $$SubOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fulfilment => $composableBuilder(
    column: $table.fulfilment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pinLat => $composableBuilder(
    column: $table.pinLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pinLng => $composableBuilder(
    column: $table.pinLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinUrl => $composableBuilder(
    column: $table.pinUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryCharge => $composableBuilder(
    column: $table.deliveryCharge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingUrl => $composableBuilder(
    column: $table.trackingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> orderItemsRefs(
    Expression<bool> Function($$OrderItemsTableFilterComposer f) f,
  ) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.subOrderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $SubOrdersTable> {
  $$SubOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fulfilment => $composableBuilder(
    column: $table.fulfilment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pinLat => $composableBuilder(
    column: $table.pinLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pinLng => $composableBuilder(
    column: $table.pinLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinUrl => $composableBuilder(
    column: $table.pinUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryCharge => $composableBuilder(
    column: $table.deliveryCharge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingUrl => $composableBuilder(
    column: $table.trackingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubOrdersTable> {
  $$SubOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fulfilment => $composableBuilder(
    column: $table.fulfilment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pinLat =>
      $composableBuilder(column: $table.pinLat, builder: (column) => column);

  GeneratedColumn<double> get pinLng =>
      $composableBuilder(column: $table.pinLng, builder: (column) => column);

  GeneratedColumn<String> get pinUrl =>
      $composableBuilder(column: $table.pinUrl, builder: (column) => column);

  GeneratedColumn<int> get deliveryCharge => $composableBuilder(
    column: $table.deliveryCharge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trackingUrl => $composableBuilder(
    column: $table.trackingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> orderItemsRefs<T extends Object>(
    Expression<T> Function($$OrderItemsTableAnnotationComposer a) f,
  ) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.subOrderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubOrdersTable,
          SubOrderRow,
          $$SubOrdersTableFilterComposer,
          $$SubOrdersTableOrderingComposer,
          $$SubOrdersTableAnnotationComposer,
          $$SubOrdersTableCreateCompanionBuilder,
          $$SubOrdersTableUpdateCompanionBuilder,
          (SubOrderRow, $$SubOrdersTableReferences),
          SubOrderRow,
          PrefetchHooks Function({bool orderId, bool orderItemsRefs})
        > {
  $$SubOrdersTableTableManager(_$AppDatabase db, $SubOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> deliveryDate = const Value.absent(),
                Value<int?> deliveryTime = const Value.absent(),
                Value<String> fulfilment = const Value.absent(),
                Value<String?> deliveryType = const Value.absent(),
                Value<String?> addressText = const Value.absent(),
                Value<double?> pinLat = const Value.absent(),
                Value<double?> pinLng = const Value.absent(),
                Value<String?> pinUrl = const Value.absent(),
                Value<int> deliveryCharge = const Value.absent(),
                Value<String?> trackingUrl = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubOrdersCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                seq: seq,
                status: status,
                deliveryDate: deliveryDate,
                deliveryTime: deliveryTime,
                fulfilment: fulfilment,
                deliveryType: deliveryType,
                addressText: addressText,
                pinLat: pinLat,
                pinLng: pinLng,
                pinUrl: pinUrl,
                deliveryCharge: deliveryCharge,
                trackingUrl: trackingUrl,
                deliveredAt: deliveredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderId,
                required int seq,
                Value<String> status = const Value.absent(),
                required int deliveryDate,
                Value<int?> deliveryTime = const Value.absent(),
                required String fulfilment,
                Value<String?> deliveryType = const Value.absent(),
                Value<String?> addressText = const Value.absent(),
                Value<double?> pinLat = const Value.absent(),
                Value<double?> pinLng = const Value.absent(),
                Value<String?> pinUrl = const Value.absent(),
                Value<int> deliveryCharge = const Value.absent(),
                Value<String?> trackingUrl = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubOrdersCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                seq: seq,
                status: status,
                deliveryDate: deliveryDate,
                deliveryTime: deliveryTime,
                fulfilment: fulfilment,
                deliveryType: deliveryType,
                addressText: addressText,
                pinLat: pinLat,
                pinLng: pinLng,
                pinUrl: pinUrl,
                deliveryCharge: deliveryCharge,
                trackingUrl: trackingUrl,
                deliveredAt: deliveredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false, orderItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (orderItemsRefs) db.orderItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$SubOrdersTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$SubOrdersTableReferences
                                    ._orderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsRefs)
                    await $_getPrefetchedData<
                      SubOrderRow,
                      $SubOrdersTable,
                      OrderItem
                    >(
                      currentTable: table,
                      referencedTable: $$SubOrdersTableReferences
                          ._orderItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubOrdersTableReferences(
                            db,
                            table,
                            p0,
                          ).orderItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.subOrderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubOrdersTable,
      SubOrderRow,
      $$SubOrdersTableFilterComposer,
      $$SubOrdersTableOrderingComposer,
      $$SubOrdersTableAnnotationComposer,
      $$SubOrdersTableCreateCompanionBuilder,
      $$SubOrdersTableUpdateCompanionBuilder,
      (SubOrderRow, $$SubOrdersTableReferences),
      SubOrderRow,
      PrefetchHooks Function({bool orderId, bool orderItemsRefs})
    >;
typedef $$OrderItemsTableCreateCompanionBuilder =
    OrderItemsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderId,
      required String menuItemId,
      required String itemNameSnapshot,
      Value<String?> flavour,
      Value<double?> weightValue,
      Value<String?> weightUnit,
      Value<int> qty,
      required int basePrice,
      Value<String?> note,
      required int position,
      required String subOrderId,
      Value<String> status,
      Value<int?> deliveredAt,
      Value<String?> cancelReason,
      Value<String?> itemMessage,
      Value<String?> requirements,
      Value<int> dietaryFlags,
      Value<String?> discountType,
      Value<int> discountValue,
      Value<int> rowid,
    });
typedef $$OrderItemsTableUpdateCompanionBuilder =
    OrderItemsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderId,
      Value<String> menuItemId,
      Value<String> itemNameSnapshot,
      Value<String?> flavour,
      Value<double?> weightValue,
      Value<String?> weightUnit,
      Value<int> qty,
      Value<int> basePrice,
      Value<String?> note,
      Value<int> position,
      Value<String> subOrderId,
      Value<String> status,
      Value<int?> deliveredAt,
      Value<String?> cancelReason,
      Value<String?> itemMessage,
      Value<String?> requirements,
      Value<int> dietaryFlags,
      Value<String?> discountType,
      Value<int> discountValue,
      Value<int> rowid,
    });

final class $$OrderItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem> {
  $$OrderItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('order_items__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MenuItemsTable _menuItemIdTable(_$AppDatabase db) =>
      db.menuItems.createAlias('order_items__menu_item_id__menu_items__id');

  $$MenuItemsTableProcessedTableManager get menuItemId {
    final $_column = $_itemColumn<String>('menu_item_id')!;

    final manager = $$MenuItemsTableTableManager(
      $_db,
      $_db.menuItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_menuItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubOrdersTable _subOrderIdTable(_$AppDatabase db) =>
      db.subOrders.createAlias('order_items__sub_order_id__sub_orders__id');

  $$SubOrdersTableProcessedTableManager get subOrderId {
    final $_column = $_itemColumn<String>('sub_order_id')!;

    final manager = $$SubOrdersTableTableManager(
      $_db,
      $_db.subOrders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subOrderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $OrderItemStatusEventsTable,
    List<OrderItemStatusEvent>
  >
  _orderItemStatusEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.orderItemStatusEvents,
        aliasName: 'order_items__id__order_item_status_events__order_item_id',
      );

  $$OrderItemStatusEventsTableProcessedTableManager
  get orderItemStatusEventsRefs {
    final manager = $$OrderItemStatusEventsTableTableManager(
      $_db,
      $_db.orderItemStatusEvents,
    ).filter((f) => f.orderItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _orderItemStatusEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrderItemAddonsTable, List<OrderItemAddon>>
  _orderItemAddonsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderItemAddons,
    aliasName: 'order_items__id__order_item_addons__order_item_id',
  );

  $$OrderItemAddonsTableProcessedTableManager get orderItemAddonsRefs {
    final manager = $$OrderItemAddonsTableTableManager(
      $_db,
      $_db.orderItemAddons,
    ).filter((f) => f.orderItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _orderItemAddonsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemNameSnapshot => $composableBuilder(
    column: $table.itemNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavour => $composableBuilder(
    column: $table.flavour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightValue => $composableBuilder(
    column: $table.weightValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemMessage => $composableBuilder(
    column: $table.itemMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requirements => $composableBuilder(
    column: $table.requirements,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MenuItemsTableFilterComposer get menuItemId {
    final $$MenuItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.menuItemId,
      referencedTable: $db.menuItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MenuItemsTableFilterComposer(
            $db: $db,
            $table: $db.menuItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubOrdersTableFilterComposer get subOrderId {
    final $$SubOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subOrderId,
      referencedTable: $db.subOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubOrdersTableFilterComposer(
            $db: $db,
            $table: $db.subOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> orderItemStatusEventsRefs(
    Expression<bool> Function($$OrderItemStatusEventsTableFilterComposer f) f,
  ) {
    final $$OrderItemStatusEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.orderItemStatusEvents,
          getReferencedColumn: (t) => t.orderItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrderItemStatusEventsTableFilterComposer(
                $db: $db,
                $table: $db.orderItemStatusEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> orderItemAddonsRefs(
    Expression<bool> Function($$OrderItemAddonsTableFilterComposer f) f,
  ) {
    final $$OrderItemAddonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItemAddons,
      getReferencedColumn: (t) => t.orderItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemAddonsTableFilterComposer(
            $db: $db,
            $table: $db.orderItemAddons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemNameSnapshot => $composableBuilder(
    column: $table.itemNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavour => $composableBuilder(
    column: $table.flavour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightValue => $composableBuilder(
    column: $table.weightValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemMessage => $composableBuilder(
    column: $table.itemMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requirements => $composableBuilder(
    column: $table.requirements,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MenuItemsTableOrderingComposer get menuItemId {
    final $$MenuItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.menuItemId,
      referencedTable: $db.menuItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MenuItemsTableOrderingComposer(
            $db: $db,
            $table: $db.menuItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubOrdersTableOrderingComposer get subOrderId {
    final $$SubOrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subOrderId,
      referencedTable: $db.subOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubOrdersTableOrderingComposer(
            $db: $db,
            $table: $db.subOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get itemNameSnapshot => $composableBuilder(
    column: $table.itemNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavour =>
      $composableBuilder(column: $table.flavour, builder: (column) => column);

  GeneratedColumn<double> get weightValue => $composableBuilder(
    column: $table.weightValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get basePrice =>
      $composableBuilder(column: $table.basePrice, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemMessage => $composableBuilder(
    column: $table.itemMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requirements => $composableBuilder(
    column: $table.requirements,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MenuItemsTableAnnotationComposer get menuItemId {
    final $$MenuItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.menuItemId,
      referencedTable: $db.menuItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MenuItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.menuItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubOrdersTableAnnotationComposer get subOrderId {
    final $$SubOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subOrderId,
      referencedTable: $db.subOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.subOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> orderItemStatusEventsRefs<T extends Object>(
    Expression<T> Function($$OrderItemStatusEventsTableAnnotationComposer a) f,
  ) {
    final $$OrderItemStatusEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.orderItemStatusEvents,
          getReferencedColumn: (t) => t.orderItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrderItemStatusEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.orderItemStatusEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> orderItemAddonsRefs<T extends Object>(
    Expression<T> Function($$OrderItemAddonsTableAnnotationComposer a) f,
  ) {
    final $$OrderItemAddonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItemAddons,
      getReferencedColumn: (t) => t.orderItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemAddonsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderItemAddons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderItemsTable,
          OrderItem,
          $$OrderItemsTableFilterComposer,
          $$OrderItemsTableOrderingComposer,
          $$OrderItemsTableAnnotationComposer,
          $$OrderItemsTableCreateCompanionBuilder,
          $$OrderItemsTableUpdateCompanionBuilder,
          (OrderItem, $$OrderItemsTableReferences),
          OrderItem,
          PrefetchHooks Function({
            bool orderId,
            bool menuItemId,
            bool subOrderId,
            bool orderItemStatusEventsRefs,
            bool orderItemAddonsRefs,
          })
        > {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> menuItemId = const Value.absent(),
                Value<String> itemNameSnapshot = const Value.absent(),
                Value<String?> flavour = const Value.absent(),
                Value<double?> weightValue = const Value.absent(),
                Value<String?> weightUnit = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int> basePrice = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> subOrderId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<String?> itemMessage = const Value.absent(),
                Value<String?> requirements = const Value.absent(),
                Value<int> dietaryFlags = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<int> discountValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                menuItemId: menuItemId,
                itemNameSnapshot: itemNameSnapshot,
                flavour: flavour,
                weightValue: weightValue,
                weightUnit: weightUnit,
                qty: qty,
                basePrice: basePrice,
                note: note,
                position: position,
                subOrderId: subOrderId,
                status: status,
                deliveredAt: deliveredAt,
                cancelReason: cancelReason,
                itemMessage: itemMessage,
                requirements: requirements,
                dietaryFlags: dietaryFlags,
                discountType: discountType,
                discountValue: discountValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderId,
                required String menuItemId,
                required String itemNameSnapshot,
                Value<String?> flavour = const Value.absent(),
                Value<double?> weightValue = const Value.absent(),
                Value<String?> weightUnit = const Value.absent(),
                Value<int> qty = const Value.absent(),
                required int basePrice,
                Value<String?> note = const Value.absent(),
                required int position,
                required String subOrderId,
                Value<String> status = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<String?> itemMessage = const Value.absent(),
                Value<String?> requirements = const Value.absent(),
                Value<int> dietaryFlags = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<int> discountValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                menuItemId: menuItemId,
                itemNameSnapshot: itemNameSnapshot,
                flavour: flavour,
                weightValue: weightValue,
                weightUnit: weightUnit,
                qty: qty,
                basePrice: basePrice,
                note: note,
                position: position,
                subOrderId: subOrderId,
                status: status,
                deliveredAt: deliveredAt,
                cancelReason: cancelReason,
                itemMessage: itemMessage,
                requirements: requirements,
                dietaryFlags: dietaryFlags,
                discountType: discountType,
                discountValue: discountValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrderItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                orderId = false,
                menuItemId = false,
                subOrderId = false,
                orderItemStatusEventsRefs = false,
                orderItemAddonsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (orderItemStatusEventsRefs) db.orderItemStatusEvents,
                    if (orderItemAddonsRefs) db.orderItemAddons,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (orderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.orderId,
                                    referencedTable: $$OrderItemsTableReferences
                                        ._orderIdTable(db),
                                    referencedColumn:
                                        $$OrderItemsTableReferences
                                            ._orderIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (menuItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.menuItemId,
                                    referencedTable: $$OrderItemsTableReferences
                                        ._menuItemIdTable(db),
                                    referencedColumn:
                                        $$OrderItemsTableReferences
                                            ._menuItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (subOrderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subOrderId,
                                    referencedTable: $$OrderItemsTableReferences
                                        ._subOrderIdTable(db),
                                    referencedColumn:
                                        $$OrderItemsTableReferences
                                            ._subOrderIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (orderItemStatusEventsRefs)
                        await $_getPrefetchedData<
                          OrderItem,
                          $OrderItemsTable,
                          OrderItemStatusEvent
                        >(
                          currentTable: table,
                          referencedTable: $$OrderItemsTableReferences
                              ._orderItemStatusEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrderItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).orderItemStatusEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (orderItemAddonsRefs)
                        await $_getPrefetchedData<
                          OrderItem,
                          $OrderItemsTable,
                          OrderItemAddon
                        >(
                          currentTable: table,
                          referencedTable: $$OrderItemsTableReferences
                              ._orderItemAddonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrderItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).orderItemAddonsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderItemsTable,
      OrderItem,
      $$OrderItemsTableFilterComposer,
      $$OrderItemsTableOrderingComposer,
      $$OrderItemsTableAnnotationComposer,
      $$OrderItemsTableCreateCompanionBuilder,
      $$OrderItemsTableUpdateCompanionBuilder,
      (OrderItem, $$OrderItemsTableReferences),
      OrderItem,
      PrefetchHooks Function({
        bool orderId,
        bool menuItemId,
        bool subOrderId,
        bool orderItemStatusEventsRefs,
        bool orderItemAddonsRefs,
      })
    >;
typedef $$OrderItemStatusEventsTableCreateCompanionBuilder =
    OrderItemStatusEventsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderItemId,
      Value<String?> fromStatus,
      required String toStatus,
      Value<String?> reason,
      required int at,
      Value<int> rowid,
    });
typedef $$OrderItemStatusEventsTableUpdateCompanionBuilder =
    OrderItemStatusEventsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderItemId,
      Value<String?> fromStatus,
      Value<String> toStatus,
      Value<String?> reason,
      Value<int> at,
      Value<int> rowid,
    });

final class $$OrderItemStatusEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OrderItemStatusEventsTable,
          OrderItemStatusEvent
        > {
  $$OrderItemStatusEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrderItemsTable _orderItemIdTable(_$AppDatabase db) => db.orderItems
      .createAlias('order_item_status_events__order_item_id__order_items__id');

  $$OrderItemsTableProcessedTableManager get orderItemId {
    final $_column = $_itemColumn<String>('order_item_id')!;

    final manager = $$OrderItemsTableTableManager(
      $_db,
      $_db.orderItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrderItemStatusEventsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemStatusEventsTable> {
  $$OrderItemStatusEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  $$OrderItemsTableFilterComposer get orderItemId {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderItemId,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemStatusEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemStatusEventsTable> {
  $$OrderItemStatusEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrderItemsTableOrderingComposer get orderItemId {
    final $$OrderItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderItemId,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableOrderingComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemStatusEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemStatusEventsTable> {
  $$OrderItemStatusEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toStatus =>
      $composableBuilder(column: $table.toStatus, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$OrderItemsTableAnnotationComposer get orderItemId {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderItemId,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemStatusEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderItemStatusEventsTable,
          OrderItemStatusEvent,
          $$OrderItemStatusEventsTableFilterComposer,
          $$OrderItemStatusEventsTableOrderingComposer,
          $$OrderItemStatusEventsTableAnnotationComposer,
          $$OrderItemStatusEventsTableCreateCompanionBuilder,
          $$OrderItemStatusEventsTableUpdateCompanionBuilder,
          (OrderItemStatusEvent, $$OrderItemStatusEventsTableReferences),
          OrderItemStatusEvent,
          PrefetchHooks Function({bool orderItemId})
        > {
  $$OrderItemStatusEventsTableTableManager(
    _$AppDatabase db,
    $OrderItemStatusEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemStatusEventsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OrderItemStatusEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OrderItemStatusEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderItemId = const Value.absent(),
                Value<String?> fromStatus = const Value.absent(),
                Value<String> toStatus = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemStatusEventsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderItemId: orderItemId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderItemId,
                Value<String?> fromStatus = const Value.absent(),
                required String toStatus,
                Value<String?> reason = const Value.absent(),
                required int at,
                Value<int> rowid = const Value.absent(),
              }) => OrderItemStatusEventsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderItemId: orderItemId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrderItemStatusEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderItemId,
                                referencedTable:
                                    $$OrderItemStatusEventsTableReferences
                                        ._orderItemIdTable(db),
                                referencedColumn:
                                    $$OrderItemStatusEventsTableReferences
                                        ._orderItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrderItemStatusEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderItemStatusEventsTable,
      OrderItemStatusEvent,
      $$OrderItemStatusEventsTableFilterComposer,
      $$OrderItemStatusEventsTableOrderingComposer,
      $$OrderItemStatusEventsTableAnnotationComposer,
      $$OrderItemStatusEventsTableCreateCompanionBuilder,
      $$OrderItemStatusEventsTableUpdateCompanionBuilder,
      (OrderItemStatusEvent, $$OrderItemStatusEventsTableReferences),
      OrderItemStatusEvent,
      PrefetchHooks Function({bool orderItemId})
    >;
typedef $$OrderItemAddonsTableCreateCompanionBuilder =
    OrderItemAddonsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderItemId,
      required String name,
      required int price,
      required int position,
      Value<int> rowid,
    });
typedef $$OrderItemAddonsTableUpdateCompanionBuilder =
    OrderItemAddonsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderItemId,
      Value<String> name,
      Value<int> price,
      Value<int> position,
      Value<int> rowid,
    });

final class $$OrderItemAddonsTableReferences
    extends
        BaseReferences<_$AppDatabase, $OrderItemAddonsTable, OrderItemAddon> {
  $$OrderItemAddonsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrderItemsTable _orderItemIdTable(_$AppDatabase db) => db.orderItems
      .createAlias('order_item_addons__order_item_id__order_items__id');

  $$OrderItemsTableProcessedTableManager get orderItemId {
    final $_column = $_itemColumn<String>('order_item_id')!;

    final manager = $$OrderItemsTableTableManager(
      $_db,
      $_db.orderItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrderItemAddonsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemAddonsTable> {
  $$OrderItemAddonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$OrderItemsTableFilterComposer get orderItemId {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderItemId,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemAddonsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemAddonsTable> {
  $$OrderItemAddonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrderItemsTableOrderingComposer get orderItemId {
    final $$OrderItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderItemId,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableOrderingComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemAddonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemAddonsTable> {
  $$OrderItemAddonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$OrderItemsTableAnnotationComposer get orderItemId {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderItemId,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemAddonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderItemAddonsTable,
          OrderItemAddon,
          $$OrderItemAddonsTableFilterComposer,
          $$OrderItemAddonsTableOrderingComposer,
          $$OrderItemAddonsTableAnnotationComposer,
          $$OrderItemAddonsTableCreateCompanionBuilder,
          $$OrderItemAddonsTableUpdateCompanionBuilder,
          (OrderItemAddon, $$OrderItemAddonsTableReferences),
          OrderItemAddon,
          PrefetchHooks Function({bool orderItemId})
        > {
  $$OrderItemAddonsTableTableManager(
    _$AppDatabase db,
    $OrderItemAddonsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemAddonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemAddonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemAddonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderItemId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemAddonsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderItemId: orderItemId,
                name: name,
                price: price,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderItemId,
                required String name,
                required int price,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => OrderItemAddonsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderItemId: orderItemId,
                name: name,
                price: price,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrderItemAddonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderItemId,
                                referencedTable:
                                    $$OrderItemAddonsTableReferences
                                        ._orderItemIdTable(db),
                                referencedColumn:
                                    $$OrderItemAddonsTableReferences
                                        ._orderItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrderItemAddonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderItemAddonsTable,
      OrderItemAddon,
      $$OrderItemAddonsTableFilterComposer,
      $$OrderItemAddonsTableOrderingComposer,
      $$OrderItemAddonsTableAnnotationComposer,
      $$OrderItemAddonsTableCreateCompanionBuilder,
      $$OrderItemAddonsTableUpdateCompanionBuilder,
      (OrderItemAddon, $$OrderItemAddonsTableReferences),
      OrderItemAddon,
      PrefetchHooks Function({bool orderItemId})
    >;
typedef $$OrderStatusEventsTableCreateCompanionBuilder =
    OrderStatusEventsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderId,
      Value<String?> fromStatus,
      required String toStatus,
      Value<String?> reason,
      required int at,
      Value<int> rowid,
    });
typedef $$OrderStatusEventsTableUpdateCompanionBuilder =
    OrderStatusEventsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderId,
      Value<String?> fromStatus,
      Value<String> toStatus,
      Value<String?> reason,
      Value<int> at,
      Value<int> rowid,
    });

final class $$OrderStatusEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OrderStatusEventsTable,
          OrderStatusEvent
        > {
  $$OrderStatusEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('order_status_events__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrderStatusEventsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderStatusEventsTable> {
  $$OrderStatusEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderStatusEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderStatusEventsTable> {
  $$OrderStatusEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderStatusEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderStatusEventsTable> {
  $$OrderStatusEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toStatus =>
      $composableBuilder(column: $table.toStatus, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderStatusEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderStatusEventsTable,
          OrderStatusEvent,
          $$OrderStatusEventsTableFilterComposer,
          $$OrderStatusEventsTableOrderingComposer,
          $$OrderStatusEventsTableAnnotationComposer,
          $$OrderStatusEventsTableCreateCompanionBuilder,
          $$OrderStatusEventsTableUpdateCompanionBuilder,
          (OrderStatusEvent, $$OrderStatusEventsTableReferences),
          OrderStatusEvent,
          PrefetchHooks Function({bool orderId})
        > {
  $$OrderStatusEventsTableTableManager(
    _$AppDatabase db,
    $OrderStatusEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderStatusEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderStatusEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderStatusEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String?> fromStatus = const Value.absent(),
                Value<String> toStatus = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderStatusEventsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderId,
                Value<String?> fromStatus = const Value.absent(),
                required String toStatus,
                Value<String?> reason = const Value.absent(),
                required int at,
                Value<int> rowid = const Value.absent(),
              }) => OrderStatusEventsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrderStatusEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable:
                                    $$OrderStatusEventsTableReferences
                                        ._orderIdTable(db),
                                referencedColumn:
                                    $$OrderStatusEventsTableReferences
                                        ._orderIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrderStatusEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderStatusEventsTable,
      OrderStatusEvent,
      $$OrderStatusEventsTableFilterComposer,
      $$OrderStatusEventsTableOrderingComposer,
      $$OrderStatusEventsTableAnnotationComposer,
      $$OrderStatusEventsTableCreateCompanionBuilder,
      $$OrderStatusEventsTableUpdateCompanionBuilder,
      (OrderStatusEvent, $$OrderStatusEventsTableReferences),
      OrderStatusEvent,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderId,
      required String path,
      required String kind,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderId,
      Value<String> path,
      Value<String> kind,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('attachments__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({bool orderId})
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                path: path,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderId,
                required String path,
                required String kind,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                path: path,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$AttachmentsTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$AttachmentsTableReferences
                                    ._orderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderId,
      required int amount,
      required String kind,
      required String mode,
      Value<String?> reference,
      required int paidAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderId,
      Value<int> amount,
      Value<String> kind,
      Value<String> mode,
      Value<String?> reference,
      Value<int> paidAt,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('payments__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<int> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool orderId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<int> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                amount: amount,
                kind: kind,
                mode: mode,
                reference: reference,
                paidAt: paidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderId,
                required int amount,
                required String kind,
                required String mode,
                Value<String?> reference = const Value.absent(),
                required int paidAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                amount: amount,
                kind: kind,
                mode: mode,
                reference: reference,
                paidAt: paidAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$PaymentsTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._orderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$MaterialsTableCreateCompanionBuilder =
    MaterialsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      required String name,
      required String category,
      required String unit,
      required double thresholdQty,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$MaterialsTableUpdateCompanionBuilder =
    MaterialsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> fieldHlcJson,
      Value<String> name,
      Value<String> category,
      Value<String> unit,
      Value<double> thresholdQty,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$MaterialsTableReferences
    extends BaseReferences<_$AppDatabase, $MaterialsTable, RawMaterial> {
  $$MaterialsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StockTransactionsTable, List<StockTransaction>>
  _stockTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockTransactions,
        aliasName: 'materials__id__stock_transactions__material_id',
      );

  $$StockTransactionsTableProcessedTableManager get stockTransactionsRefs {
    final manager = $$StockTransactionsTableTableManager(
      $_db,
      $_db.stockTransactions,
    ).filter((f) => f.materialId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thresholdQty => $composableBuilder(
    column: $table.thresholdQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stockTransactionsRefs(
    Expression<bool> Function($$StockTransactionsTableFilterComposer f) f,
  ) {
    final $$StockTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockTransactions,
      getReferencedColumn: (t) => t.materialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.stockTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thresholdQty => $composableBuilder(
    column: $table.thresholdQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get thresholdQty => $composableBuilder(
    column: $table.thresholdQty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> stockTransactionsRefs<T extends Object>(
    Expression<T> Function($$StockTransactionsTableAnnotationComposer a) f,
  ) {
    final $$StockTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockTransactions,
          getReferencedColumn: (t) => t.materialId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialsTable,
          RawMaterial,
          $$MaterialsTableFilterComposer,
          $$MaterialsTableOrderingComposer,
          $$MaterialsTableAnnotationComposer,
          $$MaterialsTableCreateCompanionBuilder,
          $$MaterialsTableUpdateCompanionBuilder,
          (RawMaterial, $$MaterialsTableReferences),
          RawMaterial,
          PrefetchHooks Function({bool stockTransactionsRefs})
        > {
  $$MaterialsTableTableManager(_$AppDatabase db, $MaterialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> thresholdQty = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                name: name,
                category: category,
                unit: unit,
                thresholdQty: thresholdQty,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> fieldHlcJson = const Value.absent(),
                required String name,
                required String category,
                required String unit,
                required double thresholdQty,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                fieldHlcJson: fieldHlcJson,
                name: name,
                category: category,
                unit: unit,
                thresholdQty: thresholdQty,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaterialsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stockTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (stockTransactionsRefs) db.stockTransactions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stockTransactionsRefs)
                    await $_getPrefetchedData<
                      RawMaterial,
                      $MaterialsTable,
                      StockTransaction
                    >(
                      currentTable: table,
                      referencedTable: $$MaterialsTableReferences
                          ._stockTransactionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MaterialsTableReferences(
                            db,
                            table,
                            p0,
                          ).stockTransactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.materialId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialsTable,
      RawMaterial,
      $$MaterialsTableFilterComposer,
      $$MaterialsTableOrderingComposer,
      $$MaterialsTableAnnotationComposer,
      $$MaterialsTableCreateCompanionBuilder,
      $$MaterialsTableUpdateCompanionBuilder,
      (RawMaterial, $$MaterialsTableReferences),
      RawMaterial,
      PrefetchHooks Function({bool stockTransactionsRefs})
    >;
typedef $$StockTransactionsTableCreateCompanionBuilder =
    StockTransactionsCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String materialId,
      required String kind,
      required double qty,
      Value<int?> amount,
      Value<String?> reason,
      required int at,
      Value<int> rowid,
    });
typedef $$StockTransactionsTableUpdateCompanionBuilder =
    StockTransactionsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> materialId,
      Value<String> kind,
      Value<double> qty,
      Value<int?> amount,
      Value<String?> reason,
      Value<int> at,
      Value<int> rowid,
    });

final class $$StockTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StockTransactionsTable,
          StockTransaction
        > {
  $$StockTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MaterialsTable _materialIdTable(_$AppDatabase db) => db.materials
      .createAlias('stock_transactions__material_id__materials__id');

  $$MaterialsTableProcessedTableManager get materialId {
    final $_column = $_itemColumn<String>('material_id')!;

    final manager = $$MaterialsTableTableManager(
      $_db,
      $_db.materials,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materialIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $StockTransactionsTable> {
  $$StockTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  $$MaterialsTableFilterComposer get materialId {
    final $$MaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materialId,
      referencedTable: $db.materials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialsTableFilterComposer(
            $db: $db,
            $table: $db.materials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTransactionsTable> {
  $$StockTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  $$MaterialsTableOrderingComposer get materialId {
    final $$MaterialsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materialId,
      referencedTable: $db.materials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialsTableOrderingComposer(
            $db: $db,
            $table: $db.materials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTransactionsTable> {
  $$StockTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$MaterialsTableAnnotationComposer get materialId {
    final $$MaterialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materialId,
      referencedTable: $db.materials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialsTableAnnotationComposer(
            $db: $db,
            $table: $db.materials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockTransactionsTable,
          StockTransaction,
          $$StockTransactionsTableFilterComposer,
          $$StockTransactionsTableOrderingComposer,
          $$StockTransactionsTableAnnotationComposer,
          $$StockTransactionsTableCreateCompanionBuilder,
          $$StockTransactionsTableUpdateCompanionBuilder,
          (StockTransaction, $$StockTransactionsTableReferences),
          StockTransaction,
          PrefetchHooks Function({bool materialId})
        > {
  $$StockTransactionsTableTableManager(
    _$AppDatabase db,
    $StockTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> materialId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockTransactionsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                materialId: materialId,
                kind: kind,
                qty: qty,
                amount: amount,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String materialId,
                required String kind,
                required double qty,
                Value<int?> amount = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required int at,
                Value<int> rowid = const Value.absent(),
              }) => StockTransactionsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                materialId: materialId,
                kind: kind,
                qty: qty,
                amount: amount,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({materialId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (materialId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.materialId,
                                referencedTable:
                                    $$StockTransactionsTableReferences
                                        ._materialIdTable(db),
                                referencedColumn:
                                    $$StockTransactionsTableReferences
                                        ._materialIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StockTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockTransactionsTable,
      StockTransaction,
      $$StockTransactionsTableFilterComposer,
      $$StockTransactionsTableOrderingComposer,
      $$StockTransactionsTableAnnotationComposer,
      $$StockTransactionsTableCreateCompanionBuilder,
      $$StockTransactionsTableUpdateCompanionBuilder,
      (StockTransaction, $$StockTransactionsTableReferences),
      StockTransaction,
      PrefetchHooks Function({bool materialId})
    >;
typedef $$ShareLogTableCreateCompanionBuilder =
    ShareLogCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String orderId,
      required String kind,
      required int composedAt,
      Value<int?> sharedAt,
      Value<int> rowid,
    });
typedef $$ShareLogTableUpdateCompanionBuilder =
    ShareLogCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> orderId,
      Value<String> kind,
      Value<int> composedAt,
      Value<int?> sharedAt,
      Value<int> rowid,
    });

final class $$ShareLogTableReferences
    extends BaseReferences<_$AppDatabase, $ShareLogTable, ShareLogData> {
  $$ShareLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('share_log__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShareLogTableFilterComposer
    extends Composer<_$AppDatabase, $ShareLogTable> {
  $$ShareLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get composedAt => $composableBuilder(
    column: $table.composedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sharedAt => $composableBuilder(
    column: $table.sharedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ShareLogTable> {
  $$ShareLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get composedAt => $composableBuilder(
    column: $table.composedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sharedAt => $composableBuilder(
    column: $table.sharedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShareLogTable> {
  $$ShareLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get composedAt => $composableBuilder(
    column: $table.composedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sharedAt =>
      $composableBuilder(column: $table.sharedAt, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShareLogTable,
          ShareLogData,
          $$ShareLogTableFilterComposer,
          $$ShareLogTableOrderingComposer,
          $$ShareLogTableAnnotationComposer,
          $$ShareLogTableCreateCompanionBuilder,
          $$ShareLogTableUpdateCompanionBuilder,
          (ShareLogData, $$ShareLogTableReferences),
          ShareLogData,
          PrefetchHooks Function({bool orderId})
        > {
  $$ShareLogTableTableManager(_$AppDatabase db, $ShareLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShareLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShareLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShareLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> composedAt = const Value.absent(),
                Value<int?> sharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShareLogCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                kind: kind,
                composedAt: composedAt,
                sharedAt: sharedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String orderId,
                required String kind,
                required int composedAt,
                Value<int?> sharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShareLogCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                orderId: orderId,
                kind: kind,
                composedAt: composedAt,
                sharedAt: sharedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShareLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$ShareLogTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$ShareLogTableReferences
                                    ._orderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShareLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShareLogTable,
      ShareLogData,
      $$ShareLogTableFilterComposer,
      $$ShareLogTableOrderingComposer,
      $$ShareLogTableAnnotationComposer,
      $$ShareLogTableCreateCompanionBuilder,
      $$ShareLogTableUpdateCompanionBuilder,
      (ShareLogData, $$ShareLogTableReferences),
      ShareLogData,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> name,
      required int firstSeenAt,
      required int lastSeenAt,
      Value<int?> appVersion,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String?> name,
      Value<int> firstSeenAt,
      Value<int> lastSeenAt,
      Value<int?> appVersion,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> firstSeenAt = const Value.absent(),
                Value<int> lastSeenAt = const Value.absent(),
                Value<int?> appVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                name: name,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                appVersion: appVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required int firstSeenAt,
                required int lastSeenAt,
                Value<int?> appVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                name: name,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                appVersion: appVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$ConflictLogTableCreateCompanionBuilder =
    ConflictLogCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      required String updatedAtHlc,
      Value<int?> deletedAt,
      required String entity,
      required String entityId,
      required String field,
      Value<String?> localValue,
      Value<String?> remoteValue,
      required String winner,
      required String reason,
      required int at,
      Value<int> rowid,
    });
typedef $$ConflictLogTableUpdateCompanionBuilder =
    ConflictLogCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> entity,
      Value<String> entityId,
      Value<String> field,
      Value<String?> localValue,
      Value<String?> remoteValue,
      Value<String> winner,
      Value<String> reason,
      Value<int> at,
      Value<int> rowid,
    });

class $$ConflictLogTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictLogTable> {
  $$ConflictLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localValue => $composableBuilder(
    column: $table.localValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteValue => $composableBuilder(
    column: $table.remoteValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictLogTable> {
  $$ConflictLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localValue => $composableBuilder(
    column: $table.localValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteValue => $composableBuilder(
    column: $table.remoteValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictLogTable> {
  $$ConflictLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get localValue => $composableBuilder(
    column: $table.localValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteValue => $composableBuilder(
    column: $table.remoteValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$ConflictLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictLogTable,
          ConflictLogData,
          $$ConflictLogTableFilterComposer,
          $$ConflictLogTableOrderingComposer,
          $$ConflictLogTableAnnotationComposer,
          $$ConflictLogTableCreateCompanionBuilder,
          $$ConflictLogTableUpdateCompanionBuilder,
          (
            ConflictLogData,
            BaseReferences<_$AppDatabase, $ConflictLogTable, ConflictLogData>,
          ),
          ConflictLogData,
          PrefetchHooks Function()
        > {
  $$ConflictLogTableTableManager(_$AppDatabase db, $ConflictLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> localValue = const Value.absent(),
                Value<String?> remoteValue = const Value.absent(),
                Value<String> winner = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictLogCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                entity: entity,
                entityId: entityId,
                field: field,
                localValue: localValue,
                remoteValue: remoteValue,
                winner: winner,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                required String updatedAtHlc,
                Value<int?> deletedAt = const Value.absent(),
                required String entity,
                required String entityId,
                required String field,
                Value<String?> localValue = const Value.absent(),
                Value<String?> remoteValue = const Value.absent(),
                required String winner,
                required String reason,
                required int at,
                Value<int> rowid = const Value.absent(),
              }) => ConflictLogCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                entity: entity,
                entityId: entityId,
                field: field,
                localValue: localValue,
                remoteValue: remoteValue,
                winner: winner,
                reason: reason,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictLogTable,
      ConflictLogData,
      $$ConflictLogTableFilterComposer,
      $$ConflictLogTableOrderingComposer,
      $$ConflictLogTableAnnotationComposer,
      $$ConflictLogTableCreateCompanionBuilder,
      $$ConflictLogTableUpdateCompanionBuilder,
      (
        ConflictLogData,
        BaseReferences<_$AppDatabase, $ConflictLogTable, ConflictLogData>,
      ),
      ConflictLogData,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      required String opId,
      required int seq,
      required String hlc,
      required String entity,
      required String entityId,
      required String kind,
      required String payload,
      required int schemaV,
      Value<int?> uploadedAt,
      Value<int> rowid,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<String> opId,
      Value<int> seq,
      Value<String> hlc,
      Value<String> entity,
      Value<String> entityId,
      Value<String> kind,
      Value<String> payload,
      Value<int> schemaV,
      Value<int?> uploadedAt,
      Value<int> rowid,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaV => $composableBuilder(
    column: $table.schemaV,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaV => $composableBuilder(
    column: $table.schemaV,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get schemaV =>
      $composableBuilder(column: $table.schemaV, builder: (column) => column);

  GeneratedColumn<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => column,
  );
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> schemaV = const Value.absent(),
                Value<int?> uploadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                opId: opId,
                seq: seq,
                hlc: hlc,
                entity: entity,
                entityId: entityId,
                kind: kind,
                payload: payload,
                schemaV: schemaV,
                uploadedAt: uploadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required int seq,
                required String hlc,
                required String entity,
                required String entityId,
                required String kind,
                required String payload,
                required int schemaV,
                Value<int?> uploadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                opId: opId,
                seq: seq,
                hlc: hlc,
                entity: entity,
                entityId: entityId,
                kind: kind,
                payload: payload,
                schemaV: schemaV,
                uploadedAt: uploadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$AppliedOpsTableCreateCompanionBuilder =
    AppliedOpsCompanion Function({
      required String opId,
      required int appliedAt,
      Value<int> rowid,
    });
typedef $$AppliedOpsTableUpdateCompanionBuilder =
    AppliedOpsCompanion Function({
      Value<String> opId,
      Value<int> appliedAt,
      Value<int> rowid,
    });

class $$AppliedOpsTableFilterComposer
    extends Composer<_$AppDatabase, $AppliedOpsTable> {
  $$AppliedOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppliedOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppliedOpsTable> {
  $$AppliedOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppliedOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppliedOpsTable> {
  $$AppliedOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<int> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);
}

class $$AppliedOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppliedOpsTable,
          AppliedOp,
          $$AppliedOpsTableFilterComposer,
          $$AppliedOpsTableOrderingComposer,
          $$AppliedOpsTableAnnotationComposer,
          $$AppliedOpsTableCreateCompanionBuilder,
          $$AppliedOpsTableUpdateCompanionBuilder,
          (
            AppliedOp,
            BaseReferences<_$AppDatabase, $AppliedOpsTable, AppliedOp>,
          ),
          AppliedOp,
          PrefetchHooks Function()
        > {
  $$AppliedOpsTableTableManager(_$AppDatabase db, $AppliedOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppliedOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppliedOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppliedOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<int> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppliedOpsCompanion(
                opId: opId,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required int appliedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppliedOpsCompanion.insert(
                opId: opId,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppliedOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppliedOpsTable,
      AppliedOp,
      $$AppliedOpsTableFilterComposer,
      $$AppliedOpsTableOrderingComposer,
      $$AppliedOpsTableAnnotationComposer,
      $$AppliedOpsTableCreateCompanionBuilder,
      $$AppliedOpsTableUpdateCompanionBuilder,
      (AppliedOp, BaseReferences<_$AppDatabase, $AppliedOpsTable, AppliedOp>),
      AppliedOp,
      PrefetchHooks Function()
    >;
typedef $$PeerCursorsTableCreateCompanionBuilder =
    PeerCursorsCompanion Function({
      required String peerDeviceId,
      Value<int> lastSeq,
      Value<int?> lastPulledAt,
      Value<bool> needsUpgrade,
      Value<int> rowid,
    });
typedef $$PeerCursorsTableUpdateCompanionBuilder =
    PeerCursorsCompanion Function({
      Value<String> peerDeviceId,
      Value<int> lastSeq,
      Value<int?> lastPulledAt,
      Value<bool> needsUpgrade,
      Value<int> rowid,
    });

class $$PeerCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $PeerCursorsTable> {
  $$PeerCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsUpgrade => $composableBuilder(
    column: $table.needsUpgrade,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeerCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeerCursorsTable> {
  $$PeerCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsUpgrade => $composableBuilder(
    column: $table.needsUpgrade,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeerCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeerCursorsTable> {
  $$PeerCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeq =>
      $composableBuilder(column: $table.lastSeq, builder: (column) => column);

  GeneratedColumn<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsUpgrade => $composableBuilder(
    column: $table.needsUpgrade,
    builder: (column) => column,
  );
}

class $$PeerCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeerCursorsTable,
          PeerCursor,
          $$PeerCursorsTableFilterComposer,
          $$PeerCursorsTableOrderingComposer,
          $$PeerCursorsTableAnnotationComposer,
          $$PeerCursorsTableCreateCompanionBuilder,
          $$PeerCursorsTableUpdateCompanionBuilder,
          (
            PeerCursor,
            BaseReferences<_$AppDatabase, $PeerCursorsTable, PeerCursor>,
          ),
          PeerCursor,
          PrefetchHooks Function()
        > {
  $$PeerCursorsTableTableManager(_$AppDatabase db, $PeerCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeerCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeerCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeerCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> peerDeviceId = const Value.absent(),
                Value<int> lastSeq = const Value.absent(),
                Value<int?> lastPulledAt = const Value.absent(),
                Value<bool> needsUpgrade = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeerCursorsCompanion(
                peerDeviceId: peerDeviceId,
                lastSeq: lastSeq,
                lastPulledAt: lastPulledAt,
                needsUpgrade: needsUpgrade,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String peerDeviceId,
                Value<int> lastSeq = const Value.absent(),
                Value<int?> lastPulledAt = const Value.absent(),
                Value<bool> needsUpgrade = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeerCursorsCompanion.insert(
                peerDeviceId: peerDeviceId,
                lastSeq: lastSeq,
                lastPulledAt: lastPulledAt,
                needsUpgrade: needsUpgrade,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeerCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeerCursorsTable,
      PeerCursor,
      $$PeerCursorsTableFilterComposer,
      $$PeerCursorsTableOrderingComposer,
      $$PeerCursorsTableAnnotationComposer,
      $$PeerCursorsTableCreateCompanionBuilder,
      $$PeerCursorsTableUpdateCompanionBuilder,
      (
        PeerCursor,
        BaseReferences<_$AppDatabase, $PeerCursorsTable, PeerCursor>,
      ),
      PeerCursor,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<String?> fieldHlcJson,
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> businessName,
      Value<String?> address,
      Value<String?> phone,
      Value<String> invoicePrefix,
      Value<String?> upiId,
      Value<String?> paymentPhone,
      Value<int> deliveryChargeLocal,
      Value<int> deliveryChargeOutstation,
      Value<bool> appLockEnabled,
      Value<String?> deviceName,
      Value<int> orderSeq,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String?> fieldHlcJson,
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String> updatedAtHlc,
      Value<int?> deletedAt,
      Value<String> businessName,
      Value<String?> address,
      Value<String?> phone,
      Value<String> invoicePrefix,
      Value<String?> upiId,
      Value<String?> paymentPhone,
      Value<int> deliveryChargeLocal,
      Value<int> deliveryChargeOutstation,
      Value<bool> appLockEnabled,
      Value<String?> deviceName,
      Value<int> orderSeq,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiId => $composableBuilder(
    column: $table.upiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentPhone => $composableBuilder(
    column: $table.paymentPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryChargeLocal => $composableBuilder(
    column: $table.deliveryChargeLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryChargeOutstation => $composableBuilder(
    column: $table.deliveryChargeOutstation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderSeq => $composableBuilder(
    column: $table.orderSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiId => $composableBuilder(
    column: $table.upiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentPhone => $composableBuilder(
    column: $table.paymentPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryChargeLocal => $composableBuilder(
    column: $table.deliveryChargeLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryChargeOutstation => $composableBuilder(
    column: $table.deliveryChargeOutstation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderSeq => $composableBuilder(
    column: $table.orderSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fieldHlcJson => $composableBuilder(
    column: $table.fieldHlcJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => column,
  );

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get paymentPhone => $composableBuilder(
    column: $table.paymentPhone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryChargeLocal => $composableBuilder(
    column: $table.deliveryChargeLocal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryChargeOutstation => $composableBuilder(
    column: $table.deliveryChargeOutstation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderSeq =>
      $composableBuilder(column: $table.orderSeq, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> fieldHlcJson = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> invoicePrefix = const Value.absent(),
                Value<String?> upiId = const Value.absent(),
                Value<String?> paymentPhone = const Value.absent(),
                Value<int> deliveryChargeLocal = const Value.absent(),
                Value<int> deliveryChargeOutstation = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<String?> deviceName = const Value.absent(),
                Value<int> orderSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                fieldHlcJson: fieldHlcJson,
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                businessName: businessName,
                address: address,
                phone: phone,
                invoicePrefix: invoicePrefix,
                upiId: upiId,
                paymentPhone: paymentPhone,
                deliveryChargeLocal: deliveryChargeLocal,
                deliveryChargeOutstation: deliveryChargeOutstation,
                appLockEnabled: appLockEnabled,
                deviceName: deviceName,
                orderSeq: orderSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> fieldHlcJson = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> invoicePrefix = const Value.absent(),
                Value<String?> upiId = const Value.absent(),
                Value<String?> paymentPhone = const Value.absent(),
                Value<int> deliveryChargeLocal = const Value.absent(),
                Value<int> deliveryChargeOutstation = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<String?> deviceName = const Value.absent(),
                Value<int> orderSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                fieldHlcJson: fieldHlcJson,
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAtHlc: updatedAtHlc,
                deletedAt: deletedAt,
                businessName: businessName,
                address: address,
                phone: phone,
                invoicePrefix: invoicePrefix,
                upiId: upiId,
                paymentPhone: paymentPhone,
                deliveryChargeLocal: deliveryChargeLocal,
                deliveryChargeOutstation: deliveryChargeOutstation,
                appLockEnabled: appLockEnabled,
                deviceName: deviceName,
                orderSeq: orderSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$CustomerAddressesTableTableManager get customerAddresses =>
      $$CustomerAddressesTableTableManager(_db, _db.customerAddresses);
  $$MenuItemsTableTableManager get menuItems =>
      $$MenuItemsTableTableManager(_db, _db.menuItems);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$SubOrdersTableTableManager get subOrders =>
      $$SubOrdersTableTableManager(_db, _db.subOrders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$OrderItemStatusEventsTableTableManager get orderItemStatusEvents =>
      $$OrderItemStatusEventsTableTableManager(_db, _db.orderItemStatusEvents);
  $$OrderItemAddonsTableTableManager get orderItemAddons =>
      $$OrderItemAddonsTableTableManager(_db, _db.orderItemAddons);
  $$OrderStatusEventsTableTableManager get orderStatusEvents =>
      $$OrderStatusEventsTableTableManager(_db, _db.orderStatusEvents);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$StockTransactionsTableTableManager get stockTransactions =>
      $$StockTransactionsTableTableManager(_db, _db.stockTransactions);
  $$ShareLogTableTableManager get shareLog =>
      $$ShareLogTableTableManager(_db, _db.shareLog);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$ConflictLogTableTableManager get conflictLog =>
      $$ConflictLogTableTableManager(_db, _db.conflictLog);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$AppliedOpsTableTableManager get appliedOps =>
      $$AppliedOpsTableTableManager(_db, _db.appliedOps);
  $$PeerCursorsTableTableManager get peerCursors =>
      $$PeerCursorsTableTableManager(_db, _db.peerCursors);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
