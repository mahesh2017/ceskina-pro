// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grammarTagsMeta = const VerificationMeta(
    'grammarTags',
  );
  @override
  late final GeneratedColumn<String> grammarTags = GeneratedColumn<String>(
    'grammar_tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isExamPrepMeta = const VerificationMeta(
    'isExamPrep',
  );
  @override
  late final GeneratedColumn<bool> isExamPrep = GeneratedColumn<bool>(
    'is_exam_prep',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_exam_prep" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lessonCountMeta = const VerificationMeta(
    'lessonCount',
  );
  @override
  late final GeneratedColumn<int> lessonCount = GeneratedColumn<int>(
    'lesson_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    phase,
    orderIndex,
    grammarTags,
    isExamPrep,
    lessonCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(
    Insertable<Unit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('grammar_tags')) {
      context.handle(
        _grammarTagsMeta,
        grammarTags.isAcceptableOrUnknown(
          data['grammar_tags']!,
          _grammarTagsMeta,
        ),
      );
    }
    if (data.containsKey('is_exam_prep')) {
      context.handle(
        _isExamPrepMeta,
        isExamPrep.isAcceptableOrUnknown(
          data['is_exam_prep']!,
          _isExamPrepMeta,
        ),
      );
    }
    if (data.containsKey('lesson_count')) {
      context.handle(
        _lessonCountMeta,
        lessonCount.isAcceptableOrUnknown(
          data['lesson_count']!,
          _lessonCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      grammarTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_tags'],
      )!,
      isExamPrep: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_exam_prep'],
      )!,
      lessonCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_count'],
      ),
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final int id;
  final String title;
  final String description;
  final String phase;
  final int orderIndex;
  final String grammarTags;
  final bool isExamPrep;
  final int? lessonCount;
  const Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.phase,
    required this.orderIndex,
    required this.grammarTags,
    required this.isExamPrep,
    this.lessonCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['phase'] = Variable<String>(phase);
    map['order_index'] = Variable<int>(orderIndex);
    map['grammar_tags'] = Variable<String>(grammarTags);
    map['is_exam_prep'] = Variable<bool>(isExamPrep);
    if (!nullToAbsent || lessonCount != null) {
      map['lesson_count'] = Variable<int>(lessonCount);
    }
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      phase: Value(phase),
      orderIndex: Value(orderIndex),
      grammarTags: Value(grammarTags),
      isExamPrep: Value(isExamPrep),
      lessonCount: lessonCount == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonCount),
    );
  }

  factory Unit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      phase: serializer.fromJson<String>(json['phase']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      grammarTags: serializer.fromJson<String>(json['grammarTags']),
      isExamPrep: serializer.fromJson<bool>(json['isExamPrep']),
      lessonCount: serializer.fromJson<int?>(json['lessonCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'phase': serializer.toJson<String>(phase),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'grammarTags': serializer.toJson<String>(grammarTags),
      'isExamPrep': serializer.toJson<bool>(isExamPrep),
      'lessonCount': serializer.toJson<int?>(lessonCount),
    };
  }

  Unit copyWith({
    int? id,
    String? title,
    String? description,
    String? phase,
    int? orderIndex,
    String? grammarTags,
    bool? isExamPrep,
    Value<int?> lessonCount = const Value.absent(),
  }) => Unit(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    phase: phase ?? this.phase,
    orderIndex: orderIndex ?? this.orderIndex,
    grammarTags: grammarTags ?? this.grammarTags,
    isExamPrep: isExamPrep ?? this.isExamPrep,
    lessonCount: lessonCount.present ? lessonCount.value : this.lessonCount,
  );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      phase: data.phase.present ? data.phase.value : this.phase,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      grammarTags: data.grammarTags.present
          ? data.grammarTags.value
          : this.grammarTags,
      isExamPrep: data.isExamPrep.present
          ? data.isExamPrep.value
          : this.isExamPrep,
      lessonCount: data.lessonCount.present
          ? data.lessonCount.value
          : this.lessonCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('phase: $phase, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('grammarTags: $grammarTags, ')
          ..write('isExamPrep: $isExamPrep, ')
          ..write('lessonCount: $lessonCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    phase,
    orderIndex,
    grammarTags,
    isExamPrep,
    lessonCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.phase == this.phase &&
          other.orderIndex == this.orderIndex &&
          other.grammarTags == this.grammarTags &&
          other.isExamPrep == this.isExamPrep &&
          other.lessonCount == this.lessonCount);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> phase;
  final Value<int> orderIndex;
  final Value<String> grammarTags;
  final Value<bool> isExamPrep;
  final Value<int?> lessonCount;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.phase = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.grammarTags = const Value.absent(),
    this.isExamPrep = const Value.absent(),
    this.lessonCount = const Value.absent(),
  });
  UnitsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String description,
    required String phase,
    required int orderIndex,
    this.grammarTags = const Value.absent(),
    this.isExamPrep = const Value.absent(),
    this.lessonCount = const Value.absent(),
  }) : title = Value(title),
       description = Value(description),
       phase = Value(phase),
       orderIndex = Value(orderIndex);
  static Insertable<Unit> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? phase,
    Expression<int>? orderIndex,
    Expression<String>? grammarTags,
    Expression<bool>? isExamPrep,
    Expression<int>? lessonCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (phase != null) 'phase': phase,
      if (orderIndex != null) 'order_index': orderIndex,
      if (grammarTags != null) 'grammar_tags': grammarTags,
      if (isExamPrep != null) 'is_exam_prep': isExamPrep,
      if (lessonCount != null) 'lesson_count': lessonCount,
    });
  }

  UnitsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? phase,
    Value<int>? orderIndex,
    Value<String>? grammarTags,
    Value<bool>? isExamPrep,
    Value<int?>? lessonCount,
  }) {
    return UnitsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      phase: phase ?? this.phase,
      orderIndex: orderIndex ?? this.orderIndex,
      grammarTags: grammarTags ?? this.grammarTags,
      isExamPrep: isExamPrep ?? this.isExamPrep,
      lessonCount: lessonCount ?? this.lessonCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (grammarTags.present) {
      map['grammar_tags'] = Variable<String>(grammarTags.value);
    }
    if (isExamPrep.present) {
      map['is_exam_prep'] = Variable<bool>(isExamPrep.value);
    }
    if (lessonCount.present) {
      map['lesson_count'] = Variable<int>(lessonCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('phase: $phase, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('grammarTags: $grammarTags, ')
          ..write('isExamPrep: $isExamPrep, ')
          ..write('lessonCount: $lessonCount')
          ..write(')'))
        .toString();
  }
}

class $LessonsTable extends Lessons with TableInfo<$LessonsTable, Lesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<int> unitId = GeneratedColumn<int>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES units (id)',
    ),
  );
  static const VerificationMeta _orderInUnitMeta = const VerificationMeta(
    'orderInUnit',
  );
  @override
  late final GeneratedColumn<int> orderInUnit = GeneratedColumn<int>(
    'order_in_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _lessonTypeMeta = const VerificationMeta(
    'lessonType',
  );
  @override
  late final GeneratedColumn<String> lessonType = GeneratedColumn<String>(
    'lesson_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('introduction'),
  );
  static const VerificationMeta _isReviewMeta = const VerificationMeta(
    'isReview',
  );
  @override
  late final GeneratedColumn<bool> isReview = GeneratedColumn<bool>(
    'is_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitId,
    orderInUnit,
    title,
    description,
    durationMinutes,
    lessonType,
    isReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('order_in_unit')) {
      context.handle(
        _orderInUnitMeta,
        orderInUnit.isAcceptableOrUnknown(
          data['order_in_unit']!,
          _orderInUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderInUnitMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('lesson_type')) {
      context.handle(
        _lessonTypeMeta,
        lessonType.isAcceptableOrUnknown(data['lesson_type']!, _lessonTypeMeta),
      );
    }
    if (data.containsKey('is_review')) {
      context.handle(
        _isReviewMeta,
        isReview.isAcceptableOrUnknown(data['is_review']!, _isReviewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lesson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_id'],
      )!,
      orderInUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_in_unit'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      lessonType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_type'],
      )!,
      isReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_review'],
      )!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }
}

class Lesson extends DataClass implements Insertable<Lesson> {
  final int id;
  final int unitId;
  final int orderInUnit;
  final String title;
  final String description;
  final int durationMinutes;
  final String lessonType;
  final bool isReview;
  const Lesson({
    required this.id,
    required this.unitId,
    required this.orderInUnit,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.lessonType,
    required this.isReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unit_id'] = Variable<int>(unitId);
    map['order_in_unit'] = Variable<int>(orderInUnit);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['lesson_type'] = Variable<String>(lessonType);
    map['is_review'] = Variable<bool>(isReview);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      id: Value(id),
      unitId: Value(unitId),
      orderInUnit: Value(orderInUnit),
      title: Value(title),
      description: Value(description),
      durationMinutes: Value(durationMinutes),
      lessonType: Value(lessonType),
      isReview: Value(isReview),
    );
  }

