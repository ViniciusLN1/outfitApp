// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClothingItemsTable extends ClothingItems
    with TableInfo<$ClothingItemsTable, ClothingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClothingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
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
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<int> dateAdded = GeneratedColumn<int>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imagePath,
    category,
    dateAdded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clothing_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClothingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClothingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClothingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_added'],
      )!,
    );
  }

  @override
  $ClothingItemsTable createAlias(String alias) {
    return $ClothingItemsTable(attachedDatabase, alias);
  }
}

class ClothingItem extends DataClass implements Insertable<ClothingItem> {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final int dateAdded;
  const ClothingItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.dateAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['image_path'] = Variable<String>(imagePath);
    map['category'] = Variable<String>(category);
    map['date_added'] = Variable<int>(dateAdded);
    return map;
  }

  ClothingItemsCompanion toCompanion(bool nullToAbsent) {
    return ClothingItemsCompanion(
      id: Value(id),
      name: Value(name),
      imagePath: Value(imagePath),
      category: Value(category),
      dateAdded: Value(dateAdded),
    );
  }

  factory ClothingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClothingItem(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      category: serializer.fromJson<String>(json['category']),
      dateAdded: serializer.fromJson<int>(json['dateAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'imagePath': serializer.toJson<String>(imagePath),
      'category': serializer.toJson<String>(category),
      'dateAdded': serializer.toJson<int>(dateAdded),
    };
  }

  ClothingItem copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? category,
    int? dateAdded,
  }) => ClothingItem(
    id: id ?? this.id,
    name: name ?? this.name,
    imagePath: imagePath ?? this.imagePath,
    category: category ?? this.category,
    dateAdded: dateAdded ?? this.dateAdded,
  );
  ClothingItem copyWithCompanion(ClothingItemsCompanion data) {
    return ClothingItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      category: data.category.present ? data.category.value : this.category,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath, ')
          ..write('category: $category, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, imagePath, category, dateAdded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClothingItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.imagePath == this.imagePath &&
          other.category == this.category &&
          other.dateAdded == this.dateAdded);
}

class ClothingItemsCompanion extends UpdateCompanion<ClothingItem> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> imagePath;
  final Value<String> category;
  final Value<int> dateAdded;
  final Value<int> rowid;
  const ClothingItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.category = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClothingItemsCompanion.insert({
    required String id,
    required String name,
    required String imagePath,
    required String category,
    required int dateAdded,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       imagePath = Value(imagePath),
       category = Value(category),
       dateAdded = Value(dateAdded);
  static Insertable<ClothingItem> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? imagePath,
    Expression<String>? category,
    Expression<int>? dateAdded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imagePath != null) 'image_path': imagePath,
      if (category != null) 'category': category,
      if (dateAdded != null) 'date_added': dateAdded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClothingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? imagePath,
    Value<String>? category,
    Value<int>? dateAdded,
    Value<int>? rowid,
  }) {
    return ClothingItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      dateAdded: dateAdded ?? this.dateAdded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<int>(dateAdded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath, ')
          ..write('category: $category, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitsTable extends Outfits with TableInfo<$OutfitsTable, Outfit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<int> isFavorite = GeneratedColumn<int>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<int> dateCreated = GeneratedColumn<int>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isFavorite,
    usageCount,
    dateCreated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Outfit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateCreatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Outfit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Outfit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_favorite'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_created'],
      )!,
    );
  }

  @override
  $OutfitsTable createAlias(String alias) {
    return $OutfitsTable(attachedDatabase, alias);
  }
}

