// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserTable extends User with TableInfo<$UserTable, UserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
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
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    name,
    surname,
    password,
    birthDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      surname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surname'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
    );
  }

  @override
  $UserTable createAlias(String alias) {
    return $UserTable(attachedDatabase, alias);
  }
}

class UserData extends DataClass implements Insertable<UserData> {
  final int id;
  final String username;
  final String name;
  final String surname;
  final String password;
  final DateTime birthDate;
  const UserData({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.password,
    required this.birthDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['name'] = Variable<String>(name);
    map['surname'] = Variable<String>(surname);
    map['password'] = Variable<String>(password);
    map['birth_date'] = Variable<DateTime>(birthDate);
    return map;
  }

  UserCompanion toCompanion(bool nullToAbsent) {
    return UserCompanion(
      id: Value(id),
      username: Value(username),
      name: Value(name),
      surname: Value(surname),
      password: Value(password),
      birthDate: Value(birthDate),
    );
  }

  factory UserData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserData(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      name: serializer.fromJson<String>(json['name']),
      surname: serializer.fromJson<String>(json['surname']),
      password: serializer.fromJson<String>(json['password']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'name': serializer.toJson<String>(name),
      'surname': serializer.toJson<String>(surname),
      'password': serializer.toJson<String>(password),
      'birthDate': serializer.toJson<DateTime>(birthDate),
    };
  }

  UserData copyWith({
    int? id,
    String? username,
    String? name,
    String? surname,
    String? password,
    DateTime? birthDate,
  }) => UserData(
    id: id ?? this.id,
    username: username ?? this.username,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    password: password ?? this.password,
    birthDate: birthDate ?? this.birthDate,
  );
  UserData copyWithCompanion(UserCompanion data) {
    return UserData(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      name: data.name.present ? data.name.value : this.name,
      surname: data.surname.present ? data.surname.value : this.surname,
      password: data.password.present ? data.password.value : this.password,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserData(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('password: $password, ')
          ..write('birthDate: $birthDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, username, name, surname, password, birthDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserData &&
          other.id == this.id &&
          other.username == this.username &&
          other.name == this.name &&
          other.surname == this.surname &&
          other.password == this.password &&
          other.birthDate == this.birthDate);
}

class UserCompanion extends UpdateCompanion<UserData> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> name;
  final Value<String> surname;
  final Value<String> password;
  final Value<DateTime> birthDate;
  const UserCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.password = const Value.absent(),
    this.birthDate = const Value.absent(),
  });
  UserCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String name,
    required String surname,
    required String password,
    required DateTime birthDate,
  }) : username = Value(username),
       name = Value(name),
       surname = Value(surname),
       password = Value(password),
       birthDate = Value(birthDate);
  static Insertable<UserData> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? name,
    Expression<String>? surname,
    Expression<String>? password,
    Expression<DateTime>? birthDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (password != null) 'password': password,
      if (birthDate != null) 'birth_date': birthDate,
    });
  }

  UserCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? name,
    Value<String>? surname,
    Value<String>? password,
    Value<DateTime>? birthDate,
  }) {
    return UserCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('password: $password, ')
          ..write('birthDate: $birthDate')
          ..write(')'))
        .toString();
  }
}

class $EmotionTable extends Emotion with TableInfo<$EmotionTable, EmotionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmotionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    check: () => ComparableExpr(value).isBetweenValues(1, 10),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user (id) ON DELETE CASCADE',
    ),
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
    defaultValue: currentDateAndTime,
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
    value,
    userId,
    createdAt,
    note,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emotion';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmotionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  EmotionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmotionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  $EmotionTable createAlias(String alias) {
    return $EmotionTable(attachedDatabase, alias);
  }
}