  factory Lesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lesson(
      id: serializer.fromJson<int>(json['id']),
      unitId: serializer.fromJson<int>(json['unitId']),
      orderInUnit: serializer.fromJson<int>(json['orderInUnit']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      lessonType: serializer.fromJson<String>(json['lessonType']),
      isReview: serializer.fromJson<bool>(json['isReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unitId': serializer.toJson<int>(unitId),
      'orderInUnit': serializer.toJson<int>(orderInUnit),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'lessonType': serializer.toJson<String>(lessonType),
      'isReview': serializer.toJson<bool>(isReview),
    };
  }

  Lesson copyWith({
    int? id,
    int? unitId,
    int? orderInUnit,
    String? title,
    String? description,
    int? durationMinutes,
    String? lessonType,
    bool? isReview,
  }) => Lesson(
    id: id ?? this.id,
    unitId: unitId ?? this.unitId,
    orderInUnit: orderInUnit ?? this.orderInUnit,
    title: title ?? this.title,
    description: description ?? this.description,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    lessonType: lessonType ?? this.lessonType,
    isReview: isReview ?? this.isReview,
  );
  Lesson copyWithCompanion(LessonsCompanion data) {
    return Lesson(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      orderInUnit: data.orderInUnit.present
          ? data.orderInUnit.value
          : this.orderInUnit,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      lessonType: data.lessonType.present
          ? data.lessonType.value
          : this.lessonType,
      isReview: data.isReview.present ? data.isReview.value : this.isReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lesson(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('orderInUnit: $orderInUnit, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('lessonType: $lessonType, ')
          ..write('isReview: $isReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unitId,
    orderInUnit,
    title,
    description,
    durationMinutes,
    lessonType,
    isReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lesson &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.orderInUnit == this.orderInUnit &&
          other.title == this.title &&
          other.description == this.description &&
          other.durationMinutes == this.durationMinutes &&
          other.lessonType == this.lessonType &&
          other.isReview == this.isReview);
}

class LessonsCompanion extends UpdateCompanion<Lesson> {
  final Value<int> id;
  final Value<int> unitId;
  final Value<int> orderInUnit;
  final Value<String> title;
  final Value<String> description;
  final Value<int> durationMinutes;
  final Value<String> lessonType;
  final Value<bool> isReview;
  const LessonsCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.orderInUnit = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.lessonType = const Value.absent(),
    this.isReview = const Value.absent(),
  });
  LessonsCompanion.insert({
    this.id = const Value.absent(),
    required int unitId,
    required int orderInUnit,
    required String title,
    required String description,
    this.durationMinutes = const Value.absent(),
    this.lessonType = const Value.absent(),
    this.isReview = const Value.absent(),
  }) : unitId = Value(unitId),
       orderInUnit = Value(orderInUnit),
       title = Value(title),
       description = Value(description);
  static Insertable<Lesson> custom({
    Expression<int>? id,
    Expression<int>? unitId,
    Expression<int>? orderInUnit,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? durationMinutes,
    Expression<String>? lessonType,
    Expression<bool>? isReview,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (orderInUnit != null) 'order_in_unit': orderInUnit,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (lessonType != null) 'lesson_type': lessonType,
      if (isReview != null) 'is_review': isReview,
    });
  }

  LessonsCompanion copyWith({
    Value<int>? id,
    Value<int>? unitId,
    Value<int>? orderInUnit,
    Value<String>? title,
    Value<String>? description,
    Value<int>? durationMinutes,
    Value<String>? lessonType,
    Value<bool>? isReview,
  }) {
    return LessonsCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      orderInUnit: orderInUnit ?? this.orderInUnit,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lessonType: lessonType ?? this.lessonType,
      isReview: isReview ?? this.isReview,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<int>(unitId.value);
    }
    if (orderInUnit.present) {
      map['order_in_unit'] = Variable<int>(orderInUnit.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (lessonType.present) {
      map['lesson_type'] = Variable<String>(lessonType.value);
    }
    if (isReview.present) {
      map['is_review'] = Variable<bool>(isReview.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('orderInUnit: $orderInUnit, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('lessonType: $lessonType, ')
          ..write('isReview: $isReview')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lessons (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerKeyMeta = const VerificationMeta(
    'answerKey',
  );
  @override
  late final GeneratedColumn<String> answerKey = GeneratedColumn<String>(
    'answer_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammarRuleIdMeta = const VerificationMeta(
    'grammarRuleId',
  );
  @override
  late final GeneratedColumn<String> grammarRuleId = GeneratedColumn<String>(
    'grammar_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  @override
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    type,
    prompt,
    data,
    answerKey,
    grammarRuleId,
    xpReward,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('answer_key')) {
      context.handle(
        _answerKeyMeta,
        answerKey.isAcceptableOrUnknown(data['answer_key']!, _answerKeyMeta),
      );
    }
    if (data.containsKey('grammar_rule_id')) {
      context.handle(
        _grammarRuleIdMeta,
        grammarRuleId.isAcceptableOrUnknown(
          data['grammar_rule_id']!,
          _grammarRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      answerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_key'],
      ),
      grammarRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_rule_id'],
      ),
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final int lessonId;
  final String type;
  final String prompt;
  final String data;
  final String? answerKey;
  final String? grammarRuleId;
  final int xpReward;
  const Exercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    required this.data,
    this.answerKey,
    this.grammarRuleId,
    required this.xpReward,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<int>(lessonId);
    map['type'] = Variable<String>(type);
    map['prompt'] = Variable<String>(prompt);
    map['data'] = Variable<String>(data);
    if (!nullToAbsent || answerKey != null) {
      map['answer_key'] = Variable<String>(answerKey);
    }
    if (!nullToAbsent || grammarRuleId != null) {
      map['grammar_rule_id'] = Variable<String>(grammarRuleId);
    }
    map['xp_reward'] = Variable<int>(xpReward);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      type: Value(type),
      prompt: Value(prompt),
      data: Value(data),
      answerKey: answerKey == null && nullToAbsent
          ? const Value.absent()
          : Value(answerKey),
      grammarRuleId: grammarRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(grammarRuleId),
      xpReward: Value(xpReward),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<int>(json['lessonId']),
      type: serializer.fromJson<String>(json['type']),
      prompt: serializer.fromJson<String>(json['prompt']),
      data: serializer.fromJson<String>(json['data']),
      answerKey: serializer.fromJson<String?>(json['answerKey']),
      grammarRuleId: serializer.fromJson<String?>(json['grammarRuleId']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<int>(lessonId),
      'type': serializer.toJson<String>(type),
      'prompt': serializer.toJson<String>(prompt),
      'data': serializer.toJson<String>(data),
      'answerKey': serializer.toJson<String?>(answerKey),
      'grammarRuleId': serializer.toJson<String?>(grammarRuleId),
      'xpReward': serializer.toJson<int>(xpReward),
    };
  }

  Exercise copyWith({
    int? id,
    int? lessonId,
    String? type,
    String? prompt,
    String? data,
    Value<String?> answerKey = const Value.absent(),
    Value<String?> grammarRuleId = const Value.absent(),
    int? xpReward,
  }) => Exercise(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    type: type ?? this.type,
    prompt: prompt ?? this.prompt,
    data: data ?? this.data,
    answerKey: answerKey.present ? answerKey.value : this.answerKey,
    grammarRuleId: grammarRuleId.present
        ? grammarRuleId.value
        : this.grammarRuleId,
    xpReward: xpReward ?? this.xpReward,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      type: data.type.present ? data.type.value : this.type,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      data: data.data.present ? data.data.value : this.data,
      answerKey: data.answerKey.present ? data.answerKey.value : this.answerKey,
      grammarRuleId: data.grammarRuleId.present
          ? data.grammarRuleId.value
          : this.grammarRuleId,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('type: $type, ')
          ..write('prompt: $prompt, ')
          ..write('data: $data, ')
          ..write('answerKey: $answerKey, ')
          ..write('grammarRuleId: $grammarRuleId, ')
          ..write('xpReward: $xpReward')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    type,
    prompt,
    data,
    answerKey,
    grammarRuleId,
    xpReward,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.type == this.type &&
          other.prompt == this.prompt &&
          other.data == this.data &&
          other.answerKey == this.answerKey &&
          other.grammarRuleId == this.grammarRuleId &&
          other.xpReward == this.xpReward);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<int> lessonId;
  final Value<String> type;
  final Value<String> prompt;
  final Value<String> data;
  final Value<String?> answerKey;
  final Value<String?> grammarRuleId;
  final Value<int> xpReward;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.type = const Value.absent(),
    this.prompt = const Value.absent(),
    this.data = const Value.absent(),
    this.answerKey = const Value.absent(),
    this.grammarRuleId = const Value.absent(),
    this.xpReward = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int lessonId,
    required String type,
    required String prompt,
    required String data,
    this.answerKey = const Value.absent(),
    this.grammarRuleId = const Value.absent(),
    this.xpReward = const Value.absent(),
  }) : lessonId = Value(lessonId),
       type = Value(type),
       prompt = Value(prompt),
       data = Value(data);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<int>? lessonId,
    Expression<String>? type,
    Expression<String>? prompt,
    Expression<String>? data,
    Expression<String>? answerKey,
    Expression<String>? grammarRuleId,
    Expression<int>? xpReward,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (type != null) 'type': type,
      if (prompt != null) 'prompt': prompt,
      if (data != null) 'data': data,
      if (answerKey != null) 'answer_key': answerKey,
      if (grammarRuleId != null) 'grammar_rule_id': grammarRuleId,
      if (xpReward != null) 'xp_reward': xpReward,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? lessonId,
    Value<String>? type,
    Value<String>? prompt,
    Value<String>? data,
    Value<String?>? answerKey,
    Value<String?>? grammarRuleId,
    Value<int>? xpReward,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      data: data ?? this.data,
      answerKey: answerKey ?? this.answerKey,
      grammarRuleId: grammarRuleId ?? this.grammarRuleId,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (answerKey.present) {
      map['answer_key'] = Variable<String>(answerKey.value);
    }
    if (grammarRuleId.present) {
      map['grammar_rule_id'] = Variable<String>(grammarRuleId.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('type: $type, ')
          ..write('prompt: $prompt, ')
          ..write('data: $data, ')
          ..write('answerKey: $answerKey, ')
          ..write('grammarRuleId: $grammarRuleId, ')
          ..write('xpReward: $xpReward')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordCzMeta = const VerificationMeta('wordCz');
  @override
  late final GeneratedColumn<String> wordCz = GeneratedColumn<String>(
    'word_cz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordEnMeta = const VerificationMeta('wordEn');
  @override
  late final GeneratedColumn<String> wordEn = GeneratedColumn<String>(
    'word_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipaMeta = const VerificationMeta('ipa');
  @override
  late final GeneratedColumn<String> ipa = GeneratedColumn<String>(
    'ipa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caseInfoMeta = const VerificationMeta(
    'caseInfo',
  );
  @override
  late final GeneratedColumn<String> caseInfo = GeneratedColumn<String>(
    'case_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioHashMeta = const VerificationMeta(
    'audioHash',
  );
  @override
  late final GeneratedColumn<String> audioHash = GeneratedColumn<String>(
    'audio_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleCzMeta = const VerificationMeta(
    'exampleCz',
  );
  @override
  late final GeneratedColumn<String> exampleCz = GeneratedColumn<String>(
    'example_cz',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleEnMeta = const VerificationMeta(
    'exampleEn',
  );
  @override
  late final GeneratedColumn<String> exampleEn = GeneratedColumn<String>(
    'example_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<int> unitId = GeneratedColumn<int>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES units (id)',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lessons (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordCz,
    wordEn,
    ipa,
    gender,
    caseInfo,
    audioHash,
    imagePath,
    exampleCz,
    exampleEn,
    unitId,
    lessonId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flashcard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_cz')) {
      context.handle(
        _wordCzMeta,
        wordCz.isAcceptableOrUnknown(data['word_cz']!, _wordCzMeta),
      );
    } else if (isInserting) {
      context.missing(_wordCzMeta);
    }
    if (data.containsKey('word_en')) {
      context.handle(
        _wordEnMeta,
        wordEn.isAcceptableOrUnknown(data['word_en']!, _wordEnMeta),
      );
    } else if (isInserting) {
      context.missing(_wordEnMeta);
    }
    if (data.containsKey('ipa')) {
      context.handle(
        _ipaMeta,
        ipa.isAcceptableOrUnknown(data['ipa']!, _ipaMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('case_info')) {
      context.handle(
        _caseInfoMeta,
        caseInfo.isAcceptableOrUnknown(data['case_info']!, _caseInfoMeta),
      );
    }
    if (data.containsKey('audio_hash')) {
      context.handle(
        _audioHashMeta,
        audioHash.isAcceptableOrUnknown(data['audio_hash']!, _audioHashMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('example_cz')) {
      context.handle(
        _exampleCzMeta,
        exampleCz.isAcceptableOrUnknown(data['example_cz']!, _exampleCzMeta),
      );
    }
    if (data.containsKey('example_en')) {
      context.handle(
        _exampleEnMeta,
        exampleEn.isAcceptableOrUnknown(data['example_en']!, _exampleEnMeta),
      );
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordCz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_cz'],
      )!,
      wordEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_en'],
      )!,
      ipa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipa'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      caseInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_info'],
      ),
      audioHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_hash'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      exampleCz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_cz'],
      ),
      exampleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_en'],
      ),
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_id'],
      ),
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      ),
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final int id;
  final String wordCz;
  final String wordEn;
  final String? ipa;
  final String? gender;
  final String? caseInfo;
  final String? audioHash;
  final String? imagePath;
  final String? exampleCz;
  final String? exampleEn;
  final int? unitId;

  /// The lesson that introduces this word. When set, the word is only
  /// scheduled for review once that lesson is completed (finer-grained than
  /// [unitId] gating). Null falls back to unit-level gating.
  final int? lessonId;
  const Flashcard({
    required this.id,
    required this.wordCz,
    required this.wordEn,
    this.ipa,
    this.gender,
    this.caseInfo,
    this.audioHash,
    this.imagePath,
    this.exampleCz,
    this.exampleEn,
    this.unitId,
    this.lessonId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_cz'] = Variable<String>(wordCz);
    map['word_en'] = Variable<String>(wordEn);
    if (!nullToAbsent || ipa != null) {
      map['ipa'] = Variable<String>(ipa);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || caseInfo != null) {
      map['case_info'] = Variable<String>(caseInfo);
    }
    if (!nullToAbsent || audioHash != null) {
      map['audio_hash'] = Variable<String>(audioHash);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || exampleCz != null) {
      map['example_cz'] = Variable<String>(exampleCz);
    }
    if (!nullToAbsent || exampleEn != null) {
      map['example_en'] = Variable<String>(exampleEn);
    }
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<int>(unitId);
    }
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<int>(lessonId);
    }
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      wordCz: Value(wordCz),
      wordEn: Value(wordEn),
      ipa: ipa == null && nullToAbsent ? const Value.absent() : Value(ipa),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      caseInfo: caseInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(caseInfo),
      audioHash: audioHash == null && nullToAbsent
          ? const Value.absent()
          : Value(audioHash),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      exampleCz: exampleCz == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleCz),
      exampleEn: exampleEn == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleEn),
      unitId: unitId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitId),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
    );
  }

  factory Flashcard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      id: serializer.fromJson<int>(json['id']),
      wordCz: serializer.fromJson<String>(json['wordCz']),
      wordEn: serializer.fromJson<String>(json['wordEn']),
      ipa: serializer.fromJson<String?>(json['ipa']),
      gender: serializer.fromJson<String?>(json['gender']),
      caseInfo: serializer.fromJson<String?>(json['caseInfo']),
      audioHash: serializer.fromJson<String?>(json['audioHash']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      exampleCz: serializer.fromJson<String?>(json['exampleCz']),
      exampleEn: serializer.fromJson<String?>(json['exampleEn']),
      unitId: serializer.fromJson<int?>(json['unitId']),
      lessonId: serializer.fromJson<int?>(json['lessonId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordCz': serializer.toJson<String>(wordCz),
      'wordEn': serializer.toJson<String>(wordEn),
      'ipa': serializer.toJson<String?>(ipa),
      'gender': serializer.toJson<String?>(gender),
      'caseInfo': serializer.toJson<String?>(caseInfo),
      'audioHash': serializer.toJson<String?>(audioHash),
      'imagePath': serializer.toJson<String?>(imagePath),
      'exampleCz': serializer.toJson<String?>(exampleCz),
      'exampleEn': serializer.toJson<String?>(exampleEn),
      'unitId': serializer.toJson<int?>(unitId),
      'lessonId': serializer.toJson<int?>(lessonId),
    };
  }

  Flashcard copyWith({
    int? id,
    String? wordCz,
    String? wordEn,
    Value<String?> ipa = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> caseInfo = const Value.absent(),
    Value<String?> audioHash = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> exampleCz = const Value.absent(),
    Value<String?> exampleEn = const Value.absent(),
    Value<int?> unitId = const Value.absent(),
    Value<int?> lessonId = const Value.absent(),
  }) => Flashcard(
    id: id ?? this.id,
    wordCz: wordCz ?? this.wordCz,
    wordEn: wordEn ?? this.wordEn,
    ipa: ipa.present ? ipa.value : this.ipa,
    gender: gender.present ? gender.value : this.gender,
    caseInfo: caseInfo.present ? caseInfo.value : this.caseInfo,
    audioHash: audioHash.present ? audioHash.value : this.audioHash,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    exampleCz: exampleCz.present ? exampleCz.value : this.exampleCz,
    exampleEn: exampleEn.present ? exampleEn.value : this.exampleEn,
    unitId: unitId.present ? unitId.value : this.unitId,
    lessonId: lessonId.present ? lessonId.value : this.lessonId,
  );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      id: data.id.present ? data.id.value : this.id,
      wordCz: data.wordCz.present ? data.wordCz.value : this.wordCz,
      wordEn: data.wordEn.present ? data.wordEn.value : this.wordEn,
      ipa: data.ipa.present ? data.ipa.value : this.ipa,
      gender: data.gender.present ? data.gender.value : this.gender,
      caseInfo: data.caseInfo.present ? data.caseInfo.value : this.caseInfo,
      audioHash: data.audioHash.present ? data.audioHash.value : this.audioHash,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      exampleCz: data.exampleCz.present ? data.exampleCz.value : this.exampleCz,
      exampleEn: data.exampleEn.present ? data.exampleEn.value : this.exampleEn,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('id: $id, ')
          ..write('wordCz: $wordCz, ')
          ..write('wordEn: $wordEn, ')
          ..write('ipa: $ipa, ')
          ..write('gender: $gender, ')
          ..write('caseInfo: $caseInfo, ')
          ..write('audioHash: $audioHash, ')
          ..write('imagePath: $imagePath, ')
          ..write('exampleCz: $exampleCz, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('unitId: $unitId, ')
          ..write('lessonId: $lessonId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordCz,
    wordEn,
    ipa,
    gender,
    caseInfo,
    audioHash,
    imagePath,
    exampleCz,
    exampleEn,
    unitId,
    lessonId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.id == this.id &&
          other.wordCz == this.wordCz &&
          other.wordEn == this.wordEn &&
          other.ipa == this.ipa &&
          other.gender == this.gender &&
          other.caseInfo == this.caseInfo &&
          other.audioHash == this.audioHash &&
          other.imagePath == this.imagePath &&
          other.exampleCz == this.exampleCz &&
          other.exampleEn == this.exampleEn &&
          other.unitId == this.unitId &&
          other.lessonId == this.lessonId);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<int> id;
  final Value<String> wordCz;
  final Value<String> wordEn;
  final Value<String?> ipa;
  final Value<String?> gender;
  final Value<String?> caseInfo;
  final Value<String?> audioHash;
  final Value<String?> imagePath;
  final Value<String?> exampleCz;
  final Value<String?> exampleEn;
  final Value<int?> unitId;
  final Value<int?> lessonId;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.wordCz = const Value.absent(),
    this.wordEn = const Value.absent(),
    this.ipa = const Value.absent(),
    this.gender = const Value.absent(),
    this.caseInfo = const Value.absent(),
    this.audioHash = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.exampleCz = const Value.absent(),
    this.exampleEn = const Value.absent(),
    this.unitId = const Value.absent(),
    this.lessonId = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    this.id = const Value.absent(),
    required String wordCz,
    required String wordEn,
    this.ipa = const Value.absent(),
    this.gender = const Value.absent(),
    this.caseInfo = const Value.absent(),
    this.audioHash = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.exampleCz = const Value.absent(),
    this.exampleEn = const Value.absent(),
    this.unitId = const Value.absent(),
    this.lessonId = const Value.absent(),
  }) : wordCz = Value(wordCz),
       wordEn = Value(wordEn);
  static Insertable<Flashcard> custom({
    Expression<int>? id,
    Expression<String>? wordCz,
    Expression<String>? wordEn,
    Expression<String>? ipa,
    Expression<String>? gender,
    Expression<String>? caseInfo,
    Expression<String>? audioHash,
    Expression<String>? imagePath,
    Expression<String>? exampleCz,
    Expression<String>? exampleEn,
    Expression<int>? unitId,
    Expression<int>? lessonId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordCz != null) 'word_cz': wordCz,
      if (wordEn != null) 'word_en': wordEn,
      if (ipa != null) 'ipa': ipa,
      if (gender != null) 'gender': gender,
      if (caseInfo != null) 'case_info': caseInfo,
      if (audioHash != null) 'audio_hash': audioHash,
      if (imagePath != null) 'image_path': imagePath,
      if (exampleCz != null) 'example_cz': exampleCz,
      if (exampleEn != null) 'example_en': exampleEn,
      if (unitId != null) 'unit_id': unitId,
      if (lessonId != null) 'lesson_id': lessonId,
    });
  }

  FlashcardsCompanion copyWith({
    Value<int>? id,
    Value<String>? wordCz,
    Value<String>? wordEn,
    Value<String?>? ipa,
    Value<String?>? gender,
    Value<String?>? caseInfo,
    Value<String?>? audioHash,
    Value<String?>? imagePath,
    Value<String?>? exampleCz,
    Value<String?>? exampleEn,
    Value<int?>? unitId,
    Value<int?>? lessonId,
  }) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      wordCz: wordCz ?? this.wordCz,
      wordEn: wordEn ?? this.wordEn,
      ipa: ipa ?? this.ipa,
      gender: gender ?? this.gender,
      caseInfo: caseInfo ?? this.caseInfo,
      audioHash: audioHash ?? this.audioHash,
      imagePath: imagePath ?? this.imagePath,
      exampleCz: exampleCz ?? this.exampleCz,
      exampleEn: exampleEn ?? this.exampleEn,
      unitId: unitId ?? this.unitId,
      lessonId: lessonId ?? this.lessonId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordCz.present) {
      map['word_cz'] = Variable<String>(wordCz.value);
    }
    if (wordEn.present) {
      map['word_en'] = Variable<String>(wordEn.value);
    }
    if (ipa.present) {
      map['ipa'] = Variable<String>(ipa.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (caseInfo.present) {
      map['case_info'] = Variable<String>(caseInfo.value);
    }
    if (audioHash.present) {
      map['audio_hash'] = Variable<String>(audioHash.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (exampleCz.present) {
      map['example_cz'] = Variable<String>(exampleCz.value);
    }
    if (exampleEn.present) {
      map['example_en'] = Variable<String>(exampleEn.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<int>(unitId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('wordCz: $wordCz, ')
          ..write('wordEn: $wordEn, ')
          ..write('ipa: $ipa, ')
          ..write('gender: $gender, ')
          ..write('caseInfo: $caseInfo, ')
          ..write('audioHash: $audioHash, ')
          ..write('imagePath: $imagePath, ')
          ..write('exampleCz: $exampleCz, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('unitId: $unitId, ')
          ..write('lessonId: $lessonId')
          ..write(')'))
        .toString();
  }
}

class $SrsCardsTable extends SrsCards with TableInfo<$SrsCardsTable, SrsCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SrsCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta(
    'cardType',
  );
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  @override
  late final GeneratedColumn<int> flashcardId = GeneratedColumn<int>(
    'flashcard_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flashcards (id)',
    ),
  );
  static const VerificationMeta _grammarPatternKeyMeta = const VerificationMeta(
    'grammarPatternKey',
  );
  @override
  late final GeneratedColumn<String> grammarPatternKey =
      GeneratedColumn<String>(
        'grammar_pattern_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('newCard'),
  );
  static const VerificationMeta _lastReviewedMeta = const VerificationMeta(
    'lastReviewed',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewed = GeneratedColumn<DateTime>(
    'last_reviewed',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardType,
    flashcardId,
    grammarPatternKey,
    stability,
    difficulty,
    due,
    reps,
    state,
    lastReviewed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'srs_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<SrsCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_cardTypeMeta);
    }
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    }
    if (data.containsKey('grammar_pattern_key')) {
      context.handle(
        _grammarPatternKeyMeta,
        grammarPatternKey.isAcceptableOrUnknown(
          data['grammar_pattern_key']!,
          _grammarPatternKeyMeta,
        ),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('last_reviewed')) {
      context.handle(
        _lastReviewedMeta,
        lastReviewed.isAcceptableOrUnknown(
          data['last_reviewed']!,
          _lastReviewedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SrsCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SrsCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      )!,
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flashcard_id'],
      ),
      grammarPatternKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_pattern_key'],
      ),
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      lastReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed'],
      ),
    );
  }

  @override
  $SrsCardsTable createAlias(String alias) {
    return $SrsCardsTable(attachedDatabase, alias);
  }
}

class SrsCard extends DataClass implements Insertable<SrsCard> {
  final int id;
  final String cardType;
  final int? flashcardId;
  final String? grammarPatternKey;
  final double stability;
  final double difficulty;
  final DateTime due;
  final int reps;
  final String state;
  final DateTime? lastReviewed;
  const SrsCard({
    required this.id,
    required this.cardType,
    this.flashcardId,
    this.grammarPatternKey,
    required this.stability,
    required this.difficulty,
    required this.due,
    required this.reps,
    required this.state,
    this.lastReviewed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_type'] = Variable<String>(cardType);
    if (!nullToAbsent || flashcardId != null) {
      map['flashcard_id'] = Variable<int>(flashcardId);
    }
    if (!nullToAbsent || grammarPatternKey != null) {
      map['grammar_pattern_key'] = Variable<String>(grammarPatternKey);
    }
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['due'] = Variable<DateTime>(due);
    map['reps'] = Variable<int>(reps);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || lastReviewed != null) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed);
    }
    return map;
  }

  SrsCardsCompanion toCompanion(bool nullToAbsent) {
    return SrsCardsCompanion(
      id: Value(id),
      cardType: Value(cardType),
      flashcardId: flashcardId == null && nullToAbsent
          ? const Value.absent()
          : Value(flashcardId),
      grammarPatternKey: grammarPatternKey == null && nullToAbsent
          ? const Value.absent()
          : Value(grammarPatternKey),
      stability: Value(stability),
      difficulty: Value(difficulty),
      due: Value(due),
      reps: Value(reps),
      state: Value(state),
      lastReviewed: lastReviewed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewed),
    );
  }