class Outfit extends DataClass implements Insertable<Outfit> {
  final String id;
  final String name;
  final int isFavorite;
  final int usageCount;
  final int dateCreated;
  const Outfit({
    required this.id,
    required this.name,
    required this.isFavorite,
    required this.usageCount,
    required this.dateCreated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_favorite'] = Variable<int>(isFavorite);
    map['usage_count'] = Variable<int>(usageCount);
    map['date_created'] = Variable<int>(dateCreated);
    return map;
  }

  OutfitsCompanion toCompanion(bool nullToAbsent) {
    return OutfitsCompanion(
      id: Value(id),
      name: Value(name),
      isFavorite: Value(isFavorite),
      usageCount: Value(usageCount),
      dateCreated: Value(dateCreated),
    );
  }

  factory Outfit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Outfit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isFavorite: serializer.fromJson<int>(json['isFavorite']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      dateCreated: serializer.fromJson<int>(json['dateCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isFavorite': serializer.toJson<int>(isFavorite),
      'usageCount': serializer.toJson<int>(usageCount),
      'dateCreated': serializer.toJson<int>(dateCreated),
    };
  }

  Outfit copyWith({
    String? id,
    String? name,
    int? isFavorite,
    int? usageCount,
    int? dateCreated,
  }) => Outfit(
    id: id ?? this.id,
    name: name ?? this.name,
    isFavorite: isFavorite ?? this.isFavorite,
    usageCount: usageCount ?? this.usageCount,
    dateCreated: dateCreated ?? this.dateCreated,
  );
  Outfit copyWithCompanion(OutfitsCompanion data) {
    return Outfit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Outfit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isFavorite, usageCount, dateCreated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Outfit &&
          other.id == this.id &&
          other.name == this.name &&
          other.isFavorite == this.isFavorite &&
          other.usageCount == this.usageCount &&
          other.dateCreated == this.dateCreated);
}

class OutfitsCompanion extends UpdateCompanion<Outfit> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> isFavorite;
  final Value<int> usageCount;
  final Value<int> dateCreated;
  final Value<int> rowid;
  const OutfitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitsCompanion.insert({
    required String id,
    required String name,
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    required int dateCreated,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       dateCreated = Value(dateCreated);
  static Insertable<Outfit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? isFavorite,
    Expression<int>? usageCount,
    Expression<int>? dateCreated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (usageCount != null) 'usage_count': usageCount,
      if (dateCreated != null) 'date_created': dateCreated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? isFavorite,
    Value<int>? usageCount,
    Value<int>? dateCreated,
    Value<int>? rowid,
  }) {
    return OutfitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      dateCreated: dateCreated ?? this.dateCreated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<int>(isFavorite.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<int>(dateCreated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitItemsTable extends OutfitItems
    with TableInfo<$OutfitItemsTable, OutfitItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outfitIdMeta = const VerificationMeta(
    'outfitId',
  );
  @override
  late final GeneratedColumn<String> outfitId = GeneratedColumn<String>(
    'outfit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES outfits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clothing_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _centerXMeta = const VerificationMeta(
    'centerX',
  );
  @override
  late final GeneratedColumn<double> centerX = GeneratedColumn<double>(
    'center_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _centerYMeta = const VerificationMeta(
    'centerY',
  );
  @override
  late final GeneratedColumn<double> centerY = GeneratedColumn<double>(
    'center_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _itemSizeMeta = const VerificationMeta(
    'itemSize',
  );
  @override
  late final GeneratedColumn<double> itemSize = GeneratedColumn<double>(
    'item_size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _zIndexMeta = const VerificationMeta('zIndex');
  @override
  late final GeneratedColumn<int> zIndex = GeneratedColumn<int>(
    'z_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    outfitId,
    itemId,
    centerX,
    centerY,
    itemSize,
    zIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutfitItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('outfit_id')) {
      context.handle(
        _outfitIdMeta,
        outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outfitIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('center_x')) {
      context.handle(
        _centerXMeta,
        centerX.isAcceptableOrUnknown(data['center_x']!, _centerXMeta),
      );
    }
    if (data.containsKey('center_y')) {
      context.handle(
        _centerYMeta,
        centerY.isAcceptableOrUnknown(data['center_y']!, _centerYMeta),
      );
    }
    if (data.containsKey('item_size')) {
      context.handle(
        _itemSizeMeta,
        itemSize.isAcceptableOrUnknown(data['item_size']!, _itemSizeMeta),
      );
    }
    if (data.containsKey('z_index')) {
      context.handle(
        _zIndexMeta,
        zIndex.isAcceptableOrUnknown(data['z_index']!, _zIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outfitId, itemId};
  @override
  OutfitItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutfitItem(
      outfitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outfit_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      centerX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}center_x'],
      )!,
      centerY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}center_y'],
      )!,
      itemSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}item_size'],
      )!,
      zIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}z_index'],
      )!,
    );
  }

  @override
  $OutfitItemsTable createAlias(String alias) {
    return $OutfitItemsTable(attachedDatabase, alias);
  }
}