class EmotionData extends DataClass implements Insertable<EmotionData> {
  final int id;
  final int value;
  final int userId;
  final DateTime createdAt;
  final String? note;
  final String? tags;
  const EmotionData({
    required this.id,
    required this.value,
    required this.userId,
    required this.createdAt,
    this.note,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value'] = Variable<int>(value);
    map['user_id'] = Variable<int>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  EmotionCompanion toCompanion(bool nullToAbsent) {
    return EmotionCompanion(
      id: Value(id),
      value: Value(value),
      userId: Value(userId),
      createdAt: Value(createdAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory EmotionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmotionData(
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<int>(json['value']),
      userId: serializer.fromJson<int>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<int>(value),
      'userId': serializer.toJson<int>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  EmotionData copyWith({
    int? id,
    int? value,
    int? userId,
    DateTime? createdAt,
    Value<String?> note = const Value.absent(),
    Value<String?> tags = const Value.absent(),
  }) => EmotionData(
    id: id ?? this.id,
    value: value ?? this.value,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    note: note.present ? note.value : this.note,
    tags: tags.present ? tags.value : this.tags,
  );
  EmotionData copyWithCompanion(EmotionCompanion data) {
    return EmotionData(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmotionData(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value, userId, createdAt, note, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmotionData &&
          other.id == this.id &&
          other.value == this.value &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.note == this.note &&
          other.tags == this.tags);
}

class EmotionCompanion extends UpdateCompanion<EmotionData> {
  final Value<int> id;
  final Value<int> value;
  final Value<int> userId;
  final Value<DateTime> createdAt;
  final Value<String?> note;
  final Value<String?> tags;
  const EmotionCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
  });
  EmotionCompanion.insert({
    this.id = const Value.absent(),
    required int value,
    required int userId,
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
  }) : value = Value(value),
       userId = Value(userId);
  static Insertable<EmotionData> custom({
    Expression<int>? id,
    Expression<int>? value,
    Expression<int>? userId,
    Expression<DateTime>? createdAt,
    Expression<String>? note,
    Expression<String>? tags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
    });
  }

  EmotionCompanion copyWith({
    Value<int>? id,
    Value<int>? value,
    Value<int>? userId,
    Value<DateTime>? createdAt,
    Value<String?>? note,
    Value<String?>? tags,
  }) {
    return EmotionCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmotionCompanion(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class $MoodTagTable extends MoodTag with TableInfo<$MoodTagTable, MoodTagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodTagTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, emoji, userId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_tag';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodTagData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoodTagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodTagData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $MoodTagTable createAlias(String alias) {
    return $MoodTagTable(attachedDatabase, alias);
  }
}

class MoodTagData extends DataClass implements Insertable<MoodTagData> {
  final int id;
  final String label;
  final String emoji;
  final int? userId;
  const MoodTagData({
    required this.id,
    required this.label,
    required this.emoji,
    this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['emoji'] = Variable<String>(emoji);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    return map;
  }

  MoodTagCompanion toCompanion(bool nullToAbsent) {
    return MoodTagCompanion(
      id: Value(id),
      label: Value(label),
      emoji: Value(emoji),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    );
  }

  factory MoodTagData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodTagData(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      emoji: serializer.fromJson<String>(json['emoji']),
      userId: serializer.fromJson<int?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'emoji': serializer.toJson<String>(emoji),
      'userId': serializer.toJson<int?>(userId),
    };
  }

  MoodTagData copyWith({
    int? id,
    String? label,
    String? emoji,
    Value<int?> userId = const Value.absent(),
  }) => MoodTagData(
    id: id ?? this.id,
    label: label ?? this.label,
    emoji: emoji ?? this.emoji,
    userId: userId.present ? userId.value : this.userId,
  );
  MoodTagData copyWithCompanion(MoodTagCompanion data) {
    return MoodTagData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodTagData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('emoji: $emoji, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, emoji, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodTagData &&
          other.id == this.id &&
          other.label == this.label &&
          other.emoji == this.emoji &&
          other.userId == this.userId);
}

class MoodTagCompanion extends UpdateCompanion<MoodTagData> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> emoji;
  final Value<int?> userId;
  const MoodTagCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.emoji = const Value.absent(),
    this.userId = const Value.absent(),
  });
  MoodTagCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String emoji,
    this.userId = const Value.absent(),
  }) : label = Value(label),
       emoji = Value(emoji);
  static Insertable<MoodTagData> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? emoji,
    Expression<int>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (emoji != null) 'emoji': emoji,
      if (userId != null) 'user_id': userId,
    });
  }

  MoodTagCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? emoji,
    Value<int?>? userId,
  }) {
    return MoodTagCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodTagCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('emoji: $emoji, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }
}

class $BadgeTable extends Badge with TableInfo<$BadgeTable, BadgeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgeTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    title,
    description,
    icon,
    unlockedAt,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badge';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadgeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BadgeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
    );
  }

  @override
  $BadgeTable createAlias(String alias) {
    return $BadgeTable(attachedDatabase, alias);
  }
}