  factory SrsCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SrsCard(
      id: serializer.fromJson<int>(json['id']),
      cardType: serializer.fromJson<String>(json['cardType']),
      flashcardId: serializer.fromJson<int?>(json['flashcardId']),
      grammarPatternKey: serializer.fromJson<String?>(
        json['grammarPatternKey'],
      ),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      due: serializer.fromJson<DateTime>(json['due']),
      reps: serializer.fromJson<int>(json['reps']),
      state: serializer.fromJson<String>(json['state']),
      lastReviewed: serializer.fromJson<DateTime?>(json['lastReviewed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardType': serializer.toJson<String>(cardType),
      'flashcardId': serializer.toJson<int?>(flashcardId),
      'grammarPatternKey': serializer.toJson<String?>(grammarPatternKey),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'due': serializer.toJson<DateTime>(due),
      'reps': serializer.toJson<int>(reps),
      'state': serializer.toJson<String>(state),
      'lastReviewed': serializer.toJson<DateTime?>(lastReviewed),
    };
  }

  SrsCard copyWith({
    int? id,
    String? cardType,
    Value<int?> flashcardId = const Value.absent(),
    Value<String?> grammarPatternKey = const Value.absent(),
    double? stability,
    double? difficulty,
    DateTime? due,
    int? reps,
    String? state,
    Value<DateTime?> lastReviewed = const Value.absent(),
  }) => SrsCard(
    id: id ?? this.id,
    cardType: cardType ?? this.cardType,
    flashcardId: flashcardId.present ? flashcardId.value : this.flashcardId,
    grammarPatternKey: grammarPatternKey.present
        ? grammarPatternKey.value
        : this.grammarPatternKey,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    due: due ?? this.due,
    reps: reps ?? this.reps,
    state: state ?? this.state,
    lastReviewed: lastReviewed.present ? lastReviewed.value : this.lastReviewed,
  );
  SrsCard copyWithCompanion(SrsCardsCompanion data) {
    return SrsCard(
      id: data.id.present ? data.id.value : this.id,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      grammarPatternKey: data.grammarPatternKey.present
          ? data.grammarPatternKey.value
          : this.grammarPatternKey,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      due: data.due.present ? data.due.value : this.due,
      reps: data.reps.present ? data.reps.value : this.reps,
      state: data.state.present ? data.state.value : this.state,
      lastReviewed: data.lastReviewed.present
          ? data.lastReviewed.value
          : this.lastReviewed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SrsCard(')
          ..write('id: $id, ')
          ..write('cardType: $cardType, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('grammarPatternKey: $grammarPatternKey, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('reps: $reps, ')
          ..write('state: $state, ')
          ..write('lastReviewed: $lastReviewed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardType,
    flashcardId,
    grammarPatternKey,
    stability,
    difficulty,
    due,
    reps,
    state,
    lastReviewed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SrsCard &&
          other.id == this.id &&
          other.cardType == this.cardType &&
          other.flashcardId == this.flashcardId &&
          other.grammarPatternKey == this.grammarPatternKey &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.due == this.due &&
          other.reps == this.reps &&
          other.state == this.state &&
          other.lastReviewed == this.lastReviewed);
}

class SrsCardsCompanion extends UpdateCompanion<SrsCard> {
  final Value<int> id;
  final Value<String> cardType;
  final Value<int?> flashcardId;
  final Value<String?> grammarPatternKey;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime> due;
  final Value<int> reps;
  final Value<String> state;
  final Value<DateTime?> lastReviewed;
  const SrsCardsCompanion({
    this.id = const Value.absent(),
    this.cardType = const Value.absent(),
    this.flashcardId = const Value.absent(),
    this.grammarPatternKey = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.due = const Value.absent(),
    this.reps = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReviewed = const Value.absent(),
  });
  SrsCardsCompanion.insert({
    this.id = const Value.absent(),
    required String cardType,
    this.flashcardId = const Value.absent(),
    this.grammarPatternKey = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.due = const Value.absent(),
    this.reps = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReviewed = const Value.absent(),
  }) : cardType = Value(cardType);
  static Insertable<SrsCard> custom({
    Expression<int>? id,
    Expression<String>? cardType,
    Expression<int>? flashcardId,
    Expression<String>? grammarPatternKey,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? due,
    Expression<int>? reps,
    Expression<String>? state,
    Expression<DateTime>? lastReviewed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardType != null) 'card_type': cardType,
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (grammarPatternKey != null) 'grammar_pattern_key': grammarPatternKey,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (due != null) 'due': due,
      if (reps != null) 'reps': reps,
      if (state != null) 'state': state,
      if (lastReviewed != null) 'last_reviewed': lastReviewed,
    });
  }

  SrsCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardType,
    Value<int?>? flashcardId,
    Value<String?>? grammarPatternKey,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime>? due,
    Value<int>? reps,
    Value<String>? state,
    Value<DateTime?>? lastReviewed,
  }) {
    return SrsCardsCompanion(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      flashcardId: flashcardId ?? this.flashcardId,
      grammarPatternKey: grammarPatternKey ?? this.grammarPatternKey,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      reps: reps ?? this.reps,
      state: state ?? this.state,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<int>(flashcardId.value);
    }
    if (grammarPatternKey.present) {
      map['grammar_pattern_key'] = Variable<String>(grammarPatternKey.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (lastReviewed.present) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SrsCardsCompanion(')
          ..write('id: $id, ')
          ..write('cardType: $cardType, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('grammarPatternKey: $grammarPatternKey, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('reps: $reps, ')
          ..write('state: $state, ')
          ..write('lastReviewed: $lastReviewed')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioMeta = const VerificationMeta(
    'scenario',
  );
  @override
  late final GeneratedColumn<String> scenario = GeneratedColumn<String>(
    'scenario',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cefrLevelMeta = const VerificationMeta(
    'cefrLevel',
  );
  @override
  late final GeneratedColumn<String> cefrLevel = GeneratedColumn<String>(
    'cefr_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [id, scenario, cefrLevel, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scenario')) {
      context.handle(
        _scenarioMeta,
        scenario.isAcceptableOrUnknown(data['scenario']!, _scenarioMeta),
      );
    } else if (isInserting) {
      context.missing(_scenarioMeta);
    }
    if (data.containsKey('cefr_level')) {
      context.handle(
        _cefrLevelMeta,
        cefrLevel.isAcceptableOrUnknown(data['cefr_level']!, _cefrLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_cefrLevelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scenario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario'],
      )!,
      cefrLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cefr_level'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String scenario;
  final String cefrLevel;
  final DateTime createdAt;
  const Conversation({
    required this.id,
    required this.scenario,
    required this.cefrLevel,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scenario'] = Variable<String>(scenario);
    map['cefr_level'] = Variable<String>(cefrLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      scenario: Value(scenario),
      cefrLevel: Value(cefrLevel),
      createdAt: Value(createdAt),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      scenario: serializer.fromJson<String>(json['scenario']),
      cefrLevel: serializer.fromJson<String>(json['cefrLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scenario': serializer.toJson<String>(scenario),
      'cefrLevel': serializer.toJson<String>(cefrLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Conversation copyWith({
    String? id,
    String? scenario,
    String? cefrLevel,
    DateTime? createdAt,
  }) => Conversation(
    id: id ?? this.id,
    scenario: scenario ?? this.scenario,
    cefrLevel: cefrLevel ?? this.cefrLevel,
    createdAt: createdAt ?? this.createdAt,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      scenario: data.scenario.present ? data.scenario.value : this.scenario,
      cefrLevel: data.cefrLevel.present ? data.cefrLevel.value : this.cefrLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('scenario: $scenario, ')
          ..write('cefrLevel: $cefrLevel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scenario, cefrLevel, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.scenario == this.scenario &&
          other.cefrLevel == this.cefrLevel &&
          other.createdAt == this.createdAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> scenario;
  final Value<String> cefrLevel;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.scenario = const Value.absent(),
    this.cefrLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String scenario,
    required String cefrLevel,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scenario = Value(scenario),
       cefrLevel = Value(cefrLevel);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? scenario,
    Expression<String>? cefrLevel,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenario != null) 'scenario': scenario,
      if (cefrLevel != null) 'cefr_level': cefrLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? scenario,
    Value<String>? cefrLevel,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      scenario: scenario ?? this.scenario,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scenario.present) {
      map['scenario'] = Variable<String>(scenario.value);
    }
    if (cefrLevel.present) {
      map['cefr_level'] = Variable<String>(cefrLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('scenario: $scenario, ')
          ..write('cefrLevel: $cefrLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctionsMeta = const VerificationMeta(
    'corrections',
  );
  @override
  late final GeneratedColumn<String> corrections = GeneratedColumn<String>(
    'corrections',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newVocabularyMeta = const VerificationMeta(
    'newVocabulary',
  );
  @override
  late final GeneratedColumn<String> newVocabulary = GeneratedColumn<String>(
    'new_vocabulary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    translation,
    corrections,
    newVocabulary,
    audioPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    if (data.containsKey('corrections')) {
      context.handle(
        _correctionsMeta,
        corrections.isAcceptableOrUnknown(
          data['corrections']!,
          _correctionsMeta,
        ),
      );
    }
    if (data.containsKey('new_vocabulary')) {
      context.handle(
        _newVocabularyMeta,
        newVocabulary.isAcceptableOrUnknown(
          data['new_vocabulary']!,
          _newVocabularyMeta,
        ),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      ),
      corrections: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrections'],
      ),
      newVocabulary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_vocabulary'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String conversationId;
  final String role;
  final String content;
  final String? translation;
  final String? corrections;
  final String? newVocabulary;
  final String? audioPath;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.translation,
    this.corrections,
    this.newVocabulary,
    this.audioPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    if (!nullToAbsent || corrections != null) {
      map['corrections'] = Variable<String>(corrections);
    }
    if (!nullToAbsent || newVocabulary != null) {
      map['new_vocabulary'] = Variable<String>(newVocabulary);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
      corrections: corrections == null && nullToAbsent
          ? const Value.absent()
          : Value(corrections),
      newVocabulary: newVocabulary == null && nullToAbsent
          ? const Value.absent()
          : Value(newVocabulary),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      translation: serializer.fromJson<String?>(json['translation']),
      corrections: serializer.fromJson<String?>(json['corrections']),
      newVocabulary: serializer.fromJson<String?>(json['newVocabulary']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'translation': serializer.toJson<String?>(translation),
      'corrections': serializer.toJson<String?>(corrections),
      'newVocabulary': serializer.toJson<String?>(newVocabulary),
      'audioPath': serializer.toJson<String?>(audioPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    int? id,
    String? conversationId,
    String? role,
    String? content,
    Value<String?> translation = const Value.absent(),
    Value<String?> corrections = const Value.absent(),
    Value<String?> newVocabulary = const Value.absent(),
    Value<String?> audioPath = const Value.absent(),
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    translation: translation.present ? translation.value : this.translation,
    corrections: corrections.present ? corrections.value : this.corrections,
    newVocabulary: newVocabulary.present
        ? newVocabulary.value
        : this.newVocabulary,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      corrections: data.corrections.present
          ? data.corrections.value
          : this.corrections,
      newVocabulary: data.newVocabulary.present
          ? data.newVocabulary.value
          : this.newVocabulary,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('translation: $translation, ')
          ..write('corrections: $corrections, ')
          ..write('newVocabulary: $newVocabulary, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    translation,
    corrections,
    newVocabulary,
    audioPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.translation == this.translation &&
          other.corrections == this.corrections &&
          other.newVocabulary == this.newVocabulary &&
          other.audioPath == this.audioPath &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> translation;
  final Value<String?> corrections;
  final Value<String?> newVocabulary;
  final Value<String?> audioPath;
  final Value<DateTime> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.translation = const Value.absent(),
    this.corrections = const Value.absent(),
    this.newVocabulary = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String conversationId,
    required String role,
    required String content,
    this.translation = const Value.absent(),
    this.corrections = const Value.absent(),
    this.newVocabulary = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? translation,
    Expression<String>? corrections,
    Expression<String>? newVocabulary,
    Expression<String>? audioPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (translation != null) 'translation': translation,
      if (corrections != null) 'corrections': corrections,
      if (newVocabulary != null) 'new_vocabulary': newVocabulary,
      if (audioPath != null) 'audio_path': audioPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? translation,
    Value<String?>? corrections,
    Value<String?>? newVocabulary,
    Value<String?>? audioPath,
    Value<DateTime>? createdAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      translation: translation ?? this.translation,
      corrections: corrections ?? this.corrections,
      newVocabulary: newVocabulary ?? this.newVocabulary,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (corrections.present) {
      map['corrections'] = Variable<String>(corrections.value);
    }
    if (newVocabulary.present) {
      map['new_vocabulary'] = Variable<String>(newVocabulary.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('translation: $translation, ')
          ..write('corrections: $corrections, ')
          ..write('newVocabulary: $newVocabulary, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GrammarRulesTable extends GrammarRules
    with TableInfo<$GrammarRulesTable, GrammarRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleNameMeta = const VerificationMeta(
    'ruleName',
  );
  @override
  late final GeneratedColumn<String> ruleName = GeneratedColumn<String>(
    'rule_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseAffectedMeta = const VerificationMeta(
    'caseAffected',
  );
  @override
  late final GeneratedColumn<String> caseAffected = GeneratedColumn<String>(
    'case_affected',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examplesMeta = const VerificationMeta(
    'examples',
  );
  @override
  late final GeneratedColumn<String> examples = GeneratedColumn<String>(
    'examples',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<int> unitId = GeneratedColumn<int>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES units (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleName,
    pattern,
    explanation,
    caseAffected,
    examples,
    unitId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_name')) {
      context.handle(
        _ruleNameMeta,
        ruleName.isAcceptableOrUnknown(data['rule_name']!, _ruleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleNameMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('case_affected')) {
      context.handle(
        _caseAffectedMeta,
        caseAffected.isAcceptableOrUnknown(
          data['case_affected']!,
          _caseAffectedMeta,
        ),
      );
    }
    if (data.containsKey('examples')) {
      context.handle(
        _examplesMeta,
        examples.isAcceptableOrUnknown(data['examples']!, _examplesMeta),
      );
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ruleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_name'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      caseAffected: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_affected'],
      ),
      examples: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_id'],
      ),
    );
  }

  @override
  $GrammarRulesTable createAlias(String alias) {
    return $GrammarRulesTable(attachedDatabase, alias);
  }
}

class GrammarRule extends DataClass implements Insertable<GrammarRule> {
  final String id;
  final String ruleName;
  final String pattern;
  final String explanation;
  final String? caseAffected;
  final String examples;
  final int? unitId;
  const GrammarRule({
    required this.id,
    required this.ruleName,
    required this.pattern,
    required this.explanation,
    this.caseAffected,
    required this.examples,
    this.unitId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_name'] = Variable<String>(ruleName);
    map['pattern'] = Variable<String>(pattern);
    map['explanation'] = Variable<String>(explanation);
    if (!nullToAbsent || caseAffected != null) {
      map['case_affected'] = Variable<String>(caseAffected);
    }
    map['examples'] = Variable<String>(examples);
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<int>(unitId);
    }
    return map;
  }

  GrammarRulesCompanion toCompanion(bool nullToAbsent) {
    return GrammarRulesCompanion(
      id: Value(id),
      ruleName: Value(ruleName),
      pattern: Value(pattern),
      explanation: Value(explanation),
      caseAffected: caseAffected == null && nullToAbsent
          ? const Value.absent()
          : Value(caseAffected),
      examples: Value(examples),
      unitId: unitId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitId),
    );
  }

  factory GrammarRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarRule(
      id: serializer.fromJson<String>(json['id']),
      ruleName: serializer.fromJson<String>(json['ruleName']),
      pattern: serializer.fromJson<String>(json['pattern']),
      explanation: serializer.fromJson<String>(json['explanation']),
      caseAffected: serializer.fromJson<String?>(json['caseAffected']),
      examples: serializer.fromJson<String>(json['examples']),
      unitId: serializer.fromJson<int?>(json['unitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ruleName': serializer.toJson<String>(ruleName),
      'pattern': serializer.toJson<String>(pattern),
      'explanation': serializer.toJson<String>(explanation),
      'caseAffected': serializer.toJson<String?>(caseAffected),
      'examples': serializer.toJson<String>(examples),
      'unitId': serializer.toJson<int?>(unitId),
    };
  }

  GrammarRule copyWith({
    String? id,
    String? ruleName,
    String? pattern,
    String? explanation,
    Value<String?> caseAffected = const Value.absent(),
    String? examples,
    Value<int?> unitId = const Value.absent(),
  }) => GrammarRule(
    id: id ?? this.id,
    ruleName: ruleName ?? this.ruleName,
    pattern: pattern ?? this.pattern,
    explanation: explanation ?? this.explanation,
    caseAffected: caseAffected.present ? caseAffected.value : this.caseAffected,
    examples: examples ?? this.examples,
    unitId: unitId.present ? unitId.value : this.unitId,
  );
  GrammarRule copyWithCompanion(GrammarRulesCompanion data) {
    return GrammarRule(
      id: data.id.present ? data.id.value : this.id,
      ruleName: data.ruleName.present ? data.ruleName.value : this.ruleName,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      caseAffected: data.caseAffected.present
          ? data.caseAffected.value
          : this.caseAffected,
      examples: data.examples.present ? data.examples.value : this.examples,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarRule(')
          ..write('id: $id, ')
          ..write('ruleName: $ruleName, ')
          ..write('pattern: $pattern, ')
          ..write('explanation: $explanation, ')
          ..write('caseAffected: $caseAffected, ')
          ..write('examples: $examples, ')
          ..write('unitId: $unitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleName,
    pattern,
    explanation,
    caseAffected,
    examples,
    unitId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarRule &&
          other.id == this.id &&
          other.ruleName == this.ruleName &&
          other.pattern == this.pattern &&
          other.explanation == this.explanation &&
          other.caseAffected == this.caseAffected &&
          other.examples == this.examples &&
          other.unitId == this.unitId);
}

class GrammarRulesCompanion extends UpdateCompanion<GrammarRule> {
  final Value<String> id;
  final Value<String> ruleName;
  final Value<String> pattern;
  final Value<String> explanation;
  final Value<String?> caseAffected;
  final Value<String> examples;
  final Value<int?> unitId;
  final Value<int> rowid;
  const GrammarRulesCompanion({
    this.id = const Value.absent(),
    this.ruleName = const Value.absent(),
    this.pattern = const Value.absent(),
    this.explanation = const Value.absent(),
    this.caseAffected = const Value.absent(),
    this.examples = const Value.absent(),
    this.unitId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrammarRulesCompanion.insert({
    required String id,
    required String ruleName,
    required String pattern,
    required String explanation,
    this.caseAffected = const Value.absent(),
    this.examples = const Value.absent(),
    this.unitId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleName = Value(ruleName),
       pattern = Value(pattern),
       explanation = Value(explanation);
  static Insertable<GrammarRule> custom({
    Expression<String>? id,
    Expression<String>? ruleName,
    Expression<String>? pattern,
    Expression<String>? explanation,
    Expression<String>? caseAffected,
    Expression<String>? examples,
    Expression<int>? unitId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleName != null) 'rule_name': ruleName,
      if (pattern != null) 'pattern': pattern,
      if (explanation != null) 'explanation': explanation,
      if (caseAffected != null) 'case_affected': caseAffected,
      if (examples != null) 'examples': examples,
      if (unitId != null) 'unit_id': unitId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrammarRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? ruleName,
    Value<String>? pattern,
    Value<String>? explanation,
    Value<String?>? caseAffected,
    Value<String>? examples,
    Value<int?>? unitId,
    Value<int>? rowid,
  }) {
    return GrammarRulesCompanion(
      id: id ?? this.id,
      ruleName: ruleName ?? this.ruleName,
      pattern: pattern ?? this.pattern,
      explanation: explanation ?? this.explanation,
      caseAffected: caseAffected ?? this.caseAffected,
      examples: examples ?? this.examples,
      unitId: unitId ?? this.unitId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleName.present) {
      map['rule_name'] = Variable<String>(ruleName.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (caseAffected.present) {
      map['case_affected'] = Variable<String>(caseAffected.value);
    }
    if (examples.present) {
      map['examples'] = Variable<String>(examples.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<int>(unitId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarRulesCompanion(')
          ..write('id: $id, ')
          ..write('ruleName: $ruleName, ')
          ..write('pattern: $pattern, ')
          ..write('explanation: $explanation, ')
          ..write('caseAffected: $caseAffected, ')
          ..write('examples: $examples, ')
          ..write('unitId: $unitId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamResultsTable extends ExamResults
    with TableInfo<$ExamResultsTable, ExamResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  static const VerificationMeta _readingScoreMeta = const VerificationMeta(
    'readingScore',
  );
  @override
  late final GeneratedColumn<int> readingScore = GeneratedColumn<int>(
    'reading_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _listeningScoreMeta = const VerificationMeta(
    'listeningScore',
  );
  @override
  late final GeneratedColumn<int> listeningScore = GeneratedColumn<int>(
    'listening_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _writingScoreMeta = const VerificationMeta(
    'writingScore',
  );
  @override
  late final GeneratedColumn<int> writingScore = GeneratedColumn<int>(
    'writing_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speakingScoreMeta = const VerificationMeta(
    'speakingScore',
  );
  @override
  late final GeneratedColumn<int> speakingScore = GeneratedColumn<int>(
    'speaking_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalScoreMeta = const VerificationMeta(
    'totalScore',
  );
  @override
  late final GeneratedColumn<int> totalScore = GeneratedColumn<int>(
    'total_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
    'passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("passed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    takenAt,
    readingScore,
    listeningScore,
    writingScore,
    speakingScore,
    totalScore,
    passed,
    details,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    }
    if (data.containsKey('reading_score')) {
      context.handle(
        _readingScoreMeta,
        readingScore.isAcceptableOrUnknown(
          data['reading_score']!,
          _readingScoreMeta,
        ),
      );
    }
    if (data.containsKey('listening_score')) {
      context.handle(
        _listeningScoreMeta,
        listeningScore.isAcceptableOrUnknown(
          data['listening_score']!,
          _listeningScoreMeta,
        ),
      );
    }
    if (data.containsKey('writing_score')) {
      context.handle(
        _writingScoreMeta,
        writingScore.isAcceptableOrUnknown(
          data['writing_score']!,
          _writingScoreMeta,
        ),
      );
    }
    if (data.containsKey('speaking_score')) {
      context.handle(
        _speakingScoreMeta,
        speakingScore.isAcceptableOrUnknown(
          data['speaking_score']!,
          _speakingScoreMeta,
        ),
      );
    }
    if (data.containsKey('total_score')) {
      context.handle(
        _totalScoreMeta,
        totalScore.isAcceptableOrUnknown(data['total_score']!, _totalScoreMeta),
      );
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      readingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reading_score'],
      )!,
      listeningScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listening_score'],
      )!,
      writingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}writing_score'],
      )!,
      speakingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaking_score'],
      )!,
      totalScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_score'],
      )!,
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}passed'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
    );
  }

  @override
  $ExamResultsTable createAlias(String alias) {
    return $ExamResultsTable(attachedDatabase, alias);
  }
}

class ExamResult extends DataClass implements Insertable<ExamResult> {
  final int id;
  final String level;
  final DateTime takenAt;
  final int readingScore;
  final int listeningScore;
  final int writingScore;
  final int speakingScore;
  final int totalScore;
  final bool passed;
  final String? details;
  const ExamResult({
    required this.id,
    required this.level,
    required this.takenAt,
    required this.readingScore,
    required this.listeningScore,
    required this.writingScore,
    required this.speakingScore,
    required this.totalScore,
    required this.passed,
    this.details,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['reading_score'] = Variable<int>(readingScore);
    map['listening_score'] = Variable<int>(listeningScore);
    map['writing_score'] = Variable<int>(writingScore);
    map['speaking_score'] = Variable<int>(speakingScore);
    map['total_score'] = Variable<int>(totalScore);
    map['passed'] = Variable<bool>(passed);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    return map;
  }

  ExamResultsCompanion toCompanion(bool nullToAbsent) {
    return ExamResultsCompanion(
      id: Value(id),
      level: Value(level),
      takenAt: Value(takenAt),
      readingScore: Value(readingScore),
      listeningScore: Value(listeningScore),
      writingScore: Value(writingScore),
      speakingScore: Value(speakingScore),
      totalScore: Value(totalScore),
      passed: Value(passed),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
    );
  }

  factory ExamResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamResult(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      readingScore: serializer.fromJson<int>(json['readingScore']),
      listeningScore: serializer.fromJson<int>(json['listeningScore']),
      writingScore: serializer.fromJson<int>(json['writingScore']),
      speakingScore: serializer.fromJson<int>(json['speakingScore']),
      totalScore: serializer.fromJson<int>(json['totalScore']),
      passed: serializer.fromJson<bool>(json['passed']),
      details: serializer.fromJson<String?>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'readingScore': serializer.toJson<int>(readingScore),
      'listeningScore': serializer.toJson<int>(listeningScore),
      'writingScore': serializer.toJson<int>(writingScore),
      'speakingScore': serializer.toJson<int>(speakingScore),
      'totalScore': serializer.toJson<int>(totalScore),
      'passed': serializer.toJson<bool>(passed),
      'details': serializer.toJson<String?>(details),
    };
  }

  ExamResult copyWith({
    int? id,
    String? level,
    DateTime? takenAt,
    int? readingScore,
    int? listeningScore,
    int? writingScore,
    int? speakingScore,
    int? totalScore,
    bool? passed,
    Value<String?> details = const Value.absent(),
  }) => ExamResult(
    id: id ?? this.id,
    level: level ?? this.level,
    takenAt: takenAt ?? this.takenAt,
    readingScore: readingScore ?? this.readingScore,
    listeningScore: listeningScore ?? this.listeningScore,
    writingScore: writingScore ?? this.writingScore,
    speakingScore: speakingScore ?? this.speakingScore,
    totalScore: totalScore ?? this.totalScore,
    passed: passed ?? this.passed,
    details: details.present ? details.value : this.details,
  );
  ExamResult copyWithCompanion(ExamResultsCompanion data) {
    return ExamResult(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      readingScore: data.readingScore.present
          ? data.readingScore.value
          : this.readingScore,
      listeningScore: data.listeningScore.present
          ? data.listeningScore.value
          : this.listeningScore,
      writingScore: data.writingScore.present
          ? data.writingScore.value
          : this.writingScore,
      speakingScore: data.speakingScore.present
          ? data.speakingScore.value
          : this.speakingScore,
      totalScore: data.totalScore.present
          ? data.totalScore.value
          : this.totalScore,
      passed: data.passed.present ? data.passed.value : this.passed,
      details: data.details.present ? data.details.value : this.details,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamResult(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('takenAt: $takenAt, ')
          ..write('readingScore: $readingScore, ')
          ..write('listeningScore: $listeningScore, ')
          ..write('writingScore: $writingScore, ')
          ..write('speakingScore: $speakingScore, ')
          ..write('totalScore: $totalScore, ')
          ..write('passed: $passed, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    level,
    takenAt,
    readingScore,
    listeningScore,
    writingScore,
    speakingScore,
    totalScore,
    passed,
    details,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamResult &&
          other.id == this.id &&
          other.level == this.level &&
          other.takenAt == this.takenAt &&
          other.readingScore == this.readingScore &&
          other.listeningScore == this.listeningScore &&
          other.writingScore == this.writingScore &&
          other.speakingScore == this.speakingScore &&
          other.totalScore == this.totalScore &&
          other.passed == this.passed &&
          other.details == this.details);
}

class ExamResultsCompanion extends UpdateCompanion<ExamResult> {
  final Value<int> id;
  final Value<String> level;
  final Value<DateTime> takenAt;
  final Value<int> readingScore;
  final Value<int> listeningScore;
  final Value<int> writingScore;
  final Value<int> speakingScore;
  final Value<int> totalScore;
  final Value<bool> passed;
  final Value<String?> details;
  const ExamResultsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.readingScore = const Value.absent(),
    this.listeningScore = const Value.absent(),
    this.writingScore = const Value.absent(),
    this.speakingScore = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.passed = const Value.absent(),
    this.details = const Value.absent(),
  });
  ExamResultsCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    this.takenAt = const Value.absent(),
    this.readingScore = const Value.absent(),
    this.listeningScore = const Value.absent(),
    this.writingScore = const Value.absent(),
    this.speakingScore = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.passed = const Value.absent(),
    this.details = const Value.absent(),
  }) : level = Value(level);
  static Insertable<ExamResult> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<DateTime>? takenAt,
    Expression<int>? readingScore,
    Expression<int>? listeningScore,
    Expression<int>? writingScore,
    Expression<int>? speakingScore,
    Expression<int>? totalScore,
    Expression<bool>? passed,
    Expression<String>? details,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (takenAt != null) 'taken_at': takenAt,
      if (readingScore != null) 'reading_score': readingScore,
      if (listeningScore != null) 'listening_score': listeningScore,
      if (writingScore != null) 'writing_score': writingScore,
      if (speakingScore != null) 'speaking_score': speakingScore,
      if (totalScore != null) 'total_score': totalScore,
      if (passed != null) 'passed': passed,
      if (details != null) 'details': details,
    });
  }

  ExamResultsCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<DateTime>? takenAt,
    Value<int>? readingScore,
    Value<int>? listeningScore,
    Value<int>? writingScore,
    Value<int>? speakingScore,
    Value<int>? totalScore,
    Value<bool>? passed,
    Value<String?>? details,
  }) {
    return ExamResultsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      takenAt: takenAt ?? this.takenAt,
      readingScore: readingScore ?? this.readingScore,
      listeningScore: listeningScore ?? this.listeningScore,
      writingScore: writingScore ?? this.writingScore,
      speakingScore: speakingScore ?? this.speakingScore,
      totalScore: totalScore ?? this.totalScore,
      passed: passed ?? this.passed,
      details: details ?? this.details,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (readingScore.present) {
      map['reading_score'] = Variable<int>(readingScore.value);
    }
    if (listeningScore.present) {
      map['listening_score'] = Variable<int>(listeningScore.value);
    }
    if (writingScore.present) {
      map['writing_score'] = Variable<int>(writingScore.value);
    }
    if (speakingScore.present) {
      map['speaking_score'] = Variable<int>(speakingScore.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<int>(totalScore.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamResultsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('takenAt: $takenAt, ')
          ..write('readingScore: $readingScore, ')
          ..write('listeningScore: $listeningScore, ')
          ..write('writingScore: $writingScore, ')
          ..write('speakingScore: $speakingScore, ')
          ..write('totalScore: $totalScore, ')
          ..write('passed: $passed, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }
}

class $UserProgressTable extends UserProgress
    with TableInfo<$UserProgressTable, UserProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class UserProgressData extends DataClass
    implements Insertable<UserProgressData> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const UserProgressData({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProgressData copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => UserProgressData(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProgressData copyWithCompanion(UserProgressCompanion data) {
    return UserProgressData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProgressCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProgressCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserProgressData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProgressCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProgressCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EarnedBadgesTable extends EarnedBadges
    with TableInfo<$EarnedBadgesTable, EarnedBadge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EarnedBadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _badgeIdMeta = const VerificationMeta(
    'badgeId',
  );
  @override
  late final GeneratedColumn<String> badgeId = GeneratedColumn<String>(
    'badge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedAtMeta = const VerificationMeta(
    'earnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
    'earned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [badgeId, earnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'earned_badges';
  @override
  VerificationContext validateIntegrity(
    Insertable<EarnedBadge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('badge_id')) {
      context.handle(
        _badgeIdMeta,
        badgeId.isAcceptableOrUnknown(data['badge_id']!, _badgeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeIdMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(
        _earnedAtMeta,
        earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {badgeId};
  @override
  EarnedBadge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EarnedBadge(
      badgeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_id'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earned_at'],
      )!,
    );
  }

  @override
  $EarnedBadgesTable createAlias(String alias) {
    return $EarnedBadgesTable(attachedDatabase, alias);
  }
}

class EarnedBadge extends DataClass implements Insertable<EarnedBadge> {
  final String badgeId;
  final DateTime earnedAt;
  const EarnedBadge({required this.badgeId, required this.earnedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['badge_id'] = Variable<String>(badgeId);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    return map;
  }

  EarnedBadgesCompanion toCompanion(bool nullToAbsent) {
    return EarnedBadgesCompanion(
      badgeId: Value(badgeId),
      earnedAt: Value(earnedAt),
    );
  }

  factory EarnedBadge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EarnedBadge(
      badgeId: serializer.fromJson<String>(json['badgeId']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'badgeId': serializer.toJson<String>(badgeId),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
    };
  }

  EarnedBadge copyWith({String? badgeId, DateTime? earnedAt}) => EarnedBadge(
    badgeId: badgeId ?? this.badgeId,
    earnedAt: earnedAt ?? this.earnedAt,
  );
  EarnedBadge copyWithCompanion(EarnedBadgesCompanion data) {
    return EarnedBadge(
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EarnedBadge(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(badgeId, earnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EarnedBadge &&
          other.badgeId == this.badgeId &&
          other.earnedAt == this.earnedAt);
}

class EarnedBadgesCompanion extends UpdateCompanion<EarnedBadge> {
  final Value<String> badgeId;
  final Value<DateTime> earnedAt;
  final Value<int> rowid;
  const EarnedBadgesCompanion({
    this.badgeId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EarnedBadgesCompanion.insert({
    required String badgeId,
    this.earnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : badgeId = Value(badgeId);
  static Insertable<EarnedBadge> custom({
    Expression<String>? badgeId,
    Expression<DateTime>? earnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (badgeId != null) 'badge_id': badgeId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EarnedBadgesCompanion copyWith({
    Value<String>? badgeId,
    Value<DateTime>? earnedAt,
    Value<int>? rowid,
  }) {
    return EarnedBadgesCompanion(
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EarnedBadgesCompanion(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonProgressTable extends LessonProgress
    with TableInfo<$LessonProgressTable, LessonProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<int> unitId = GeneratedColumn<int>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<double> bestScore = GeneratedColumn<double>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptedMeta = const VerificationMeta(
    'lastAttempted',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttempted =
      GeneratedColumn<DateTime>(
        'last_attempted',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    lessonId,
    unitId,
    isCompleted,
    bestScore,
    attempts,
    lastAttempted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempted')) {
      context.handle(
        _lastAttemptedMeta,
        lastAttempted.isAcceptableOrUnknown(
          data['last_attempted']!,
          _lastAttemptedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  LessonProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressData(
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_id'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_score'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttempted: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempted'],
      ),
    );
  }

  @override
  $LessonProgressTable createAlias(String alias) {
    return $LessonProgressTable(attachedDatabase, alias);
  }
}

class LessonProgressData extends DataClass
    implements Insertable<LessonProgressData> {
  final int lessonId;
  final int unitId;
  final bool isCompleted;
  final double bestScore;
  final int attempts;
  final DateTime? lastAttempted;
  const LessonProgressData({
    required this.lessonId,
    required this.unitId,
    required this.isCompleted,
    required this.bestScore,
    required this.attempts,
    this.lastAttempted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<int>(lessonId);
    map['unit_id'] = Variable<int>(unitId);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['best_score'] = Variable<double>(bestScore);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttempted != null) {
      map['last_attempted'] = Variable<DateTime>(lastAttempted);
    }
    return map;
  }

  LessonProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressCompanion(
      lessonId: Value(lessonId),
      unitId: Value(unitId),
      isCompleted: Value(isCompleted),
      bestScore: Value(bestScore),
      attempts: Value(attempts),
      lastAttempted: lastAttempted == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempted),
    );
  }

  factory LessonProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressData(
      lessonId: serializer.fromJson<int>(json['lessonId']),
      unitId: serializer.fromJson<int>(json['unitId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      bestScore: serializer.fromJson<double>(json['bestScore']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttempted: serializer.fromJson<DateTime?>(json['lastAttempted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<int>(lessonId),
      'unitId': serializer.toJson<int>(unitId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'bestScore': serializer.toJson<double>(bestScore),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttempted': serializer.toJson<DateTime?>(lastAttempted),
    };
  }

  LessonProgressData copyWith({
    int? lessonId,
    int? unitId,
    bool? isCompleted,
    double? bestScore,
    int? attempts,
    Value<DateTime?> lastAttempted = const Value.absent(),
  }) => LessonProgressData(
    lessonId: lessonId ?? this.lessonId,
    unitId: unitId ?? this.unitId,
    isCompleted: isCompleted ?? this.isCompleted,
    bestScore: bestScore ?? this.bestScore,
    attempts: attempts ?? this.attempts,
    lastAttempted: lastAttempted.present
        ? lastAttempted.value
        : this.lastAttempted,
  );
  LessonProgressData copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressData(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttempted: data.lastAttempted.present
          ? data.lastAttempted.value
          : this.lastAttempted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressData(')
          ..write('lessonId: $lessonId, ')
          ..write('unitId: $unitId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('bestScore: $bestScore, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttempted: $lastAttempted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lessonId,
    unitId,
    isCompleted,
    bestScore,
    attempts,
    lastAttempted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressData &&
          other.lessonId == this.lessonId &&
          other.unitId == this.unitId &&
          other.isCompleted == this.isCompleted &&
          other.bestScore == this.bestScore &&
          other.attempts == this.attempts &&
          other.lastAttempted == this.lastAttempted);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressData> {
  final Value<int> lessonId;
  final Value<int> unitId;
  final Value<bool> isCompleted;
  final Value<double> bestScore;
  final Value<int> attempts;
  final Value<DateTime?> lastAttempted;
  const LessonProgressCompanion({
    this.lessonId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttempted = const Value.absent(),
  });
  LessonProgressCompanion.insert({
    this.lessonId = const Value.absent(),
    required int unitId,
    this.isCompleted = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttempted = const Value.absent(),
  }) : unitId = Value(unitId);
  static Insertable<LessonProgressData> custom({
    Expression<int>? lessonId,
    Expression<int>? unitId,
    Expression<bool>? isCompleted,
    Expression<double>? bestScore,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttempted,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (unitId != null) 'unit_id': unitId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (bestScore != null) 'best_score': bestScore,
      if (attempts != null) 'attempts': attempts,
      if (lastAttempted != null) 'last_attempted': lastAttempted,
    });
  }

  LessonProgressCompanion copyWith({
    Value<int>? lessonId,
    Value<int>? unitId,
    Value<bool>? isCompleted,
    Value<double>? bestScore,
    Value<int>? attempts,
    Value<DateTime?>? lastAttempted,
  }) {
    return LessonProgressCompanion(
      lessonId: lessonId ?? this.lessonId,
      unitId: unitId ?? this.unitId,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
      attempts: attempts ?? this.attempts,
      lastAttempted: lastAttempted ?? this.lastAttempted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<int>(unitId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<double>(bestScore.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttempted.present) {
      map['last_attempted'] = Variable<DateTime>(lastAttempted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('unitId: $unitId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('bestScore: $bestScore, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttempted: $lastAttempted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $SrsCardsTable srsCards = $SrsCardsTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $GrammarRulesTable grammarRules = $GrammarRulesTable(this);
  late final $ExamResultsTable examResults = $ExamResultsTable(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final $EarnedBadgesTable earnedBadges = $EarnedBadgesTable(this);
  late final $LessonProgressTable lessonProgress = $LessonProgressTable(this);
  late final CurriculumDao curriculumDao = CurriculumDao(this as AppDatabase);
  late final VocabularyDao vocabularyDao = VocabularyDao(this as AppDatabase);
  late final ConversationDao conversationDao = ConversationDao(
    this as AppDatabase,
  );
  late final ProgressDao progressDao = ProgressDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    units,
    lessons,
    exercises,
    flashcards,
    srsCards,
    conversations,
    chatMessages,
    grammarRules,
    examResults,
    userProgress,
    earnedBadges,
    lessonProgress,
  ];
}

typedef $$UnitsTableCreateCompanionBuilder =
    UnitsCompanion Function({
      Value<int> id,
      required String title,
      required String description,
      required String phase,
      required int orderIndex,
      Value<String> grammarTags,
      Value<bool> isExamPrep,
      Value<int?> lessonCount,
    });
typedef $$UnitsTableUpdateCompanionBuilder =
    UnitsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> description,
      Value<String> phase,
      Value<int> orderIndex,
      Value<String> grammarTags,
      Value<bool> isExamPrep,
      Value<int?> lessonCount,
    });

final class $$UnitsTableReferences
    extends BaseReferences<_$AppDatabase, $UnitsTable, Unit> {
  $$UnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LessonsTable, List<Lesson>> _lessonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.lessons,
    aliasName: $_aliasNameGenerator(db.units.id, db.lessons.unitId),
  );

  $$LessonsTableProcessedTableManager get lessonsRefs {
    final manager = $$LessonsTableTableManager(
      $_db,
      $_db.lessons,
    ).filter((f) => f.unitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lessonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: $_aliasNameGenerator(db.units.id, db.flashcards.unitId),
  );

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.unitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GrammarRulesTable, List<GrammarRule>>
  _grammarRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grammarRules,
    aliasName: $_aliasNameGenerator(db.units.id, db.grammarRules.unitId),
  );

  $$GrammarRulesTableProcessedTableManager get grammarRulesRefs {
    final manager = $$GrammarRulesTableTableManager(
      $_db,
      $_db.grammarRules,
    ).filter((f) => f.unitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_grammarRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarTags => $composableBuilder(
    column: $table.grammarTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExamPrep => $composableBuilder(
    column: $table.isExamPrep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonCount => $composableBuilder(
    column: $table.lessonCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lessonsRefs(
    Expression<bool> Function($$LessonsTableFilterComposer f) f,
  ) {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableFilterComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($$FlashcardsTableFilterComposer f) f,
  ) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grammarRulesRefs(
    Expression<bool> Function($$GrammarRulesTableFilterComposer f) f,
  ) {
    final $$GrammarRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarRules,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarRulesTableFilterComposer(
            $db: $db,
            $table: $db.grammarRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarTags => $composableBuilder(
    column: $table.grammarTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExamPrep => $composableBuilder(
    column: $table.isExamPrep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonCount => $composableBuilder(
    column: $table.lessonCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grammarTags => $composableBuilder(
    column: $table.grammarTags,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExamPrep => $composableBuilder(
    column: $table.isExamPrep,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lessonCount => $composableBuilder(
    column: $table.lessonCount,
    builder: (column) => column,
  );

  Expression<T> lessonsRefs<T extends Object>(
    Expression<T> Function($$LessonsTableAnnotationComposer a) f,
  ) {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableAnnotationComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($$FlashcardsTableAnnotationComposer a) f,
  ) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> grammarRulesRefs<T extends Object>(
    Expression<T> Function($$GrammarRulesTableAnnotationComposer a) f,
  ) {
    final $$GrammarRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarRules,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitsTable,
          Unit,
          $$UnitsTableFilterComposer,
          $$UnitsTableOrderingComposer,
          $$UnitsTableAnnotationComposer,
          $$UnitsTableCreateCompanionBuilder,
          $$UnitsTableUpdateCompanionBuilder,
          (Unit, $$UnitsTableReferences),
          Unit,
          PrefetchHooks Function({
            bool lessonsRefs,
            bool flashcardsRefs,
            bool grammarRulesRefs,
          })
        > {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> grammarTags = const Value.absent(),
                Value<bool> isExamPrep = const Value.absent(),
                Value<int?> lessonCount = const Value.absent(),
              }) => UnitsCompanion(
                id: id,
                title: title,
                description: description,
                phase: phase,
                orderIndex: orderIndex,
                grammarTags: grammarTags,
                isExamPrep: isExamPrep,
                lessonCount: lessonCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String description,
                required String phase,
                required int orderIndex,
                Value<String> grammarTags = const Value.absent(),
                Value<bool> isExamPrep = const Value.absent(),
                Value<int?> lessonCount = const Value.absent(),
              }) => UnitsCompanion.insert(
                id: id,
                title: title,
                description: description,
                phase: phase,
                orderIndex: orderIndex,
                grammarTags: grammarTags,
                isExamPrep: isExamPrep,
                lessonCount: lessonCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UnitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                lessonsRefs = false,
                flashcardsRefs = false,
                grammarRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lessonsRefs) db.lessons,
                    if (flashcardsRefs) db.flashcards,
                    if (grammarRulesRefs) db.grammarRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lessonsRefs)
                        await $_getPrefetchedData<Unit, $UnitsTable, Lesson>(
                          currentTable: table,
                          referencedTable: $$UnitsTableReferences
                              ._lessonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitsTableReferences(db, table, p0).lessonsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.unitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (flashcardsRefs)
                        await $_getPrefetchedData<Unit, $UnitsTable, Flashcard>(
                          currentTable: table,
                          referencedTable: $$UnitsTableReferences
                              ._flashcardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).flashcardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.unitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grammarRulesRefs)
                        await $_getPrefetchedData<
                          Unit,
                          $UnitsTable,
                          GrammarRule
                        >(
                          currentTable: table,
                          referencedTable: $$UnitsTableReferences
                              ._grammarRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).grammarRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.unitId == item.id,
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

typedef $$UnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitsTable,
      Unit,
      $$UnitsTableFilterComposer,
      $$UnitsTableOrderingComposer,
      $$UnitsTableAnnotationComposer,
      $$UnitsTableCreateCompanionBuilder,
      $$UnitsTableUpdateCompanionBuilder,
      (Unit, $$UnitsTableReferences),
      Unit,
      PrefetchHooks Function({
        bool lessonsRefs,
        bool flashcardsRefs,
        bool grammarRulesRefs,
      })
    >;
typedef $$LessonsTableCreateCompanionBuilder =
    LessonsCompanion Function({
      Value<int> id,
      required int unitId,
      required int orderInUnit,
      required String title,
      required String description,
      Value<int> durationMinutes,
      Value<String> lessonType,
      Value<bool> isReview,
    });
typedef $$LessonsTableUpdateCompanionBuilder =
    LessonsCompanion Function({
      Value<int> id,
      Value<int> unitId,
      Value<int> orderInUnit,
      Value<String> title,
      Value<String> description,
      Value<int> durationMinutes,
      Value<String> lessonType,
      Value<bool> isReview,
    });

final class $$LessonsTableReferences
    extends BaseReferences<_$AppDatabase, $LessonsTable, Lesson> {
  $$LessonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UnitsTable _unitIdTable(_$AppDatabase db) => db.units.createAlias(
    $_aliasNameGenerator(db.lessons.unitId, db.units.id),
  );

  $$UnitsTableProcessedTableManager get unitId {
    final $_column = $_itemColumn<int>('unit_id')!;

    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: $_aliasNameGenerator(db.lessons.id, db.exercises.lessonId),
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.lessonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: $_aliasNameGenerator(db.lessons.id, db.flashcards.lessonId),
  );

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.lessonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderInUnit => $composableBuilder(
    column: $table.orderInUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonType => $composableBuilder(
    column: $table.lessonType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReview => $composableBuilder(
    column: $table.isReview,
    builder: (column) => ColumnFilters(column),
  );

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($$FlashcardsTableFilterComposer f) f,
  ) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderInUnit => $composableBuilder(
    column: $table.orderInUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonType => $composableBuilder(
    column: $table.lessonType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReview => $composableBuilder(
    column: $table.isReview,
    builder: (column) => ColumnOrderings(column),
  );

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableOrderingComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderInUnit => $composableBuilder(
    column: $table.orderInUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lessonType => $composableBuilder(
    column: $table.lessonType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReview =>
      $composableBuilder(column: $table.isReview, builder: (column) => column);

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($$FlashcardsTableAnnotationComposer a) f,
  ) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonsTable,
          Lesson,
          $$LessonsTableFilterComposer,
          $$LessonsTableOrderingComposer,
          $$LessonsTableAnnotationComposer,
          $$LessonsTableCreateCompanionBuilder,
          $$LessonsTableUpdateCompanionBuilder,
          (Lesson, $$LessonsTableReferences),
          Lesson,
          PrefetchHooks Function({
            bool unitId,
            bool exercisesRefs,
            bool flashcardsRefs,
          })
        > {
  $$LessonsTableTableManager(_$AppDatabase db, $LessonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> unitId = const Value.absent(),
                Value<int> orderInUnit = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> lessonType = const Value.absent(),
                Value<bool> isReview = const Value.absent(),
              }) => LessonsCompanion(
                id: id,
                unitId: unitId,
                orderInUnit: orderInUnit,
                title: title,
                description: description,
                durationMinutes: durationMinutes,
                lessonType: lessonType,
                isReview: isReview,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int unitId,
                required int orderInUnit,
                required String title,
                required String description,
                Value<int> durationMinutes = const Value.absent(),
                Value<String> lessonType = const Value.absent(),
                Value<bool> isReview = const Value.absent(),
              }) => LessonsCompanion.insert(
                id: id,
                unitId: unitId,
                orderInUnit: orderInUnit,
                title: title,
                description: description,
                durationMinutes: durationMinutes,
                lessonType: lessonType,
                isReview: isReview,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LessonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                unitId = false,
                exercisesRefs = false,
                flashcardsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exercisesRefs) db.exercises,
                    if (flashcardsRefs) db.flashcards,
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
                        if (unitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.unitId,
                                    referencedTable: $$LessonsTableReferences
                                        ._unitIdTable(db),
                                    referencedColumn: $$LessonsTableReferences
                                        ._unitIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exercisesRefs)
                        await $_getPrefetchedData<
                          Lesson,
                          $LessonsTable,
                          Exercise
                        >(
                          currentTable: table,
                          referencedTable: $$LessonsTableReferences
                              ._exercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LessonsTableReferences(
                                db,
                                table,
                                p0,
                              ).exercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lessonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (flashcardsRefs)
                        await $_getPrefetchedData<
                          Lesson,
                          $LessonsTable,
                          Flashcard
                        >(
                          currentTable: table,
                          referencedTable: $$LessonsTableReferences
                              ._flashcardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LessonsTableReferences(
                                db,
                                table,
                                p0,
                              ).flashcardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lessonId == item.id,
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

typedef $$LessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonsTable,
      Lesson,
      $$LessonsTableFilterComposer,
      $$LessonsTableOrderingComposer,
      $$LessonsTableAnnotationComposer,
      $$LessonsTableCreateCompanionBuilder,
      $$LessonsTableUpdateCompanionBuilder,
      (Lesson, $$LessonsTableReferences),
      Lesson,
      PrefetchHooks Function({
        bool unitId,
        bool exercisesRefs,
        bool flashcardsRefs,
      })
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required int lessonId,
      required String type,
      required String prompt,
      required String data,
      Value<String?> answerKey,
      Value<String?> grammarRuleId,
      Value<int> xpReward,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<int> lessonId,
      Value<String> type,
      Value<String> prompt,
      Value<String> data,
      Value<String?> answerKey,
      Value<String?> grammarRuleId,
      Value<int> xpReward,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LessonsTable _lessonIdTable(_$AppDatabase db) => db.lessons
      .createAlias($_aliasNameGenerator(db.exercises.lessonId, db.lessons.id));

  $$LessonsTableProcessedTableManager get lessonId {
    final $_column = $_itemColumn<int>('lesson_id')!;

    final manager = $$LessonsTableTableManager(
      $_db,
      $_db.lessons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerKey => $composableBuilder(
    column: $table.answerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarRuleId => $composableBuilder(
    column: $table.grammarRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  $$LessonsTableFilterComposer get lessonId {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableFilterComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerKey => $composableBuilder(
    column: $table.answerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarRuleId => $composableBuilder(
    column: $table.grammarRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  $$LessonsTableOrderingComposer get lessonId {
    final $$LessonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableOrderingComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get answerKey =>
      $composableBuilder(column: $table.answerKey, builder: (column) => column);

  GeneratedColumn<String> get grammarRuleId => $composableBuilder(
    column: $table.grammarRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  $$LessonsTableAnnotationComposer get lessonId {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableAnnotationComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({bool lessonId})
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lessonId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<String?> answerKey = const Value.absent(),
                Value<String?> grammarRuleId = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                lessonId: lessonId,
                type: type,
                prompt: prompt,
                data: data,
                answerKey: answerKey,
                grammarRuleId: grammarRuleId,
                xpReward: xpReward,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lessonId,
                required String type,
                required String prompt,
                required String data,
                Value<String?> answerKey = const Value.absent(),
                Value<String?> grammarRuleId = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                lessonId: lessonId,
                type: type,
                prompt: prompt,
                data: data,
                answerKey: answerKey,
                grammarRuleId: grammarRuleId,
                xpReward: xpReward,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lessonId = false}) {
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
                    if (lessonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lessonId,
                                referencedTable: $$ExercisesTableReferences
                                    ._lessonIdTable(db),
                                referencedColumn: $$ExercisesTableReferences
                                    ._lessonIdTable(db)
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

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({bool lessonId})
    >;
typedef $$FlashcardsTableCreateCompanionBuilder =
    FlashcardsCompanion Function({
      Value<int> id,
      required String wordCz,
      required String wordEn,
      Value<String?> ipa,
      Value<String?> gender,
      Value<String?> caseInfo,
      Value<String?> audioHash,
      Value<String?> imagePath,
      Value<String?> exampleCz,
      Value<String?> exampleEn,
      Value<int?> unitId,
      Value<int?> lessonId,
    });
typedef $$FlashcardsTableUpdateCompanionBuilder =
    FlashcardsCompanion Function({
      Value<int> id,
      Value<String> wordCz,
      Value<String> wordEn,
      Value<String?> ipa,
      Value<String?> gender,
      Value<String?> caseInfo,
      Value<String?> audioHash,
      Value<String?> imagePath,
      Value<String?> exampleCz,
      Value<String?> exampleEn,
      Value<int?> unitId,
      Value<int?> lessonId,
    });

final class $$FlashcardsTableReferences
    extends BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UnitsTable _unitIdTable(_$AppDatabase db) => db.units.createAlias(
    $_aliasNameGenerator(db.flashcards.unitId, db.units.id),
  );

  $$UnitsTableProcessedTableManager? get unitId {
    final $_column = $_itemColumn<int>('unit_id');
    if ($_column == null) return null;
    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LessonsTable _lessonIdTable(_$AppDatabase db) => db.lessons
      .createAlias($_aliasNameGenerator(db.flashcards.lessonId, db.lessons.id));

  $$LessonsTableProcessedTableManager? get lessonId {
    final $_column = $_itemColumn<int>('lesson_id');
    if ($_column == null) return null;
    final manager = $$LessonsTableTableManager(
      $_db,
      $_db.lessons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SrsCardsTable, List<SrsCard>> _srsCardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.srsCards,
    aliasName: $_aliasNameGenerator(db.flashcards.id, db.srsCards.flashcardId),
  );

  $$SrsCardsTableProcessedTableManager get srsCardsRefs {
    final manager = $$SrsCardsTableTableManager(
      $_db,
      $_db.srsCards,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_srsCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordCz => $composableBuilder(
    column: $table.wordCz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordEn => $composableBuilder(
    column: $table.wordEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipa => $composableBuilder(
    column: $table.ipa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseInfo => $composableBuilder(
    column: $table.caseInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioHash => $composableBuilder(
    column: $table.audioHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleCz => $composableBuilder(
    column: $table.exampleCz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnFilters(column),
  );

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LessonsTableFilterComposer get lessonId {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableFilterComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> srsCardsRefs(
    Expression<bool> Function($$SrsCardsTableFilterComposer f) f,
  ) {
    final $$SrsCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.srsCards,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SrsCardsTableFilterComposer(
            $db: $db,
            $table: $db.srsCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordCz => $composableBuilder(
    column: $table.wordCz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordEn => $composableBuilder(
    column: $table.wordEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipa => $composableBuilder(
    column: $table.ipa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseInfo => $composableBuilder(
    column: $table.caseInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioHash => $composableBuilder(
    column: $table.audioHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleCz => $composableBuilder(
    column: $table.exampleCz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableOrderingComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LessonsTableOrderingComposer get lessonId {
    final $$LessonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableOrderingComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wordCz =>
      $composableBuilder(column: $table.wordCz, builder: (column) => column);

  GeneratedColumn<String> get wordEn =>
      $composableBuilder(column: $table.wordEn, builder: (column) => column);

  GeneratedColumn<String> get ipa =>
      $composableBuilder(column: $table.ipa, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get caseInfo =>
      $composableBuilder(column: $table.caseInfo, builder: (column) => column);

  GeneratedColumn<String> get audioHash =>
      $composableBuilder(column: $table.audioHash, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get exampleCz =>
      $composableBuilder(column: $table.exampleCz, builder: (column) => column);

  GeneratedColumn<String> get exampleEn =>
      $composableBuilder(column: $table.exampleEn, builder: (column) => column);

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LessonsTableAnnotationComposer get lessonId {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableAnnotationComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> srsCardsRefs<T extends Object>(
    Expression<T> Function($$SrsCardsTableAnnotationComposer a) f,
  ) {
    final $$SrsCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.srsCards,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SrsCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.srsCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardsTable,
          Flashcard,
          $$FlashcardsTableFilterComposer,
          $$FlashcardsTableOrderingComposer,
          $$FlashcardsTableAnnotationComposer,
          $$FlashcardsTableCreateCompanionBuilder,
          $$FlashcardsTableUpdateCompanionBuilder,
          (Flashcard, $$FlashcardsTableReferences),
          Flashcard,
          PrefetchHooks Function({
            bool unitId,
            bool lessonId,
            bool srsCardsRefs,
          })
        > {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> wordCz = const Value.absent(),
                Value<String> wordEn = const Value.absent(),
                Value<String?> ipa = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> caseInfo = const Value.absent(),
                Value<String?> audioHash = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> exampleCz = const Value.absent(),
                Value<String?> exampleEn = const Value.absent(),
                Value<int?> unitId = const Value.absent(),
                Value<int?> lessonId = const Value.absent(),
              }) => FlashcardsCompanion(
                id: id,
                wordCz: wordCz,
                wordEn: wordEn,
                ipa: ipa,
                gender: gender,
                caseInfo: caseInfo,
                audioHash: audioHash,
                imagePath: imagePath,
                exampleCz: exampleCz,
                exampleEn: exampleEn,
                unitId: unitId,
                lessonId: lessonId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String wordCz,
                required String wordEn,
                Value<String?> ipa = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> caseInfo = const Value.absent(),
                Value<String?> audioHash = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> exampleCz = const Value.absent(),
                Value<String?> exampleEn = const Value.absent(),
                Value<int?> unitId = const Value.absent(),
                Value<int?> lessonId = const Value.absent(),
              }) => FlashcardsCompanion.insert(
                id: id,
                wordCz: wordCz,
                wordEn: wordEn,
                ipa: ipa,
                gender: gender,
                caseInfo: caseInfo,
                audioHash: audioHash,
                imagePath: imagePath,
                exampleCz: exampleCz,
                exampleEn: exampleEn,
                unitId: unitId,
                lessonId: lessonId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FlashcardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({unitId = false, lessonId = false, srsCardsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (srsCardsRefs) db.srsCards],
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
                        if (unitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.unitId,
                                    referencedTable: $$FlashcardsTableReferences
                                        ._unitIdTable(db),
                                    referencedColumn:
                                        $$FlashcardsTableReferences
                                            ._unitIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (lessonId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.lessonId,
                                    referencedTable: $$FlashcardsTableReferences
                                        ._lessonIdTable(db),
                                    referencedColumn:
                                        $$FlashcardsTableReferences
                                            ._lessonIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (srsCardsRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          $FlashcardsTable,
                          SrsCard
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._srsCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).srsCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
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

typedef $$FlashcardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardsTable,
      Flashcard,
      $$FlashcardsTableFilterComposer,
      $$FlashcardsTableOrderingComposer,
      $$FlashcardsTableAnnotationComposer,
      $$FlashcardsTableCreateCompanionBuilder,
      $$FlashcardsTableUpdateCompanionBuilder,
      (Flashcard, $$FlashcardsTableReferences),
      Flashcard,
      PrefetchHooks Function({bool unitId, bool lessonId, bool srsCardsRefs})
    >;
typedef $$SrsCardsTableCreateCompanionBuilder =
    SrsCardsCompanion Function({
      Value<int> id,
      required String cardType,
      Value<int?> flashcardId,
      Value<String?> grammarPatternKey,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime> due,
      Value<int> reps,
      Value<String> state,
      Value<DateTime?> lastReviewed,
    });
typedef $$SrsCardsTableUpdateCompanionBuilder =
    SrsCardsCompanion Function({
      Value<int> id,
      Value<String> cardType,
      Value<int?> flashcardId,
      Value<String?> grammarPatternKey,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime> due,
      Value<int> reps,
      Value<String> state,
      Value<DateTime?> lastReviewed,
    });

final class $$SrsCardsTableReferences
    extends BaseReferences<_$AppDatabase, $SrsCardsTable, SrsCard> {
  $$SrsCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FlashcardsTable _flashcardIdTable(_$AppDatabase db) =>
      db.flashcards.createAlias(
        $_aliasNameGenerator(db.srsCards.flashcardId, db.flashcards.id),
      );

  $$FlashcardsTableProcessedTableManager? get flashcardId {
    final $_column = $_itemColumn<int>('flashcard_id');
    if ($_column == null) return null;
    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SrsCardsTableFilterComposer
    extends Composer<_$AppDatabase, $SrsCardsTable> {
  $$SrsCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarPatternKey => $composableBuilder(
    column: $table.grammarPatternKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => ColumnFilters(column),
  );

  $$FlashcardsTableFilterComposer get flashcardId {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SrsCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $SrsCardsTable> {
  $$SrsCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarPatternKey => $composableBuilder(
    column: $table.grammarPatternKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  $$FlashcardsTableOrderingComposer get flashcardId {
    final $$FlashcardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SrsCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SrsCardsTable> {
  $$SrsCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<String> get grammarPatternKey => $composableBuilder(
    column: $table.grammarPatternKey,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => column,
  );

  $$FlashcardsTableAnnotationComposer get flashcardId {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SrsCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SrsCardsTable,
          SrsCard,
          $$SrsCardsTableFilterComposer,
          $$SrsCardsTableOrderingComposer,
          $$SrsCardsTableAnnotationComposer,
          $$SrsCardsTableCreateCompanionBuilder,
          $$SrsCardsTableUpdateCompanionBuilder,
          (SrsCard, $$SrsCardsTableReferences),
          SrsCard,
          PrefetchHooks Function({bool flashcardId})
        > {
  $$SrsCardsTableTableManager(_$AppDatabase db, $SrsCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SrsCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SrsCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SrsCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardType = const Value.absent(),
                Value<int?> flashcardId = const Value.absent(),
                Value<String?> grammarPatternKey = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> lastReviewed = const Value.absent(),
              }) => SrsCardsCompanion(
                id: id,
                cardType: cardType,
                flashcardId: flashcardId,
                grammarPatternKey: grammarPatternKey,
                stability: stability,
                difficulty: difficulty,
                due: due,
                reps: reps,
                state: state,
                lastReviewed: lastReviewed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardType,
                Value<int?> flashcardId = const Value.absent(),
                Value<String?> grammarPatternKey = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> lastReviewed = const Value.absent(),
              }) => SrsCardsCompanion.insert(
                id: id,
                cardType: cardType,
                flashcardId: flashcardId,
                grammarPatternKey: grammarPatternKey,
                stability: stability,
                difficulty: difficulty,
                due: due,
                reps: reps,
                state: state,
                lastReviewed: lastReviewed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SrsCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flashcardId = false}) {
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
                    if (flashcardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.flashcardId,
                                referencedTable: $$SrsCardsTableReferences
                                    ._flashcardIdTable(db),
                                referencedColumn: $$SrsCardsTableReferences
                                    ._flashcardIdTable(db)
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

typedef $$SrsCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SrsCardsTable,
      SrsCard,
      $$SrsCardsTableFilterComposer,
      $$SrsCardsTableOrderingComposer,
      $$SrsCardsTableAnnotationComposer,
      $$SrsCardsTableCreateCompanionBuilder,
      $$SrsCardsTableUpdateCompanionBuilder,
      (SrsCard, $$SrsCardsTableReferences),
      SrsCard,
      PrefetchHooks Function({bool flashcardId})
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      required String scenario,
      required String cefrLevel,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String> scenario,
      Value<String> cefrLevel,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: $_aliasNameGenerator(
      db.conversations.id,
      db.chatMessages.conversationId,
    ),
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
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

  ColumnFilters<String> get scenario => $composableBuilder(
    column: $table.scenario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cefrLevel => $composableBuilder(
    column: $table.cefrLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
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

  ColumnOrderings<String> get scenario => $composableBuilder(
    column: $table.scenario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cefrLevel => $composableBuilder(
    column: $table.cefrLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenario =>
      $composableBuilder(column: $table.scenario, builder: (column) => column);

  GeneratedColumn<String> get cefrLevel =>
      $composableBuilder(column: $table.cefrLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({bool chatMessagesRefs})
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scenario = const Value.absent(),
                Value<String> cefrLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                scenario: scenario,
                cefrLevel: cefrLevel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scenario,
                required String cefrLevel,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                scenario: scenario,
                cefrLevel: cefrLevel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatMessagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chatMessagesRefs) db.chatMessages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatMessagesRefs)
                    await $_getPrefetchedData<
                      Conversation,
                      $ConversationsTable,
                      ChatMessage
                    >(
                      currentTable: table,
                      referencedTable: $$ConversationsTableReferences
                          ._chatMessagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConversationsTableReferences(
                            db,
                            table,
                            p0,
                          ).chatMessagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.conversationId == item.id,
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

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({bool chatMessagesRefs})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required String conversationId,
      required String role,
      required String content,
      Value<String?> translation,
      Value<String?> corrections,
      Value<String?> newVocabulary,
      Value<String?> audioPath,
      Value<DateTime> createdAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<String?> translation,
      Value<String?> corrections,
      Value<String?> newVocabulary,
      Value<String?> audioPath,
      Value<DateTime> createdAt,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias(
        $_aliasNameGenerator(
          db.chatMessages.conversationId,
          db.conversations.id,
        ),
      );

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get corrections => $composableBuilder(
    column: $table.corrections,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newVocabulary => $composableBuilder(
    column: $table.newVocabulary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get corrections => $composableBuilder(
    column: $table.corrections,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newVocabulary => $composableBuilder(
    column: $table.newVocabulary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get corrections => $composableBuilder(
    column: $table.corrections,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newVocabulary => $composableBuilder(
    column: $table.newVocabulary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool conversationId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> corrections = const Value.absent(),
                Value<String?> newVocabulary = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                translation: translation,
                corrections: corrections,
                newVocabulary: newVocabulary,
                audioPath: audioPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conversationId,
                required String role,
                required String content,
                Value<String?> translation = const Value.absent(),
                Value<String?> corrections = const Value.absent(),
                Value<String?> newVocabulary = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                translation: translation,
                corrections: corrections,
                newVocabulary: newVocabulary,
                audioPath: audioPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
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
                    if (conversationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conversationId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._conversationIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._conversationIdTable(db)
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

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$GrammarRulesTableCreateCompanionBuilder =
    GrammarRulesCompanion Function({
      required String id,
      required String ruleName,
      required String pattern,
      required String explanation,
      Value<String?> caseAffected,
      Value<String> examples,
      Value<int?> unitId,
      Value<int> rowid,
    });
typedef $$GrammarRulesTableUpdateCompanionBuilder =
    GrammarRulesCompanion Function({
      Value<String> id,
      Value<String> ruleName,
      Value<String> pattern,
      Value<String> explanation,
      Value<String?> caseAffected,
      Value<String> examples,
      Value<int?> unitId,
      Value<int> rowid,
    });

final class $$GrammarRulesTableReferences
    extends BaseReferences<_$AppDatabase, $GrammarRulesTable, GrammarRule> {
  $$GrammarRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UnitsTable _unitIdTable(_$AppDatabase db) => db.units.createAlias(
    $_aliasNameGenerator(db.grammarRules.unitId, db.units.id),
  );

  $$UnitsTableProcessedTableManager? get unitId {
    final $_column = $_itemColumn<int>('unit_id');
    if ($_column == null) return null;
    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GrammarRulesTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarRulesTable> {
  $$GrammarRulesTableFilterComposer({
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

  ColumnFilters<String> get ruleName => $composableBuilder(
    column: $table.ruleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseAffected => $composableBuilder(
    column: $table.caseAffected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnFilters(column),
  );

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarRulesTable> {
  $$GrammarRulesTableOrderingComposer({
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

  ColumnOrderings<String> get ruleName => $composableBuilder(
    column: $table.ruleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseAffected => $composableBuilder(
    column: $table.caseAffected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnOrderings(column),
  );

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableOrderingComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarRulesTable> {
  $$GrammarRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleName =>
      $composableBuilder(column: $table.ruleName, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caseAffected => $composableBuilder(
    column: $table.caseAffected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarRulesTable,
          GrammarRule,
          $$GrammarRulesTableFilterComposer,
          $$GrammarRulesTableOrderingComposer,
          $$GrammarRulesTableAnnotationComposer,
          $$GrammarRulesTableCreateCompanionBuilder,
          $$GrammarRulesTableUpdateCompanionBuilder,
          (GrammarRule, $$GrammarRulesTableReferences),
          GrammarRule,
          PrefetchHooks Function({bool unitId})
        > {
  $$GrammarRulesTableTableManager(_$AppDatabase db, $GrammarRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ruleName = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String?> caseAffected = const Value.absent(),
                Value<String> examples = const Value.absent(),
                Value<int?> unitId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarRulesCompanion(
                id: id,
                ruleName: ruleName,
                pattern: pattern,
                explanation: explanation,
                caseAffected: caseAffected,
                examples: examples,
                unitId: unitId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ruleName,
                required String pattern,
                required String explanation,
                Value<String?> caseAffected = const Value.absent(),
                Value<String> examples = const Value.absent(),
                Value<int?> unitId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarRulesCompanion.insert(
                id: id,
                ruleName: ruleName,
                pattern: pattern,
                explanation: explanation,
                caseAffected: caseAffected,
                examples: examples,
                unitId: unitId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrammarRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({unitId = false}) {
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
                    if (unitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.unitId,
                                referencedTable: $$GrammarRulesTableReferences
                                    ._unitIdTable(db),
                                referencedColumn: $$GrammarRulesTableReferences
                                    ._unitIdTable(db)
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

typedef $$GrammarRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarRulesTable,
      GrammarRule,
      $$GrammarRulesTableFilterComposer,
      $$GrammarRulesTableOrderingComposer,
      $$GrammarRulesTableAnnotationComposer,
      $$GrammarRulesTableCreateCompanionBuilder,
      $$GrammarRulesTableUpdateCompanionBuilder,
      (GrammarRule, $$GrammarRulesTableReferences),
      GrammarRule,
      PrefetchHooks Function({bool unitId})
    >;
typedef $$ExamResultsTableCreateCompanionBuilder =
    ExamResultsCompanion Function({
      Value<int> id,
      required String level,
      Value<DateTime> takenAt,
      Value<int> readingScore,
      Value<int> listeningScore,
      Value<int> writingScore,
      Value<int> speakingScore,
      Value<int> totalScore,
      Value<bool> passed,
      Value<String?> details,
    });
typedef $$ExamResultsTableUpdateCompanionBuilder =
    ExamResultsCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<DateTime> takenAt,
      Value<int> readingScore,
      Value<int> listeningScore,
      Value<int> writingScore,
      Value<int> speakingScore,
      Value<int> totalScore,
      Value<bool> passed,
      Value<String?> details,
    });

class $$ExamResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamResultsTable> {
  $$ExamResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readingScore => $composableBuilder(
    column: $table.readingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listeningScore => $composableBuilder(
    column: $table.listeningScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get writingScore => $composableBuilder(
    column: $table.writingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speakingScore => $composableBuilder(
    column: $table.speakingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExamResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamResultsTable> {
  $$ExamResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readingScore => $composableBuilder(
    column: $table.readingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listeningScore => $composableBuilder(
    column: $table.listeningScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get writingScore => $composableBuilder(
    column: $table.writingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speakingScore => $composableBuilder(
    column: $table.speakingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamResultsTable> {
  $$ExamResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get readingScore => $composableBuilder(
    column: $table.readingScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get listeningScore => $composableBuilder(
    column: $table.listeningScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get writingScore => $composableBuilder(
    column: $table.writingScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speakingScore => $composableBuilder(
    column: $table.speakingScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);
}

class $$ExamResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamResultsTable,
          ExamResult,
          $$ExamResultsTableFilterComposer,
          $$ExamResultsTableOrderingComposer,
          $$ExamResultsTableAnnotationComposer,
          $$ExamResultsTableCreateCompanionBuilder,
          $$ExamResultsTableUpdateCompanionBuilder,
          (
            ExamResult,
            BaseReferences<_$AppDatabase, $ExamResultsTable, ExamResult>,
          ),
          ExamResult,
          PrefetchHooks Function()
        > {
  $$ExamResultsTableTableManager(_$AppDatabase db, $ExamResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<int> readingScore = const Value.absent(),
                Value<int> listeningScore = const Value.absent(),
                Value<int> writingScore = const Value.absent(),
                Value<int> speakingScore = const Value.absent(),
                Value<int> totalScore = const Value.absent(),
                Value<bool> passed = const Value.absent(),
                Value<String?> details = const Value.absent(),
              }) => ExamResultsCompanion(
                id: id,
                level: level,
                takenAt: takenAt,
                readingScore: readingScore,
                listeningScore: listeningScore,
                writingScore: writingScore,
                speakingScore: speakingScore,
                totalScore: totalScore,
                passed: passed,
                details: details,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                Value<DateTime> takenAt = const Value.absent(),
                Value<int> readingScore = const Value.absent(),
                Value<int> listeningScore = const Value.absent(),
                Value<int> writingScore = const Value.absent(),
                Value<int> speakingScore = const Value.absent(),
                Value<int> totalScore = const Value.absent(),
                Value<bool> passed = const Value.absent(),
                Value<String?> details = const Value.absent(),
              }) => ExamResultsCompanion.insert(
                id: id,
                level: level,
                takenAt: takenAt,
                readingScore: readingScore,
                listeningScore: listeningScore,
                writingScore: writingScore,
                speakingScore: speakingScore,
                totalScore: totalScore,
                passed: passed,
                details: details,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExamResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamResultsTable,
      ExamResult,
      $$ExamResultsTableFilterComposer,
      $$ExamResultsTableOrderingComposer,
      $$ExamResultsTableAnnotationComposer,
      $$ExamResultsTableCreateCompanionBuilder,
      $$ExamResultsTableUpdateCompanionBuilder,
      (
        ExamResult,
        BaseReferences<_$AppDatabase, $ExamResultsTable, ExamResult>,
      ),
      ExamResult,
      PrefetchHooks Function()
    >;
typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserProgressTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTable,
          UserProgressData,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (
            UserProgressData,
            BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
          ),
          UserProgressData,
          PrefetchHooks Function()
        > {
  $$UserProgressTableTableManager(_$AppDatabase db, $UserProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTable,
      UserProgressData,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (
        UserProgressData,
        BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
      ),
      UserProgressData,
      PrefetchHooks Function()
    >;
typedef $$EarnedBadgesTableCreateCompanionBuilder =
    EarnedBadgesCompanion Function({
      required String badgeId,
      Value<DateTime> earnedAt,
      Value<int> rowid,
    });
typedef $$EarnedBadgesTableUpdateCompanionBuilder =
    EarnedBadgesCompanion Function({
      Value<String> badgeId,
      Value<DateTime> earnedAt,
      Value<int> rowid,
    });

class $$EarnedBadgesTableFilterComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EarnedBadgesTableOrderingComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EarnedBadgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get badgeId =>
      $composableBuilder(column: $table.badgeId, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);
}

class $$EarnedBadgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EarnedBadgesTable,
          EarnedBadge,
          $$EarnedBadgesTableFilterComposer,
          $$EarnedBadgesTableOrderingComposer,
          $$EarnedBadgesTableAnnotationComposer,
          $$EarnedBadgesTableCreateCompanionBuilder,
          $$EarnedBadgesTableUpdateCompanionBuilder,
          (
            EarnedBadge,
            BaseReferences<_$AppDatabase, $EarnedBadgesTable, EarnedBadge>,
          ),
          EarnedBadge,
          PrefetchHooks Function()
        > {
  $$EarnedBadgesTableTableManager(_$AppDatabase db, $EarnedBadgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EarnedBadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EarnedBadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EarnedBadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> badgeId = const Value.absent(),
                Value<DateTime> earnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EarnedBadgesCompanion(
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String badgeId,
                Value<DateTime> earnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EarnedBadgesCompanion.insert(
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EarnedBadgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EarnedBadgesTable,
      EarnedBadge,
      $$EarnedBadgesTableFilterComposer,
      $$EarnedBadgesTableOrderingComposer,
      $$EarnedBadgesTableAnnotationComposer,
      $$EarnedBadgesTableCreateCompanionBuilder,
      $$EarnedBadgesTableUpdateCompanionBuilder,
      (
        EarnedBadge,
        BaseReferences<_$AppDatabase, $EarnedBadgesTable, EarnedBadge>,
      ),
      EarnedBadge,
      PrefetchHooks Function()
    >;
typedef $$LessonProgressTableCreateCompanionBuilder =
    LessonProgressCompanion Function({
      Value<int> lessonId,
      required int unitId,
      Value<bool> isCompleted,
      Value<double> bestScore,
      Value<int> attempts,
      Value<DateTime?> lastAttempted,
    });
typedef $$LessonProgressTableUpdateCompanionBuilder =
    LessonProgressCompanion Function({
      Value<int> lessonId,
      Value<int> unitId,
      Value<bool> isCompleted,
      Value<double> bestScore,
      Value<int> attempts,
      Value<DateTime?> lastAttempted,
    });

class $$LessonProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttempted => $composableBuilder(
    column: $table.lastAttempted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttempted => $composableBuilder(
    column: $table.lastAttempted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttempted => $composableBuilder(
    column: $table.lastAttempted,
    builder: (column) => column,
  );
}

class $$LessonProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressTable,
          LessonProgressData,
          $$LessonProgressTableFilterComposer,
          $$LessonProgressTableOrderingComposer,
          $$LessonProgressTableAnnotationComposer,
          $$LessonProgressTableCreateCompanionBuilder,
          $$LessonProgressTableUpdateCompanionBuilder,
          (
            LessonProgressData,
            BaseReferences<
              _$AppDatabase,
              $LessonProgressTable,
              LessonProgressData
            >,
          ),
          LessonProgressData,
          PrefetchHooks Function()
        > {
  $$LessonProgressTableTableManager(
    _$AppDatabase db,
    $LessonProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> lessonId = const Value.absent(),
                Value<int> unitId = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<double> bestScore = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttempted = const Value.absent(),
              }) => LessonProgressCompanion(
                lessonId: lessonId,
                unitId: unitId,
                isCompleted: isCompleted,
                bestScore: bestScore,
                attempts: attempts,
                lastAttempted: lastAttempted,
              ),
          createCompanionCallback:
              ({
                Value<int> lessonId = const Value.absent(),
                required int unitId,
                Value<bool> isCompleted = const Value.absent(),
                Value<double> bestScore = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttempted = const Value.absent(),
              }) => LessonProgressCompanion.insert(
                lessonId: lessonId,
                unitId: unitId,
                isCompleted: isCompleted,
                bestScore: bestScore,
                attempts: attempts,
                lastAttempted: lastAttempted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressTable,
      LessonProgressData,
      $$LessonProgressTableFilterComposer,
      $$LessonProgressTableOrderingComposer,
      $$LessonProgressTableAnnotationComposer,
      $$LessonProgressTableCreateCompanionBuilder,
      $$LessonProgressTableUpdateCompanionBuilder,
      (
        LessonProgressData,
        BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>,
      ),
      LessonProgressData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$SrsCardsTableTableManager get srsCards =>
      $$SrsCardsTableTableManager(_db, _db.srsCards);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$GrammarRulesTableTableManager get grammarRules =>
      $$GrammarRulesTableTableManager(_db, _db.grammarRules);
  $$ExamResultsTableTableManager get examResults =>
      $$ExamResultsTableTableManager(_db, _db.examResults);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$EarnedBadgesTableTableManager get earnedBadges =>
      $$EarnedBadgesTableTableManager(_db, _db.earnedBadges);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(_db, _db.lessonProgress);
}