class OutfitItem extends DataClass implements Insertable<OutfitItem> {
  final String outfitId;
  final String itemId;
  final double centerX;
  final double centerY;
  final double itemSize;
  final int zIndex;
  const OutfitItem({
    required this.outfitId,
    required this.itemId,
    required this.centerX,
    required this.centerY,
    required this.itemSize,
    required this.zIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['outfit_id'] = Variable<String>(outfitId);
    map['item_id'] = Variable<String>(itemId);
    map['center_x'] = Variable<double>(centerX);
    map['center_y'] = Variable<double>(centerY);
    map['item_size'] = Variable<double>(itemSize);
    map['z_index'] = Variable<int>(zIndex);
    return map;
  }

  OutfitItemsCompanion toCompanion(bool nullToAbsent) {
    return OutfitItemsCompanion(
      outfitId: Value(outfitId),
      itemId: Value(itemId),
      centerX: Value(centerX),
      centerY: Value(centerY),
      itemSize: Value(itemSize),
      zIndex: Value(zIndex),
    );
  }

  factory OutfitItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutfitItem(
      outfitId: serializer.fromJson<String>(json['outfitId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      centerX: serializer.fromJson<double>(json['centerX']),
      centerY: serializer.fromJson<double>(json['centerY']),
      itemSize: serializer.fromJson<double>(json['itemSize']),
      zIndex: serializer.fromJson<int>(json['zIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outfitId': serializer.toJson<String>(outfitId),
      'itemId': serializer.toJson<String>(itemId),
      'centerX': serializer.toJson<double>(centerX),
      'centerY': serializer.toJson<double>(centerY),
      'itemSize': serializer.toJson<double>(itemSize),
      'zIndex': serializer.toJson<int>(zIndex),
    };
  }

  OutfitItem copyWith({
    String? outfitId,
    String? itemId,
    double? centerX,
    double? centerY,
    double? itemSize,
    int? zIndex,
  }) => OutfitItem(
    outfitId: outfitId ?? this.outfitId,
    itemId: itemId ?? this.itemId,
    centerX: centerX ?? this.centerX,
    centerY: centerY ?? this.centerY,
    itemSize: itemSize ?? this.itemSize,
    zIndex: zIndex ?? this.zIndex,
  );
  OutfitItem copyWithCompanion(OutfitItemsCompanion data) {
    return OutfitItem(
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      centerX: data.centerX.present ? data.centerX.value : this.centerX,
      centerY: data.centerY.present ? data.centerY.value : this.centerY,
      itemSize: data.itemSize.present ? data.itemSize.value : this.itemSize,
      zIndex: data.zIndex.present ? data.zIndex.value : this.zIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItem(')
          ..write('outfitId: $outfitId, ')
          ..write('itemId: $itemId, ')
          ..write('centerX: $centerX, ')
          ..write('centerY: $centerY, ')
          ..write('itemSize: $itemSize, ')
          ..write('zIndex: $zIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(outfitId, itemId, centerX, centerY, itemSize, zIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutfitItem &&
          other.outfitId == this.outfitId &&
          other.itemId == this.itemId &&
          other.centerX == this.centerX &&
          other.centerY == this.centerY &&
          other.itemSize == this.itemSize &&
          other.zIndex == this.zIndex);
}

class OutfitItemsCompanion extends UpdateCompanion<OutfitItem> {
  final Value<String> outfitId;
  final Value<String> itemId;
  final Value<double> centerX;
  final Value<double> centerY;
  final Value<double> itemSize;
  final Value<int> zIndex;
  final Value<int> rowid;
  const OutfitItemsCompanion({
    this.outfitId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.centerX = const Value.absent(),
    this.centerY = const Value.absent(),
    this.itemSize = const Value.absent(),
    this.zIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitItemsCompanion.insert({
    required String outfitId,
    required String itemId,
    this.centerX = const Value.absent(),
    this.centerY = const Value.absent(),
    this.itemSize = const Value.absent(),
    this.zIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : outfitId = Value(outfitId),
       itemId = Value(itemId);
  static Insertable<OutfitItem> custom({
    Expression<String>? outfitId,
    Expression<String>? itemId,
    Expression<double>? centerX,
    Expression<double>? centerY,
    Expression<double>? itemSize,
    Expression<int>? zIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (outfitId != null) 'outfit_id': outfitId,
      if (itemId != null) 'item_id': itemId,
      if (centerX != null) 'center_x': centerX,
      if (centerY != null) 'center_y': centerY,
      if (itemSize != null) 'item_size': itemSize,
      if (zIndex != null) 'z_index': zIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitItemsCompanion copyWith({
    Value<String>? outfitId,
    Value<String>? itemId,
    Value<double>? centerX,
    Value<double>? centerY,
    Value<double>? itemSize,
    Value<int>? zIndex,
    Value<int>? rowid,
  }) {
    return OutfitItemsCompanion(
      outfitId: outfitId ?? this.outfitId,
      itemId: itemId ?? this.itemId,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      itemSize: itemSize ?? this.itemSize,
      zIndex: zIndex ?? this.zIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outfitId.present) {
      map['outfit_id'] = Variable<String>(outfitId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (centerX.present) {
      map['center_x'] = Variable<double>(centerX.value);
    }
    if (centerY.present) {
      map['center_y'] = Variable<double>(centerY.value);
    }
    if (itemSize.present) {
      map['item_size'] = Variable<double>(itemSize.value);
    }
    if (zIndex.present) {
      map['z_index'] = Variable<int>(zIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItemsCompanion(')
          ..write('outfitId: $outfitId, ')
          ..write('itemId: $itemId, ')
          ..write('centerX: $centerX, ')
          ..write('centerY: $centerY, ')
          ..write('itemSize: $itemSize, ')
          ..write('zIndex: $zIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClothingItemsTable clothingItems = $ClothingItemsTable(this);
  late final $OutfitsTable outfits = $OutfitsTable(this);
  late final $OutfitItemsTable outfitItems = $OutfitItemsTable(this);
  late final Index idxClothingItemsCategory = Index(
    'idx_clothing_items_category',
    'CREATE INDEX idx_clothing_items_category ON clothing_items (category)',
  );
  late final Index idxClothingItemsDateAdded = Index(
    'idx_clothing_items_date_added',
    'CREATE INDEX idx_clothing_items_date_added ON clothing_items (date_added)',
  );
  late final Index idxOutfitsDateCreated = Index(
    'idx_outfits_date_created',
    'CREATE INDEX idx_outfits_date_created ON outfits (date_created)',
  );
  late final Index idxOutfitsFavoriteDate = Index(
    'idx_outfits_favorite_date',
    'CREATE INDEX idx_outfits_favorite_date ON outfits (is_favorite, date_created)',
  );
  late final Index idxOutfitsUsageDate = Index(
    'idx_outfits_usage_date',
    'CREATE INDEX idx_outfits_usage_date ON outfits (usage_count, date_created)',
  );
  late final Index idxOutfitItemsItemId = Index(
    'idx_outfit_items_item_id',
    'CREATE INDEX idx_outfit_items_item_id ON outfit_items (item_id)',
  );
  late final ClothingDao clothingDao = ClothingDao(this as AppDatabase);
  late final OutfitDao outfitDao = OutfitDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clothingItems,
    outfits,
    outfitItems,
    idxClothingItemsCategory,
    idxClothingItemsDateAdded,
    idxOutfitsDateCreated,
    idxOutfitsFavoriteDate,
    idxOutfitsUsageDate,
    idxOutfitItemsItemId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'outfits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clothing_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ClothingItemsTableCreateCompanionBuilder =
    ClothingItemsCompanion Function({
      required String id,
      required String name,
      required String imagePath,
      required String category,
      required int dateAdded,
      Value<int> rowid,
    });
typedef $$ClothingItemsTableUpdateCompanionBuilder =
    ClothingItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> imagePath,
      Value<String> category,
      Value<int> dateAdded,
      Value<int> rowid,
    });

final class $$ClothingItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ClothingItemsTable, ClothingItem> {
  $$ClothingItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>>
  _outfitItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outfitItems,
    aliasName: $_aliasNameGenerator(db.clothingItems.id, db.outfitItems.itemId),
  );

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager(
      $_db,
      $_db.outfitItems,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClothingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> outfitItemsRefs(
    Expression<bool> Function($$OutfitItemsTableFilterComposer f) f,
  ) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableFilterComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClothingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClothingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  Expression<T> outfitItemsRefs<T extends Object>(
    Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f,
  ) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClothingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClothingItemsTable,
          ClothingItem,
          $$ClothingItemsTableFilterComposer,
          $$ClothingItemsTableOrderingComposer,
          $$ClothingItemsTableAnnotationComposer,
          $$ClothingItemsTableCreateCompanionBuilder,
          $$ClothingItemsTableUpdateCompanionBuilder,
          (ClothingItem, $$ClothingItemsTableReferences),
          ClothingItem,
          PrefetchHooks Function({bool outfitItemsRefs})
        > {
  $$ClothingItemsTableTableManager(_$AppDatabase db, $ClothingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClothingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClothingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClothingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> dateAdded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClothingItemsCompanion(
                id: id,
                name: name,
                imagePath: imagePath,
                category: category,
                dateAdded: dateAdded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String imagePath,
                required String category,
                required int dateAdded,
                Value<int> rowid = const Value.absent(),
              }) => ClothingItemsCompanion.insert(
                id: id,
                name: name,
                imagePath: imagePath,
                category: category,
                dateAdded: dateAdded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClothingItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({outfitItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (outfitItemsRefs) db.outfitItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (outfitItemsRefs)
                    await $_getPrefetchedData<
                      ClothingItem,
                      $ClothingItemsTable,
                      OutfitItem
                    >(
                      currentTable: table,
                      referencedTable: $$ClothingItemsTableReferences
                          ._outfitItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ClothingItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).outfitItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClothingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClothingItemsTable,
      ClothingItem,
      $$ClothingItemsTableFilterComposer,
      $$ClothingItemsTableOrderingComposer,
      $$ClothingItemsTableAnnotationComposer,
      $$ClothingItemsTableCreateCompanionBuilder,
      $$ClothingItemsTableUpdateCompanionBuilder,
      (ClothingItem, $$ClothingItemsTableReferences),
      ClothingItem,
      PrefetchHooks Function({bool outfitItemsRefs})
    >;
typedef $$OutfitsTableCreateCompanionBuilder =
    OutfitsCompanion Function({
      required String id,
      required String name,
      Value<int> isFavorite,
      Value<int> usageCount,
      required int dateCreated,
      Value<int> rowid,
    });
typedef $$OutfitsTableUpdateCompanionBuilder =
    OutfitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> isFavorite,
      Value<int> usageCount,
      Value<int> dateCreated,
      Value<int> rowid,
    });

final class $$OutfitsTableReferences
    extends BaseReferences<_$AppDatabase, $OutfitsTable, Outfit> {
  $$OutfitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>>
  _outfitItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outfitItems,
    aliasName: $_aliasNameGenerator(db.outfits.id, db.outfitItems.outfitId),
  );

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager(
      $_db,
      $_db.outfitItems,
    ).filter((f) => f.outfitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OutfitsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> outfitItemsRefs(
    Expression<bool> Function($$OutfitItemsTableFilterComposer f) f,
  ) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableFilterComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutfitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  Expression<T> outfitItemsRefs<T extends Object>(
    Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f,
  ) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitsTable,
          Outfit,
          $$OutfitsTableFilterComposer,
          $$OutfitsTableOrderingComposer,
          $$OutfitsTableAnnotationComposer,
          $$OutfitsTableCreateCompanionBuilder,
          $$OutfitsTableUpdateCompanionBuilder,
          (Outfit, $$OutfitsTableReferences),
          Outfit,
          PrefetchHooks Function({bool outfitItemsRefs})
        > {
  $$OutfitsTableTableManager(_$AppDatabase db, $OutfitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> isFavorite = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<int> dateCreated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitsCompanion(
                id: id,
                name: name,
                isFavorite: isFavorite,
                usageCount: usageCount,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> isFavorite = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                required int dateCreated,
                Value<int> rowid = const Value.absent(),
              }) => OutfitsCompanion.insert(
                id: id,
                name: name,
                isFavorite: isFavorite,
                usageCount: usageCount,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OutfitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({outfitItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (outfitItemsRefs) db.outfitItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (outfitItemsRefs)
                    await $_getPrefetchedData<
                      Outfit,
                      $OutfitsTable,
                      OutfitItem
                    >(
                      currentTable: table,
                      referencedTable: $$OutfitsTableReferences
                          ._outfitItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$OutfitsTableReferences(
                        db,
                        table,
                        p0,
                      ).outfitItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.outfitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$OutfitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitsTable,
      Outfit,
      $$OutfitsTableFilterComposer,
      $$OutfitsTableOrderingComposer,
      $$OutfitsTableAnnotationComposer,
      $$OutfitsTableCreateCompanionBuilder,
      $$OutfitsTableUpdateCompanionBuilder,
      (Outfit, $$OutfitsTableReferences),
      Outfit,
      PrefetchHooks Function({bool outfitItemsRefs})
    >;
typedef $$OutfitItemsTableCreateCompanionBuilder =
    OutfitItemsCompanion Function({
      required String outfitId,
      required String itemId,
      Value<double> centerX,
      Value<double> centerY,
      Value<double> itemSize,
      Value<int> zIndex,
      Value<int> rowid,
    });
typedef $$OutfitItemsTableUpdateCompanionBuilder =
    OutfitItemsCompanion Function({
      Value<String> outfitId,
      Value<String> itemId,
      Value<double> centerX,
      Value<double> centerY,
      Value<double> itemSize,
      Value<int> zIndex,
      Value<int> rowid,
    });

final class $$OutfitItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OutfitItemsTable, OutfitItem> {
  $$OutfitItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OutfitsTable _outfitIdTable(_$AppDatabase db) =>
      db.outfits.createAlias(
        $_aliasNameGenerator(db.outfitItems.outfitId, db.outfits.id),
      );

  $$OutfitsTableProcessedTableManager get outfitId {
    final $_column = $_itemColumn<String>('outfit_id')!;

    final manager = $$OutfitsTableTableManager(
      $_db,
      $_db.outfits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_outfitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClothingItemsTable _itemIdTable(_$AppDatabase db) =>
      db.clothingItems.createAlias(
        $_aliasNameGenerator(db.outfitItems.itemId, db.clothingItems.id),
      );

  $$ClothingItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ClothingItemsTableTableManager(
      $_db,
      $_db.clothingItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OutfitItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get centerX => $composableBuilder(
    column: $table.centerX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get centerY => $composableBuilder(
    column: $table.centerY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get itemSize => $composableBuilder(
    column: $table.itemSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zIndex => $composableBuilder(
    column: $table.zIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$OutfitsTableFilterComposer get outfitId {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableFilterComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClothingItemsTableFilterComposer get itemId {
    final $$ClothingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableFilterComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get centerX => $composableBuilder(
    column: $table.centerX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get centerY => $composableBuilder(
    column: $table.centerY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get itemSize => $composableBuilder(
    column: $table.itemSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zIndex => $composableBuilder(
    column: $table.zIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$OutfitsTableOrderingComposer get outfitId {
    final $$OutfitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableOrderingComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClothingItemsTableOrderingComposer get itemId {
    final $$ClothingItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableOrderingComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get centerX =>
      $composableBuilder(column: $table.centerX, builder: (column) => column);

  GeneratedColumn<double> get centerY =>
      $composableBuilder(column: $table.centerY, builder: (column) => column);

  GeneratedColumn<double> get itemSize =>
      $composableBuilder(column: $table.itemSize, builder: (column) => column);

  GeneratedColumn<int> get zIndex =>
      $composableBuilder(column: $table.zIndex, builder: (column) => column);

  $$OutfitsTableAnnotationComposer get outfitId {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClothingItemsTableAnnotationComposer get itemId {
    final $$ClothingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitItemsTable,
          OutfitItem,
          $$OutfitItemsTableFilterComposer,
          $$OutfitItemsTableOrderingComposer,
          $$OutfitItemsTableAnnotationComposer,
          $$OutfitItemsTableCreateCompanionBuilder,
          $$OutfitItemsTableUpdateCompanionBuilder,
          (OutfitItem, $$OutfitItemsTableReferences),
          OutfitItem,
          PrefetchHooks Function({bool outfitId, bool itemId})
        > {
  $$OutfitItemsTableTableManager(_$AppDatabase db, $OutfitItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> outfitId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<double> centerX = const Value.absent(),
                Value<double> centerY = const Value.absent(),
                Value<double> itemSize = const Value.absent(),
                Value<int> zIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitItemsCompanion(
                outfitId: outfitId,
                itemId: itemId,
                centerX: centerX,
                centerY: centerY,
                itemSize: itemSize,
                zIndex: zIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String outfitId,
                required String itemId,
                Value<double> centerX = const Value.absent(),
                Value<double> centerY = const Value.absent(),
                Value<double> itemSize = const Value.absent(),
                Value<int> zIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitItemsCompanion.insert(
                outfitId: outfitId,
                itemId: itemId,
                centerX: centerX,
                centerY: centerY,
                itemSize: itemSize,
                zIndex: zIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OutfitItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({outfitId = false, itemId = false}) {
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
                    if (outfitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.outfitId,
                                referencedTable: $$OutfitItemsTableReferences
                                    ._outfitIdTable(db),
                                referencedColumn: $$OutfitItemsTableReferences
                                    ._outfitIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$OutfitItemsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$OutfitItemsTableReferences
                                    ._itemIdTable(db)
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

typedef $$OutfitItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitItemsTable,
      OutfitItem,
      $$OutfitItemsTableFilterComposer,
      $$OutfitItemsTableOrderingComposer,
      $$OutfitItemsTableAnnotationComposer,
      $$OutfitItemsTableCreateCompanionBuilder,
      $$OutfitItemsTableUpdateCompanionBuilder,
      (OutfitItem, $$OutfitItemsTableReferences),
      OutfitItem,
      PrefetchHooks Function({bool outfitId, bool itemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClothingItemsTableTableManager get clothingItems =>
      $$ClothingItemsTableTableManager(_db, _db.clothingItems);
  $$OutfitsTableTableManager get outfits =>
      $$OutfitsTableTableManager(_db, _db.outfits);
  $$OutfitItemsTableTableManager get outfitItems =>
      $$OutfitItemsTableTableManager(_db, _db.outfitItems);
}