class BadgeData extends DataClass implements Insertable<BadgeData> {
  final int id;
  final String code;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final int userId;
  const BadgeData({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['user_id'] = Variable<int>(userId);
    return map;
  }

  BadgeCompanion toCompanion(bool nullToAbsent) {
    return BadgeCompanion(
      id: Value(id),
      code: Value(code),
      title: Value(title),
      description: Value(description),
      icon: Value(icon),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      userId: Value(userId),
    );
  }

  factory BadgeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgeData(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      icon: serializer.fromJson<String>(json['icon']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      userId: serializer.fromJson<int>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'icon': serializer.toJson<String>(icon),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'userId': serializer.toJson<int>(userId),
    };
  }

  BadgeData copyWith({
    int? id,
    String? code,
    String? title,
    String? description,
    String? icon,
    Value<DateTime?> unlockedAt = const Value.absent(),
    int? userId,
  }) => BadgeData(
    id: id ?? this.id,
    code: code ?? this.code,
    title: title ?? this.title,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    userId: userId ?? this.userId,
  );
  BadgeData copyWithCompanion(BadgeCompanion data) {
    return BadgeData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgeData(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, title, description, icon, unlockedAt, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgeData &&
          other.id == this.id &&
          other.code == this.code &&
          other.title == this.title &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.unlockedAt == this.unlockedAt &&
          other.userId == this.userId);
}

class BadgeCompanion extends UpdateCompanion<BadgeData> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> title;
  final Value<String> description;
  final Value<String> icon;
  final Value<DateTime?> unlockedAt;
  final Value<int> userId;
  const BadgeCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.userId = const Value.absent(),
  });
  BadgeCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String title,
    required String description,
    required String icon,
    this.unlockedAt = const Value.absent(),
    required int userId,
  }) : code = Value(code),
       title = Value(title),
       description = Value(description),
       icon = Value(icon),
       userId = Value(userId);
  static Insertable<BadgeData> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<DateTime>? unlockedAt,
    Expression<int>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (userId != null) 'user_id': userId,
    });
  }

  BadgeCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? title,
    Value<String>? description,
    Value<String>? icon,
    Value<DateTime?>? unlockedAt,
    Value<int>? userId,
  }) {
    return BadgeCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgeCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDataBase extends GeneratedDatabase {
  _$AppDataBase(QueryExecutor e) : super(e);
  $AppDataBaseManager get managers => $AppDataBaseManager(this);
  late final $UserTable user = $UserTable(this);
  late final $EmotionTable emotion = $EmotionTable(this);
  late final $MoodTagTable moodTag = $MoodTagTable(this);
  late final $BadgeTable badge = $BadgeTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    user,
    emotion,
    moodTag,
    badge,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('emotion', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('mood_tag', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('badge', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserTableCreateCompanionBuilder =
    UserCompanion Function({
      Value<int> id,
      required String username,
      required String name,
      required String surname,
      required String password,
      required DateTime birthDate,
    });
typedef $$UserTableUpdateCompanionBuilder =
    UserCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> name,
      Value<String> surname,
      Value<String> password,
      Value<DateTime> birthDate,
    });

final class $$UserTableReferences
    extends BaseReferences<_$AppDataBase, $UserTable, UserData> {
  $$UserTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EmotionTable, List<EmotionData>>
  _emotionRefsTable(_$AppDataBase db) => MultiTypedResultKey.fromTable(
    db.emotion,
    aliasName: 'user__id__emotion__user_id',
  );

  $$EmotionTableProcessedTableManager get emotionRefs {
    final manager = $$EmotionTableTableManager(
      $_db,
      $_db.emotion,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_emotionRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MoodTagTable, List<MoodTagData>>
  _moodTagRefsTable(_$AppDataBase db) => MultiTypedResultKey.fromTable(
    db.moodTag,
    aliasName: 'user__id__mood_tag__user_id',
  );

  $$MoodTagTableProcessedTableManager get moodTagRefs {
    final manager = $$MoodTagTableTableManager(
      $_db,
      $_db.moodTag,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_moodTagRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BadgeTable, List<BadgeData>> _badgeRefsTable(
    _$AppDataBase db,
  ) => MultiTypedResultKey.fromTable(
    db.badge,
    aliasName: 'user__id__badge__user_id',
  );

  $$BadgeTableProcessedTableManager get badgeRefs {
    final manager = $$BadgeTableTableManager(
      $_db,
      $_db.badge,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_badgeRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserTableFilterComposer extends Composer<_$AppDataBase, $UserTable> {
  $$UserTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> emotionRefs(
    Expression<bool> Function($$EmotionTableFilterComposer f) f,
  ) {
    final $$EmotionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emotion,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionTableFilterComposer(
            $db: $db,
            $table: $db.emotion,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moodTagRefs(
    Expression<bool> Function($$MoodTagTableFilterComposer f) f,
  ) {
    final $$MoodTagTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodTag,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagTableFilterComposer(
            $db: $db,
            $table: $db.moodTag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> badgeRefs(
    Expression<bool> Function($$BadgeTableFilterComposer f) f,
  ) {
    final $$BadgeTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badge,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgeTableFilterComposer(
            $db: $db,
            $table: $db.badge,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserTableOrderingComposer extends Composer<_$AppDataBase, $UserTable> {
  $$UserTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserTableAnnotationComposer
    extends Composer<_$AppDataBase, $UserTable> {
  $$UserTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  Expression<T> emotionRefs<T extends Object>(
    Expression<T> Function($$EmotionTableAnnotationComposer a) f,
  ) {
    final $$EmotionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emotion,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionTableAnnotationComposer(
            $db: $db,
            $table: $db.emotion,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moodTagRefs<T extends Object>(
    Expression<T> Function($$MoodTagTableAnnotationComposer a) f,
  ) {
    final $$MoodTagTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodTag,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagTableAnnotationComposer(
            $db: $db,
            $table: $db.moodTag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> badgeRefs<T extends Object>(
    Expression<T> Function($$BadgeTableAnnotationComposer a) f,
  ) {
    final $$BadgeTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badge,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgeTableAnnotationComposer(
            $db: $db,
            $table: $db.badge,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $UserTable,
          UserData,
          $$UserTableFilterComposer,
          $$UserTableOrderingComposer,
          $$UserTableAnnotationComposer,
          $$UserTableCreateCompanionBuilder,
          $$UserTableUpdateCompanionBuilder,
          (UserData, $$UserTableReferences),
          UserData,
          PrefetchHooks Function({
            bool emotionRefs,
            bool moodTagRefs,
            bool badgeRefs,
          })
        > {
  $$UserTableTableManager(_$AppDataBase db, $UserTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> surname = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
              }) => UserCompanion(
                id: id,
                username: username,
                name: name,
                surname: surname,
                password: password,
                birthDate: birthDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String name,
                required String surname,
                required String password,
                required DateTime birthDate,
              }) => UserCompanion.insert(
                id: id,
                username: username,
                name: name,
                surname: surname,
                password: password,
                birthDate: birthDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UserTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({emotionRefs = false, moodTagRefs = false, badgeRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (emotionRefs) db.emotion,
                    if (moodTagRefs) db.moodTag,
                    if (badgeRefs) db.badge,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (emotionRefs)
                        await $_getPrefetchedData<
                          UserData,
                          $UserTable,
                          EmotionData
                        >(
                          currentTable: table,
                          referencedTable: $$UserTableReferences
                              ._emotionRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserTableReferences(db, table, p0).emotionRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (moodTagRefs)
                        await $_getPrefetchedData<
                          UserData,
                          $UserTable,
                          MoodTagData
                        >(
                          currentTable: table,
                          referencedTable: $$UserTableReferences
                              ._moodTagRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserTableReferences(db, table, p0).moodTagRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (badgeRefs)
                        await $_getPrefetchedData<
                          UserData,
                          $UserTable,
                          BadgeData
                        >(
                          currentTable: table,
                          referencedTable: $$UserTableReferences
                              ._badgeRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserTableReferences(db, table, p0).badgeRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
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

typedef $$UserTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $UserTable,
      UserData,
      $$UserTableFilterComposer,
      $$UserTableOrderingComposer,
      $$UserTableAnnotationComposer,
      $$UserTableCreateCompanionBuilder,
      $$UserTableUpdateCompanionBuilder,
      (UserData, $$UserTableReferences),
      UserData,
      PrefetchHooks Function({
        bool emotionRefs,
        bool moodTagRefs,
        bool badgeRefs,
      })
    >;
typedef $$EmotionTableCreateCompanionBuilder =
    EmotionCompanion Function({
      Value<int> id,
      required int value,
      required int userId,
      Value<DateTime> createdAt,
      Value<String?> note,
      Value<String?> tags,
    });
typedef $$EmotionTableUpdateCompanionBuilder =
    EmotionCompanion Function({
      Value<int> id,
      Value<int> value,
      Value<int> userId,
      Value<DateTime> createdAt,
      Value<String?> note,
      Value<String?> tags,
    });

final class $$EmotionTableReferences
    extends BaseReferences<_$AppDataBase, $EmotionTable, EmotionData> {
  $$EmotionTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserTable _userIdTable(_$AppDataBase db) =>
      db.user.createAlias('emotion__user_id__user__id');

  $$UserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UserTableTableManager(
      $_db,
      $_db.user,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmotionTableFilterComposer
    extends Composer<_$AppDataBase, $EmotionTable> {
  $$EmotionTableFilterComposer({
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

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  $$UserTableFilterComposer get userId {
    final $$UserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableFilterComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmotionTableOrderingComposer
    extends Composer<_$AppDataBase, $EmotionTable> {
  $$EmotionTableOrderingComposer({
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

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserTableOrderingComposer get userId {
    final $$UserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableOrderingComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmotionTableAnnotationComposer
    extends Composer<_$AppDataBase, $EmotionTable> {
  $$EmotionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  $$UserTableAnnotationComposer get userId {
    final $$UserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableAnnotationComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmotionTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $EmotionTable,
          EmotionData,
          $$EmotionTableFilterComposer,
          $$EmotionTableOrderingComposer,
          $$EmotionTableAnnotationComposer,
          $$EmotionTableCreateCompanionBuilder,
          $$EmotionTableUpdateCompanionBuilder,
          (EmotionData, $$EmotionTableReferences),
          EmotionData,
          PrefetchHooks Function({bool userId})
        > {
  $$EmotionTableTableManager(_$AppDataBase db, $EmotionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmotionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmotionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmotionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => EmotionCompanion(
                id: id,
                value: value,
                userId: userId,
                createdAt: createdAt,
                note: note,
                tags: tags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int value,
                required int userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => EmotionCompanion.insert(
                id: id,
                value: value,
                userId: userId,
                createdAt: createdAt,
                note: note,
                tags: tags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmotionTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$EmotionTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$EmotionTableReferences
                                    ._userIdTable(db)
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

typedef $$EmotionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $EmotionTable,
      EmotionData,
      $$EmotionTableFilterComposer,
      $$EmotionTableOrderingComposer,
      $$EmotionTableAnnotationComposer,
      $$EmotionTableCreateCompanionBuilder,
      $$EmotionTableUpdateCompanionBuilder,
      (EmotionData, $$EmotionTableReferences),
      EmotionData,
      PrefetchHooks Function({bool userId})
    >;
typedef $$MoodTagTableCreateCompanionBuilder =
    MoodTagCompanion Function({
      Value<int> id,
      required String label,
      required String emoji,
      Value<int?> userId,
    });
typedef $$MoodTagTableUpdateCompanionBuilder =
    MoodTagCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> emoji,
      Value<int?> userId,
    });

final class $$MoodTagTableReferences
    extends BaseReferences<_$AppDataBase, $MoodTagTable, MoodTagData> {
  $$MoodTagTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserTable _userIdTable(_$AppDataBase db) =>
      db.user.createAlias('mood_tag__user_id__user__id');

  $$UserTableProcessedTableManager? get userId {
    final $_column = $_itemColumn<int>('user_id');
    if ($_column == null) return null;
    final manager = $$UserTableTableManager(
      $_db,
      $_db.user,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoodTagTableFilterComposer
    extends Composer<_$AppDataBase, $MoodTagTable> {
  $$MoodTagTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  $$UserTableFilterComposer get userId {
    final $$UserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableFilterComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodTagTableOrderingComposer
    extends Composer<_$AppDataBase, $MoodTagTable> {
  $$MoodTagTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserTableOrderingComposer get userId {
    final $$UserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableOrderingComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodTagTableAnnotationComposer
    extends Composer<_$AppDataBase, $MoodTagTable> {
  $$MoodTagTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  $$UserTableAnnotationComposer get userId {
    final $$UserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableAnnotationComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodTagTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $MoodTagTable,
          MoodTagData,
          $$MoodTagTableFilterComposer,
          $$MoodTagTableOrderingComposer,
          $$MoodTagTableAnnotationComposer,
          $$MoodTagTableCreateCompanionBuilder,
          $$MoodTagTableUpdateCompanionBuilder,
          (MoodTagData, $$MoodTagTableReferences),
          MoodTagData,
          PrefetchHooks Function({bool userId})
        > {
  $$MoodTagTableTableManager(_$AppDataBase db, $MoodTagTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodTagTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodTagTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodTagTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int?> userId = const Value.absent(),
              }) => MoodTagCompanion(
                id: id,
                label: label,
                emoji: emoji,
                userId: userId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String emoji,
                Value<int?> userId = const Value.absent(),
              }) => MoodTagCompanion.insert(
                id: id,
                label: label,
                emoji: emoji,
                userId: userId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoodTagTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$MoodTagTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$MoodTagTableReferences
                                    ._userIdTable(db)
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

typedef $$MoodTagTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $MoodTagTable,
      MoodTagData,
      $$MoodTagTableFilterComposer,
      $$MoodTagTableOrderingComposer,
      $$MoodTagTableAnnotationComposer,
      $$MoodTagTableCreateCompanionBuilder,
      $$MoodTagTableUpdateCompanionBuilder,
      (MoodTagData, $$MoodTagTableReferences),
      MoodTagData,
      PrefetchHooks Function({bool userId})
    >;
typedef $$BadgeTableCreateCompanionBuilder =
    BadgeCompanion Function({
      Value<int> id,
      required String code,
      required String title,
      required String description,
      required String icon,
      Value<DateTime?> unlockedAt,
      required int userId,
    });
typedef $$BadgeTableUpdateCompanionBuilder =
    BadgeCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> title,
      Value<String> description,
      Value<String> icon,
      Value<DateTime?> unlockedAt,
      Value<int> userId,
    });

final class $$BadgeTableReferences
    extends BaseReferences<_$AppDataBase, $BadgeTable, BadgeData> {
  $$BadgeTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserTable _userIdTable(_$AppDataBase db) =>
      db.user.createAlias('badge__user_id__user__id');

  $$UserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UserTableTableManager(
      $_db,
      $_db.user,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BadgeTableFilterComposer extends Composer<_$AppDataBase, $BadgeTable> {
  $$BadgeTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserTableFilterComposer get userId {
    final $$UserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableFilterComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadgeTableOrderingComposer
    extends Composer<_$AppDataBase, $BadgeTable> {
  $$BadgeTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserTableOrderingComposer get userId {
    final $$UserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableOrderingComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadgeTableAnnotationComposer
    extends Composer<_$AppDataBase, $BadgeTable> {
  $$BadgeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  $$UserTableAnnotationComposer get userId {
    final $$UserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.user,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableAnnotationComposer(
            $db: $db,
            $table: $db.user,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadgeTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $BadgeTable,
          BadgeData,
          $$BadgeTableFilterComposer,
          $$BadgeTableOrderingComposer,
          $$BadgeTableAnnotationComposer,
          $$BadgeTableCreateCompanionBuilder,
          $$BadgeTableUpdateCompanionBuilder,
          (BadgeData, $$BadgeTableReferences),
          BadgeData,
          PrefetchHooks Function({bool userId})
        > {
  $$BadgeTableTableManager(_$AppDataBase db, $BadgeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> userId = const Value.absent(),
              }) => BadgeCompanion(
                id: id,
                code: code,
                title: title,
                description: description,
                icon: icon,
                unlockedAt: unlockedAt,
                userId: userId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String title,
                required String description,
                required String icon,
                Value<DateTime?> unlockedAt = const Value.absent(),
                required int userId,
              }) => BadgeCompanion.insert(
                id: id,
                code: code,
                title: title,
                description: description,
                icon: icon,
                unlockedAt: unlockedAt,
                userId: userId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BadgeTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$BadgeTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$BadgeTableReferences
                                    ._userIdTable(db)
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

typedef $$BadgeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $BadgeTable,
      BadgeData,
      $$BadgeTableFilterComposer,
      $$BadgeTableOrderingComposer,
      $$BadgeTableAnnotationComposer,
      $$BadgeTableCreateCompanionBuilder,
      $$BadgeTableUpdateCompanionBuilder,
      (BadgeData, $$BadgeTableReferences),
      BadgeData,
      PrefetchHooks Function({bool userId})
    >;

class $AppDataBaseManager {
  final _$AppDataBase _db;
  $AppDataBaseManager(this._db);
  $$UserTableTableManager get user => $$UserTableTableManager(_db, _db.user);
  $$EmotionTableTableManager get emotion =>
      $$EmotionTableTableManager(_db, _db.emotion);
  $$MoodTagTableTableManager get moodTag =>
      $$MoodTagTableTableManager(_db, _db.moodTag);
  $$BadgeTableTableManager get badge =>
      $$BadgeTableTableManager(_db, _db.badge);
}
