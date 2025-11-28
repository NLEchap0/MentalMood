// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EmozioneTable extends Emozione
    with TableInfo<$EmozioneTable, EmozioneData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmozioneTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imgPathMeta = const VerificationMeta(
    'imgPath',
  );
  @override
  late final GeneratedColumn<String> imgPath = GeneratedColumn<String>(
    'img_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valoreMeta = const VerificationMeta('valore');
  @override
  late final GeneratedColumn<int> valore = GeneratedColumn<int>(
    'valore',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [nome, imgPath, valore];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emozione';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmozioneData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('img_path')) {
      context.handle(
        _imgPathMeta,
        imgPath.isAcceptableOrUnknown(data['img_path']!, _imgPathMeta),
      );
    } else if (isInserting) {
      context.missing(_imgPathMeta);
    }
    if (data.containsKey('valore')) {
      context.handle(
        _valoreMeta,
        valore.isAcceptableOrUnknown(data['valore']!, _valoreMeta),
      );
    } else if (isInserting) {
      context.missing(_valoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nome};
  @override
  EmozioneData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmozioneData(
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      imgPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}img_path'],
      )!,
      valore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valore'],
      )!,
    );
  }

  @override
  $EmozioneTable createAlias(String alias) {
    return $EmozioneTable(attachedDatabase, alias);
  }
}

class EmozioneData extends DataClass implements Insertable<EmozioneData> {
  final String nome;
  final String imgPath;
  final int valore;
  const EmozioneData({
    required this.nome,
    required this.imgPath,
    required this.valore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['nome'] = Variable<String>(nome);
    map['img_path'] = Variable<String>(imgPath);
    map['valore'] = Variable<int>(valore);
    return map;
  }

  EmozioneCompanion toCompanion(bool nullToAbsent) {
    return EmozioneCompanion(
      nome: Value(nome),
      imgPath: Value(imgPath),
      valore: Value(valore),
    );
  }

  factory EmozioneData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmozioneData(
      nome: serializer.fromJson<String>(json['nome']),
      imgPath: serializer.fromJson<String>(json['imgPath']),
      valore: serializer.fromJson<int>(json['valore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nome': serializer.toJson<String>(nome),
      'imgPath': serializer.toJson<String>(imgPath),
      'valore': serializer.toJson<int>(valore),
    };
  }

  EmozioneData copyWith({String? nome, String? imgPath, int? valore}) =>
      EmozioneData(
        nome: nome ?? this.nome,
        imgPath: imgPath ?? this.imgPath,
        valore: valore ?? this.valore,
      );
  EmozioneData copyWithCompanion(EmozioneCompanion data) {
    return EmozioneData(
      nome: data.nome.present ? data.nome.value : this.nome,
      imgPath: data.imgPath.present ? data.imgPath.value : this.imgPath,
      valore: data.valore.present ? data.valore.value : this.valore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmozioneData(')
          ..write('nome: $nome, ')
          ..write('imgPath: $imgPath, ')
          ..write('valore: $valore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(nome, imgPath, valore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmozioneData &&
          other.nome == this.nome &&
          other.imgPath == this.imgPath &&
          other.valore == this.valore);
}

class EmozioneCompanion extends UpdateCompanion<EmozioneData> {
  final Value<String> nome;
  final Value<String> imgPath;
  final Value<int> valore;
  final Value<int> rowid;
  const EmozioneCompanion({
    this.nome = const Value.absent(),
    this.imgPath = const Value.absent(),
    this.valore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmozioneCompanion.insert({
    required String nome,
    required String imgPath,
    required int valore,
    this.rowid = const Value.absent(),
  }) : nome = Value(nome),
       imgPath = Value(imgPath),
       valore = Value(valore);
  static Insertable<EmozioneData> custom({
    Expression<String>? nome,
    Expression<String>? imgPath,
    Expression<int>? valore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nome != null) 'nome': nome,
      if (imgPath != null) 'img_path': imgPath,
      if (valore != null) 'valore': valore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmozioneCompanion copyWith({
    Value<String>? nome,
    Value<String>? imgPath,
    Value<int>? valore,
    Value<int>? rowid,
  }) {
    return EmozioneCompanion(
      nome: nome ?? this.nome,
      imgPath: imgPath ?? this.imgPath,
      valore: valore ?? this.valore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (imgPath.present) {
      map['img_path'] = Variable<String>(imgPath.value);
    }
    if (valore.present) {
      map['valore'] = Variable<int>(valore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmozioneCompanion(')
          ..write('nome: $nome, ')
          ..write('imgPath: $imgPath, ')
          ..write('valore: $valore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UtenteTable extends Utente with TableInfo<$UtenteTable, UtenteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UtenteTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataNascitaMeta = const VerificationMeta(
    'dataNascita',
  );
  @override
  late final GeneratedColumn<DateTime> dataNascita = GeneratedColumn<DateTime>(
    'data_nascita',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, username, nome, dataNascita];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'utente';
  @override
  VerificationContext validateIntegrity(
    Insertable<UtenteData> instance, {
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
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('data_nascita')) {
      context.handle(
        _dataNascitaMeta,
        dataNascita.isAcceptableOrUnknown(
          data['data_nascita']!,
          _dataNascitaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataNascitaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UtenteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UtenteData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      dataNascita: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_nascita'],
      )!,
    );
  }

  @override
  $UtenteTable createAlias(String alias) {
    return $UtenteTable(attachedDatabase, alias);
  }
}

class UtenteData extends DataClass implements Insertable<UtenteData> {
  final int id;
  final String username;
  final String nome;
  final DateTime dataNascita;
  const UtenteData({
    required this.id,
    required this.username,
    required this.nome,
    required this.dataNascita,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['nome'] = Variable<String>(nome);
    map['data_nascita'] = Variable<DateTime>(dataNascita);
    return map;
  }

  UtenteCompanion toCompanion(bool nullToAbsent) {
    return UtenteCompanion(
      id: Value(id),
      username: Value(username),
      nome: Value(nome),
      dataNascita: Value(dataNascita),
    );
  }

  factory UtenteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UtenteData(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      nome: serializer.fromJson<String>(json['nome']),
      dataNascita: serializer.fromJson<DateTime>(json['dataNascita']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'nome': serializer.toJson<String>(nome),
      'dataNascita': serializer.toJson<DateTime>(dataNascita),
    };
  }

  UtenteData copyWith({
    int? id,
    String? username,
    String? nome,
    DateTime? dataNascita,
  }) => UtenteData(
    id: id ?? this.id,
    username: username ?? this.username,
    nome: nome ?? this.nome,
    dataNascita: dataNascita ?? this.dataNascita,
  );
  UtenteData copyWithCompanion(UtenteCompanion data) {
    return UtenteData(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      nome: data.nome.present ? data.nome.value : this.nome,
      dataNascita: data.dataNascita.present
          ? data.dataNascita.value
          : this.dataNascita,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UtenteData(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('nome: $nome, ')
          ..write('dataNascita: $dataNascita')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, nome, dataNascita);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UtenteData &&
          other.id == this.id &&
          other.username == this.username &&
          other.nome == this.nome &&
          other.dataNascita == this.dataNascita);
}

class UtenteCompanion extends UpdateCompanion<UtenteData> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> nome;
  final Value<DateTime> dataNascita;
  const UtenteCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.nome = const Value.absent(),
    this.dataNascita = const Value.absent(),
  });
  UtenteCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String nome,
    required DateTime dataNascita,
  }) : username = Value(username),
       nome = Value(nome),
       dataNascita = Value(dataNascita);
  static Insertable<UtenteData> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? nome,
    Expression<DateTime>? dataNascita,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (nome != null) 'nome': nome,
      if (dataNascita != null) 'data_nascita': dataNascita,
    });
  }

  UtenteCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? nome,
    Value<DateTime>? dataNascita,
  }) {
    return UtenteCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      nome: nome ?? this.nome,
      dataNascita: dataNascita ?? this.dataNascita,
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
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (dataNascita.present) {
      map['data_nascita'] = Variable<DateTime>(dataNascita.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtenteCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('nome: $nome, ')
          ..write('dataNascita: $dataNascita')
          ..write(')'))
        .toString();
  }
}

class $ConsiglioTable extends Consiglio
    with TableInfo<$ConsiglioTable, ConsiglioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsiglioTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _testoMeta = const VerificationMeta('testo');
  @override
  late final GeneratedColumn<String> testo = GeneratedColumn<String>(
    'testo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valoreInizialeMeta = const VerificationMeta(
    'valoreIniziale',
  );
  @override
  late final GeneratedColumn<int> valoreIniziale = GeneratedColumn<int>(
    'valore_iniziale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valoreFinaleMeta = const VerificationMeta(
    'valoreFinale',
  );
  @override
  late final GeneratedColumn<int> valoreFinale = GeneratedColumn<int>(
    'valore_finale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    testo,
    valoreIniziale,
    valoreFinale,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consiglio';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsiglioData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('testo')) {
      context.handle(
        _testoMeta,
        testo.isAcceptableOrUnknown(data['testo']!, _testoMeta),
      );
    } else if (isInserting) {
      context.missing(_testoMeta);
    }
    if (data.containsKey('valore_iniziale')) {
      context.handle(
        _valoreInizialeMeta,
        valoreIniziale.isAcceptableOrUnknown(
          data['valore_iniziale']!,
          _valoreInizialeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valoreInizialeMeta);
    }
    if (data.containsKey('valore_finale')) {
      context.handle(
        _valoreFinaleMeta,
        valoreFinale.isAcceptableOrUnknown(
          data['valore_finale']!,
          _valoreFinaleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valoreFinaleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsiglioData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsiglioData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      testo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}testo'],
      )!,
      valoreIniziale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valore_iniziale'],
      )!,
      valoreFinale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valore_finale'],
      )!,
    );
  }

  @override
  $ConsiglioTable createAlias(String alias) {
    return $ConsiglioTable(attachedDatabase, alias);
  }
}

class ConsiglioData extends DataClass implements Insertable<ConsiglioData> {
  final int id;
  final String testo;
  final int valoreIniziale;
  final int valoreFinale;
  const ConsiglioData({
    required this.id,
    required this.testo,
    required this.valoreIniziale,
    required this.valoreFinale,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['testo'] = Variable<String>(testo);
    map['valore_iniziale'] = Variable<int>(valoreIniziale);
    map['valore_finale'] = Variable<int>(valoreFinale);
    return map;
  }

  ConsiglioCompanion toCompanion(bool nullToAbsent) {
    return ConsiglioCompanion(
      id: Value(id),
      testo: Value(testo),
      valoreIniziale: Value(valoreIniziale),
      valoreFinale: Value(valoreFinale),
    );
  }

  factory ConsiglioData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsiglioData(
      id: serializer.fromJson<int>(json['id']),
      testo: serializer.fromJson<String>(json['testo']),
      valoreIniziale: serializer.fromJson<int>(json['valoreIniziale']),
      valoreFinale: serializer.fromJson<int>(json['valoreFinale']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testo': serializer.toJson<String>(testo),
      'valoreIniziale': serializer.toJson<int>(valoreIniziale),
      'valoreFinale': serializer.toJson<int>(valoreFinale),
    };
  }

  ConsiglioData copyWith({
    int? id,
    String? testo,
    int? valoreIniziale,
    int? valoreFinale,
  }) => ConsiglioData(
    id: id ?? this.id,
    testo: testo ?? this.testo,
    valoreIniziale: valoreIniziale ?? this.valoreIniziale,
    valoreFinale: valoreFinale ?? this.valoreFinale,
  );
  ConsiglioData copyWithCompanion(ConsiglioCompanion data) {
    return ConsiglioData(
      id: data.id.present ? data.id.value : this.id,
      testo: data.testo.present ? data.testo.value : this.testo,
      valoreIniziale: data.valoreIniziale.present
          ? data.valoreIniziale.value
          : this.valoreIniziale,
      valoreFinale: data.valoreFinale.present
          ? data.valoreFinale.value
          : this.valoreFinale,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsiglioData(')
          ..write('id: $id, ')
          ..write('testo: $testo, ')
          ..write('valoreIniziale: $valoreIniziale, ')
          ..write('valoreFinale: $valoreFinale')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, testo, valoreIniziale, valoreFinale);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsiglioData &&
          other.id == this.id &&
          other.testo == this.testo &&
          other.valoreIniziale == this.valoreIniziale &&
          other.valoreFinale == this.valoreFinale);

  operator [](int other) {}
}

class ConsiglioCompanion extends UpdateCompanion<ConsiglioData> {
  final Value<int> id;
  final Value<String> testo;
  final Value<int> valoreIniziale;
  final Value<int> valoreFinale;
  const ConsiglioCompanion({
    this.id = const Value.absent(),
    this.testo = const Value.absent(),
    this.valoreIniziale = const Value.absent(),
    this.valoreFinale = const Value.absent(),
  });
  ConsiglioCompanion.insert({
    this.id = const Value.absent(),
    required String testo,
    required int valoreIniziale,
    required int valoreFinale,
  }) : testo = Value(testo),
       valoreIniziale = Value(valoreIniziale),
       valoreFinale = Value(valoreFinale);
  static Insertable<ConsiglioData> custom({
    Expression<int>? id,
    Expression<String>? testo,
    Expression<int>? valoreIniziale,
    Expression<int>? valoreFinale,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testo != null) 'testo': testo,
      if (valoreIniziale != null) 'valore_iniziale': valoreIniziale,
      if (valoreFinale != null) 'valore_finale': valoreFinale,
    });
  }

  ConsiglioCompanion copyWith({
    Value<int>? id,
    Value<String>? testo,
    Value<int>? valoreIniziale,
    Value<int>? valoreFinale,
  }) {
    return ConsiglioCompanion(
      id: id ?? this.id,
      testo: testo ?? this.testo,
      valoreIniziale: valoreIniziale ?? this.valoreIniziale,
      valoreFinale: valoreFinale ?? this.valoreFinale,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testo.present) {
      map['testo'] = Variable<String>(testo.value);
    }
    if (valoreIniziale.present) {
      map['valore_iniziale'] = Variable<int>(valoreIniziale.value);
    }
    if (valoreFinale.present) {
      map['valore_finale'] = Variable<int>(valoreFinale.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsiglioCompanion(')
          ..write('id: $id, ')
          ..write('testo: $testo, ')
          ..write('valoreIniziale: $valoreIniziale, ')
          ..write('valoreFinale: $valoreFinale')
          ..write(')'))
        .toString();
  }
}

class $EmozioneRegistrataTable extends EmozioneRegistrata
    with TableInfo<$EmozioneRegistrataTable, EmozioneRegistrataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmozioneRegistrataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _utenteIdMeta = const VerificationMeta(
    'utenteId',
  );
  @override
  late final GeneratedColumn<int> utenteId = GeneratedColumn<int>(
    'utente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES utente (id)',
    ),
  );
  static const VerificationMeta _emozioneNomeMeta = const VerificationMeta(
    'emozioneNome',
  );
  @override
  late final GeneratedColumn<String> emozioneNome = GeneratedColumn<String>(
    'emozione_nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emozione (nome)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  motivazioneTesto =
      GeneratedColumn<String>(
        'motivazione_testo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>(
        $EmozioneRegistrataTable.$convertermotivazioneTesto,
      );
  static const VerificationMeta _dataRegistrazioneMeta = const VerificationMeta(
    'dataRegistrazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataRegistrazione =
      GeneratedColumn<DateTime>(
        'data_registrazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    utenteId,
    emozioneNome,
    motivazioneTesto,
    dataRegistrazione,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emozione_registrata';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmozioneRegistrataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('utente_id')) {
      context.handle(
        _utenteIdMeta,
        utenteId.isAcceptableOrUnknown(data['utente_id']!, _utenteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_utenteIdMeta);
    }
    if (data.containsKey('emozione_nome')) {
      context.handle(
        _emozioneNomeMeta,
        emozioneNome.isAcceptableOrUnknown(
          data['emozione_nome']!,
          _emozioneNomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_emozioneNomeMeta);
    }
    if (data.containsKey('data_registrazione')) {
      context.handle(
        _dataRegistrazioneMeta,
        dataRegistrazione.isAcceptableOrUnknown(
          data['data_registrazione']!,
          _dataRegistrazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataRegistrazioneMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    utenteId,
    emozioneNome,
    dataRegistrazione,
  };
  @override
  EmozioneRegistrataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmozioneRegistrataData(
      utenteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utente_id'],
      )!,
      emozioneNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emozione_nome'],
      )!,
      motivazioneTesto: $EmozioneRegistrataTable.$convertermotivazioneTesto
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}motivazione_testo'],
            )!,
          ),
      dataRegistrazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_registrazione'],
      )!,
    );
  }

  @override
  $EmozioneRegistrataTable createAlias(String alias) {
    return $EmozioneRegistrataTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertermotivazioneTesto =
      StringListConverter();
}

class EmozioneRegistrataData extends DataClass
    implements Insertable<EmozioneRegistrataData> {
  final int utenteId;
  final String emozioneNome;
  final List<String> motivazioneTesto;
  final DateTime dataRegistrazione;
  const EmozioneRegistrataData({
    required this.utenteId,
    required this.emozioneNome,
    required this.motivazioneTesto,
    required this.dataRegistrazione,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['utente_id'] = Variable<int>(utenteId);
    map['emozione_nome'] = Variable<String>(emozioneNome);
    {
      map['motivazione_testo'] = Variable<String>(
        $EmozioneRegistrataTable.$convertermotivazioneTesto.toSql(
          motivazioneTesto,
        ),
      );
    }
    map['data_registrazione'] = Variable<DateTime>(dataRegistrazione);
    return map;
  }

  EmozioneRegistrataCompanion toCompanion(bool nullToAbsent) {
    return EmozioneRegistrataCompanion(
      utenteId: Value(utenteId),
      emozioneNome: Value(emozioneNome),
      motivazioneTesto: Value(motivazioneTesto),
      dataRegistrazione: Value(dataRegistrazione),
    );
  }

  factory EmozioneRegistrataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmozioneRegistrataData(
      utenteId: serializer.fromJson<int>(json['utenteId']),
      emozioneNome: serializer.fromJson<String>(json['emozioneNome']),
      motivazioneTesto: serializer.fromJson<List<String>>(
        json['motivazioneTesto'],
      ),
      dataRegistrazione: serializer.fromJson<DateTime>(
        json['dataRegistrazione'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'utenteId': serializer.toJson<int>(utenteId),
      'emozioneNome': serializer.toJson<String>(emozioneNome),
      'motivazioneTesto': serializer.toJson<List<String>>(motivazioneTesto),
      'dataRegistrazione': serializer.toJson<DateTime>(dataRegistrazione),
    };
  }

  EmozioneRegistrataData copyWith({
    int? utenteId,
    String? emozioneNome,
    List<String>? motivazioneTesto,
    DateTime? dataRegistrazione,
  }) => EmozioneRegistrataData(
    utenteId: utenteId ?? this.utenteId,
    emozioneNome: emozioneNome ?? this.emozioneNome,
    motivazioneTesto: motivazioneTesto ?? this.motivazioneTesto,
    dataRegistrazione: dataRegistrazione ?? this.dataRegistrazione,
  );
  EmozioneRegistrataData copyWithCompanion(EmozioneRegistrataCompanion data) {
    return EmozioneRegistrataData(
      utenteId: data.utenteId.present ? data.utenteId.value : this.utenteId,
      emozioneNome: data.emozioneNome.present
          ? data.emozioneNome.value
          : this.emozioneNome,
      motivazioneTesto: data.motivazioneTesto.present
          ? data.motivazioneTesto.value
          : this.motivazioneTesto,
      dataRegistrazione: data.dataRegistrazione.present
          ? data.dataRegistrazione.value
          : this.dataRegistrazione,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmozioneRegistrataData(')
          ..write('utenteId: $utenteId, ')
          ..write('emozioneNome: $emozioneNome, ')
          ..write('motivazioneTesto: $motivazioneTesto, ')
          ..write('dataRegistrazione: $dataRegistrazione')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(utenteId, emozioneNome, motivazioneTesto, dataRegistrazione);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmozioneRegistrataData &&
          other.utenteId == this.utenteId &&
          other.emozioneNome == this.emozioneNome &&
          other.motivazioneTesto == this.motivazioneTesto &&
          other.dataRegistrazione == this.dataRegistrazione);
}

class EmozioneRegistrataCompanion
    extends UpdateCompanion<EmozioneRegistrataData> {
  final Value<int> utenteId;
  final Value<String> emozioneNome;
  final Value<List<String>> motivazioneTesto;
  final Value<DateTime> dataRegistrazione;
  final Value<int> rowid;
  const EmozioneRegistrataCompanion({
    this.utenteId = const Value.absent(),
    this.emozioneNome = const Value.absent(),
    this.motivazioneTesto = const Value.absent(),
    this.dataRegistrazione = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmozioneRegistrataCompanion.insert({
    required int utenteId,
    required String emozioneNome,
    required List<String> motivazioneTesto,
    required DateTime dataRegistrazione,
    this.rowid = const Value.absent(),
  }) : utenteId = Value(utenteId),
       emozioneNome = Value(emozioneNome),
       motivazioneTesto = Value(motivazioneTesto),
       dataRegistrazione = Value(dataRegistrazione);
  static Insertable<EmozioneRegistrataData> custom({
    Expression<int>? utenteId,
    Expression<String>? emozioneNome,
    Expression<String>? motivazioneTesto,
    Expression<DateTime>? dataRegistrazione,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (utenteId != null) 'utente_id': utenteId,
      if (emozioneNome != null) 'emozione_nome': emozioneNome,
      if (motivazioneTesto != null) 'motivazione_testo': motivazioneTesto,
      if (dataRegistrazione != null) 'data_registrazione': dataRegistrazione,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmozioneRegistrataCompanion copyWith({
    Value<int>? utenteId,
    Value<String>? emozioneNome,
    Value<List<String>>? motivazioneTesto,
    Value<DateTime>? dataRegistrazione,
    Value<int>? rowid,
  }) {
    return EmozioneRegistrataCompanion(
      utenteId: utenteId ?? this.utenteId,
      emozioneNome: emozioneNome ?? this.emozioneNome,
      motivazioneTesto: motivazioneTesto ?? this.motivazioneTesto,
      dataRegistrazione: dataRegistrazione ?? this.dataRegistrazione,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (utenteId.present) {
      map['utente_id'] = Variable<int>(utenteId.value);
    }
    if (emozioneNome.present) {
      map['emozione_nome'] = Variable<String>(emozioneNome.value);
    }
    if (motivazioneTesto.present) {
      map['motivazione_testo'] = Variable<String>(
        $EmozioneRegistrataTable.$convertermotivazioneTesto.toSql(
          motivazioneTesto.value,
        ),
      );
    }
    if (dataRegistrazione.present) {
      map['data_registrazione'] = Variable<DateTime>(dataRegistrazione.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmozioneRegistrataCompanion(')
          ..write('utenteId: $utenteId, ')
          ..write('emozioneNome: $emozioneNome, ')
          ..write('motivazioneTesto: $motivazioneTesto, ')
          ..write('dataRegistrazione: $dataRegistrazione, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MotivazioneTable extends Motivazione
    with TableInfo<$MotivazioneTable, MotivazioneData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MotivazioneTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _testoMeta = const VerificationMeta('testo');
  @override
  late final GeneratedColumn<String> testo = GeneratedColumn<String>(
    'testo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [testo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'motivazione';
  @override
  VerificationContext validateIntegrity(
    Insertable<MotivazioneData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('testo')) {
      context.handle(
        _testoMeta,
        testo.isAcceptableOrUnknown(data['testo']!, _testoMeta),
      );
    } else if (isInserting) {
      context.missing(_testoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {testo};
  @override
  MotivazioneData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MotivazioneData(
      testo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}testo'],
      )!,
    );
  }

  @override
  $MotivazioneTable createAlias(String alias) {
    return $MotivazioneTable(attachedDatabase, alias);
  }
}

class MotivazioneData extends DataClass implements Insertable<MotivazioneData> {
  final String testo;
  const MotivazioneData({required this.testo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['testo'] = Variable<String>(testo);
    return map;
  }

  MotivazioneCompanion toCompanion(bool nullToAbsent) {
    return MotivazioneCompanion(testo: Value(testo));
  }

  factory MotivazioneData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MotivazioneData(testo: serializer.fromJson<String>(json['testo']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'testo': serializer.toJson<String>(testo)};
  }

  MotivazioneData copyWith({String? testo}) =>
      MotivazioneData(testo: testo ?? this.testo);
  MotivazioneData copyWithCompanion(MotivazioneCompanion data) {
    return MotivazioneData(
      testo: data.testo.present ? data.testo.value : this.testo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MotivazioneData(')
          ..write('testo: $testo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => testo.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MotivazioneData && other.testo == this.testo);
}

class MotivazioneCompanion extends UpdateCompanion<MotivazioneData> {
  final Value<String> testo;
  final Value<int> rowid;
  const MotivazioneCompanion({
    this.testo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MotivazioneCompanion.insert({
    required String testo,
    this.rowid = const Value.absent(),
  }) : testo = Value(testo);
  static Insertable<MotivazioneData> custom({
    Expression<String>? testo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (testo != null) 'testo': testo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MotivazioneCompanion copyWith({Value<String>? testo, Value<int>? rowid}) {
    return MotivazioneCompanion(
      testo: testo ?? this.testo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (testo.present) {
      map['testo'] = Variable<String>(testo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MotivazioneCompanion(')
          ..write('testo: $testo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImpostazioneTable extends Impostazione
    with TableInfo<$ImpostazioneTable, ImpostazioneData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImpostazioneTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cronologiaMeta = const VerificationMeta(
    'cronologia',
  );
  @override
  late final GeneratedColumn<int> cronologia = GeneratedColumn<int>(
    'cronologia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificheMeta = const VerificationMeta(
    'notifiche',
  );
  @override
  late final GeneratedColumn<bool> notifiche = GeneratedColumn<bool>(
    'notifiche',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifiche" IN (0, 1))',
    ),
  );
  static const VerificationMeta _utenteIdMeta = const VerificationMeta(
    'utenteId',
  );
  @override
  late final GeneratedColumn<int> utenteId = GeneratedColumn<int>(
    'utente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES utente (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [cronologia, notifiche, utenteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'impostazione';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImpostazioneData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cronologia')) {
      context.handle(
        _cronologiaMeta,
        cronologia.isAcceptableOrUnknown(data['cronologia']!, _cronologiaMeta),
      );
    } else if (isInserting) {
      context.missing(_cronologiaMeta);
    }
    if (data.containsKey('notifiche')) {
      context.handle(
        _notificheMeta,
        notifiche.isAcceptableOrUnknown(data['notifiche']!, _notificheMeta),
      );
    } else if (isInserting) {
      context.missing(_notificheMeta);
    }
    if (data.containsKey('utente_id')) {
      context.handle(
        _utenteIdMeta,
        utenteId.isAcceptableOrUnknown(data['utente_id']!, _utenteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {utenteId};
  @override
  ImpostazioneData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImpostazioneData(
      cronologia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cronologia'],
      )!,
      notifiche: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifiche'],
      )!,
      utenteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utente_id'],
      )!,
    );
  }

  @override
  $ImpostazioneTable createAlias(String alias) {
    return $ImpostazioneTable(attachedDatabase, alias);
  }
}

class ImpostazioneData extends DataClass
    implements Insertable<ImpostazioneData> {
  final int cronologia;
  final bool notifiche;
  final int utenteId;
  const ImpostazioneData({
    required this.cronologia,
    required this.notifiche,
    required this.utenteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cronologia'] = Variable<int>(cronologia);
    map['notifiche'] = Variable<bool>(notifiche);
    map['utente_id'] = Variable<int>(utenteId);
    return map;
  }

  ImpostazioneCompanion toCompanion(bool nullToAbsent) {
    return ImpostazioneCompanion(
      cronologia: Value(cronologia),
      notifiche: Value(notifiche),
      utenteId: Value(utenteId),
    );
  }

  factory ImpostazioneData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImpostazioneData(
      cronologia: serializer.fromJson<int>(json['cronologia']),
      notifiche: serializer.fromJson<bool>(json['notifiche']),
      utenteId: serializer.fromJson<int>(json['utenteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cronologia': serializer.toJson<int>(cronologia),
      'notifiche': serializer.toJson<bool>(notifiche),
      'utenteId': serializer.toJson<int>(utenteId),
    };
  }

  ImpostazioneData copyWith({
    int? cronologia,
    bool? notifiche,
    int? utenteId,
  }) => ImpostazioneData(
    cronologia: cronologia ?? this.cronologia,
    notifiche: notifiche ?? this.notifiche,
    utenteId: utenteId ?? this.utenteId,
  );
  ImpostazioneData copyWithCompanion(ImpostazioneCompanion data) {
    return ImpostazioneData(
      cronologia: data.cronologia.present
          ? data.cronologia.value
          : this.cronologia,
      notifiche: data.notifiche.present ? data.notifiche.value : this.notifiche,
      utenteId: data.utenteId.present ? data.utenteId.value : this.utenteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImpostazioneData(')
          ..write('cronologia: $cronologia, ')
          ..write('notifiche: $notifiche, ')
          ..write('utenteId: $utenteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cronologia, notifiche, utenteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImpostazioneData &&
          other.cronologia == this.cronologia &&
          other.notifiche == this.notifiche &&
          other.utenteId == this.utenteId);
}

class ImpostazioneCompanion extends UpdateCompanion<ImpostazioneData> {
  final Value<int> cronologia;
  final Value<bool> notifiche;
  final Value<int> utenteId;
  const ImpostazioneCompanion({
    this.cronologia = const Value.absent(),
    this.notifiche = const Value.absent(),
    this.utenteId = const Value.absent(),
  });
  ImpostazioneCompanion.insert({
    required int cronologia,
    required bool notifiche,
    this.utenteId = const Value.absent(),
  }) : cronologia = Value(cronologia),
       notifiche = Value(notifiche);
  static Insertable<ImpostazioneData> custom({
    Expression<int>? cronologia,
    Expression<bool>? notifiche,
    Expression<int>? utenteId,
  }) {
    return RawValuesInsertable({
      if (cronologia != null) 'cronologia': cronologia,
      if (notifiche != null) 'notifiche': notifiche,
      if (utenteId != null) 'utente_id': utenteId,
    });
  }

  ImpostazioneCompanion copyWith({
    Value<int>? cronologia,
    Value<bool>? notifiche,
    Value<int>? utenteId,
  }) {
    return ImpostazioneCompanion(
      cronologia: cronologia ?? this.cronologia,
      notifiche: notifiche ?? this.notifiche,
      utenteId: utenteId ?? this.utenteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cronologia.present) {
      map['cronologia'] = Variable<int>(cronologia.value);
    }
    if (notifiche.present) {
      map['notifiche'] = Variable<bool>(notifiche.value);
    }
    if (utenteId.present) {
      map['utente_id'] = Variable<int>(utenteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImpostazioneCompanion(')
          ..write('cronologia: $cronologia, ')
          ..write('notifiche: $notifiche, ')
          ..write('utenteId: $utenteId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDataBase extends GeneratedDatabase {
  _$AppDataBase(QueryExecutor e) : super(e);
  $AppDataBaseManager get managers => $AppDataBaseManager(this);
  late final $EmozioneTable emozione = $EmozioneTable(this);
  late final $UtenteTable utente = $UtenteTable(this);
  late final $ConsiglioTable consiglio = $ConsiglioTable(this);
  late final $EmozioneRegistrataTable emozioneRegistrata =
      $EmozioneRegistrataTable(this);
  late final $MotivazioneTable motivazione = $MotivazioneTable(this);
  late final $ImpostazioneTable impostazione = $ImpostazioneTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    emozione,
    utente,
    consiglio,
    emozioneRegistrata,
    motivazione,
    impostazione,
  ];
}

typedef $$EmozioneTableCreateCompanionBuilder =
    EmozioneCompanion Function({
      required String nome,
      required String imgPath,
      required int valore,
      Value<int> rowid,
    });
typedef $$EmozioneTableUpdateCompanionBuilder =
    EmozioneCompanion Function({
      Value<String> nome,
      Value<String> imgPath,
      Value<int> valore,
      Value<int> rowid,
    });

final class $$EmozioneTableReferences
    extends BaseReferences<_$AppDataBase, $EmozioneTable, EmozioneData> {
  $$EmozioneTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $EmozioneRegistrataTable,
    List<EmozioneRegistrataData>
  >
  _emozioneRegistrataRefsTable(_$AppDataBase db) =>
      MultiTypedResultKey.fromTable(
        db.emozioneRegistrata,
        aliasName: $_aliasNameGenerator(
          db.emozione.nome,
          db.emozioneRegistrata.emozioneNome,
        ),
      );

  $$EmozioneRegistrataTableProcessedTableManager get emozioneRegistrataRefs {
    final manager =
        $$EmozioneRegistrataTableTableManager(
          $_db,
          $_db.emozioneRegistrata,
        ).filter(
          (f) => f.emozioneNome.nome.sqlEquals($_itemColumn<String>('nome')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _emozioneRegistrataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmozioneTableFilterComposer
    extends Composer<_$AppDataBase, $EmozioneTable> {
  $$EmozioneTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imgPath => $composableBuilder(
    column: $table.imgPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valore => $composableBuilder(
    column: $table.valore,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> emozioneRegistrataRefs(
    Expression<bool> Function($$EmozioneRegistrataTableFilterComposer f) f,
  ) {
    final $$EmozioneRegistrataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nome,
      referencedTable: $db.emozioneRegistrata,
      getReferencedColumn: (t) => t.emozioneNome,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmozioneRegistrataTableFilterComposer(
            $db: $db,
            $table: $db.emozioneRegistrata,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmozioneTableOrderingComposer
    extends Composer<_$AppDataBase, $EmozioneTable> {
  $$EmozioneTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imgPath => $composableBuilder(
    column: $table.imgPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valore => $composableBuilder(
    column: $table.valore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmozioneTableAnnotationComposer
    extends Composer<_$AppDataBase, $EmozioneTable> {
  $$EmozioneTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get imgPath =>
      $composableBuilder(column: $table.imgPath, builder: (column) => column);

  GeneratedColumn<int> get valore =>
      $composableBuilder(column: $table.valore, builder: (column) => column);

  Expression<T> emozioneRegistrataRefs<T extends Object>(
    Expression<T> Function($$EmozioneRegistrataTableAnnotationComposer a) f,
  ) {
    final $$EmozioneRegistrataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.nome,
          referencedTable: $db.emozioneRegistrata,
          getReferencedColumn: (t) => t.emozioneNome,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EmozioneRegistrataTableAnnotationComposer(
                $db: $db,
                $table: $db.emozioneRegistrata,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EmozioneTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $EmozioneTable,
          EmozioneData,
          $$EmozioneTableFilterComposer,
          $$EmozioneTableOrderingComposer,
          $$EmozioneTableAnnotationComposer,
          $$EmozioneTableCreateCompanionBuilder,
          $$EmozioneTableUpdateCompanionBuilder,
          (EmozioneData, $$EmozioneTableReferences),
          EmozioneData,
          PrefetchHooks Function({bool emozioneRegistrataRefs})
        > {
  $$EmozioneTableTableManager(_$AppDataBase db, $EmozioneTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmozioneTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmozioneTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmozioneTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> nome = const Value.absent(),
                Value<String> imgPath = const Value.absent(),
                Value<int> valore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmozioneCompanion(
                nome: nome,
                imgPath: imgPath,
                valore: valore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String nome,
                required String imgPath,
                required int valore,
                Value<int> rowid = const Value.absent(),
              }) => EmozioneCompanion.insert(
                nome: nome,
                imgPath: imgPath,
                valore: valore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmozioneTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({emozioneRegistrataRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (emozioneRegistrataRefs) db.emozioneRegistrata,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (emozioneRegistrataRefs)
                    await $_getPrefetchedData<
                      EmozioneData,
                      $EmozioneTable,
                      EmozioneRegistrataData
                    >(
                      currentTable: table,
                      referencedTable: $$EmozioneTableReferences
                          ._emozioneRegistrataRefsTable(db),
                      managerFromTypedResult: (p0) => $$EmozioneTableReferences(
                        db,
                        table,
                        p0,
                      ).emozioneRegistrataRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.emozioneNome == item.nome,
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

typedef $$EmozioneTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $EmozioneTable,
      EmozioneData,
      $$EmozioneTableFilterComposer,
      $$EmozioneTableOrderingComposer,
      $$EmozioneTableAnnotationComposer,
      $$EmozioneTableCreateCompanionBuilder,
      $$EmozioneTableUpdateCompanionBuilder,
      (EmozioneData, $$EmozioneTableReferences),
      EmozioneData,
      PrefetchHooks Function({bool emozioneRegistrataRefs})
    >;
typedef $$UtenteTableCreateCompanionBuilder =
    UtenteCompanion Function({
      Value<int> id,
      required String username,
      required String nome,
      required DateTime dataNascita,
    });
typedef $$UtenteTableUpdateCompanionBuilder =
    UtenteCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> nome,
      Value<DateTime> dataNascita,
    });

final class $$UtenteTableReferences
    extends BaseReferences<_$AppDataBase, $UtenteTable, UtenteData> {
  $$UtenteTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $EmozioneRegistrataTable,
    List<EmozioneRegistrataData>
  >
  _emozioneRegistrataRefsTable(_$AppDataBase db) =>
      MultiTypedResultKey.fromTable(
        db.emozioneRegistrata,
        aliasName: $_aliasNameGenerator(
          db.utente.id,
          db.emozioneRegistrata.utenteId,
        ),
      );

  $$EmozioneRegistrataTableProcessedTableManager get emozioneRegistrataRefs {
    final manager = $$EmozioneRegistrataTableTableManager(
      $_db,
      $_db.emozioneRegistrata,
    ).filter((f) => f.utenteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _emozioneRegistrataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImpostazioneTable, List<ImpostazioneData>>
  _impostazioneRefsTable(_$AppDataBase db) => MultiTypedResultKey.fromTable(
    db.impostazione,
    aliasName: $_aliasNameGenerator(db.utente.id, db.impostazione.utenteId),
  );

  $$ImpostazioneTableProcessedTableManager get impostazioneRefs {
    final manager = $$ImpostazioneTableTableManager(
      $_db,
      $_db.impostazione,
    ).filter((f) => f.utenteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_impostazioneRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UtenteTableFilterComposer
    extends Composer<_$AppDataBase, $UtenteTable> {
  $$UtenteTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataNascita => $composableBuilder(
    column: $table.dataNascita,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> emozioneRegistrataRefs(
    Expression<bool> Function($$EmozioneRegistrataTableFilterComposer f) f,
  ) {
    final $$EmozioneRegistrataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emozioneRegistrata,
      getReferencedColumn: (t) => t.utenteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmozioneRegistrataTableFilterComposer(
            $db: $db,
            $table: $db.emozioneRegistrata,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> impostazioneRefs(
    Expression<bool> Function($$ImpostazioneTableFilterComposer f) f,
  ) {
    final $$ImpostazioneTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.impostazione,
      getReferencedColumn: (t) => t.utenteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImpostazioneTableFilterComposer(
            $db: $db,
            $table: $db.impostazione,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UtenteTableOrderingComposer
    extends Composer<_$AppDataBase, $UtenteTable> {
  $$UtenteTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataNascita => $composableBuilder(
    column: $table.dataNascita,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UtenteTableAnnotationComposer
    extends Composer<_$AppDataBase, $UtenteTable> {
  $$UtenteTableAnnotationComposer({
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

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<DateTime> get dataNascita => $composableBuilder(
    column: $table.dataNascita,
    builder: (column) => column,
  );

  Expression<T> emozioneRegistrataRefs<T extends Object>(
    Expression<T> Function($$EmozioneRegistrataTableAnnotationComposer a) f,
  ) {
    final $$EmozioneRegistrataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.emozioneRegistrata,
          getReferencedColumn: (t) => t.utenteId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EmozioneRegistrataTableAnnotationComposer(
                $db: $db,
                $table: $db.emozioneRegistrata,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> impostazioneRefs<T extends Object>(
    Expression<T> Function($$ImpostazioneTableAnnotationComposer a) f,
  ) {
    final $$ImpostazioneTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.impostazione,
      getReferencedColumn: (t) => t.utenteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImpostazioneTableAnnotationComposer(
            $db: $db,
            $table: $db.impostazione,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UtenteTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $UtenteTable,
          UtenteData,
          $$UtenteTableFilterComposer,
          $$UtenteTableOrderingComposer,
          $$UtenteTableAnnotationComposer,
          $$UtenteTableCreateCompanionBuilder,
          $$UtenteTableUpdateCompanionBuilder,
          (UtenteData, $$UtenteTableReferences),
          UtenteData,
          PrefetchHooks Function({
            bool emozioneRegistrataRefs,
            bool impostazioneRefs,
          })
        > {
  $$UtenteTableTableManager(_$AppDataBase db, $UtenteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UtenteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UtenteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UtenteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<DateTime> dataNascita = const Value.absent(),
              }) => UtenteCompanion(
                id: id,
                username: username,
                nome: nome,
                dataNascita: dataNascita,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String nome,
                required DateTime dataNascita,
              }) => UtenteCompanion.insert(
                id: id,
                username: username,
                nome: nome,
                dataNascita: dataNascita,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UtenteTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({emozioneRegistrataRefs = false, impostazioneRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (emozioneRegistrataRefs) db.emozioneRegistrata,
                    if (impostazioneRefs) db.impostazione,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (emozioneRegistrataRefs)
                        await $_getPrefetchedData<
                          UtenteData,
                          $UtenteTable,
                          EmozioneRegistrataData
                        >(
                          currentTable: table,
                          referencedTable: $$UtenteTableReferences
                              ._emozioneRegistrataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UtenteTableReferences(
                                db,
                                table,
                                p0,
                              ).emozioneRegistrataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.utenteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (impostazioneRefs)
                        await $_getPrefetchedData<
                          UtenteData,
                          $UtenteTable,
                          ImpostazioneData
                        >(
                          currentTable: table,
                          referencedTable: $$UtenteTableReferences
                              ._impostazioneRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UtenteTableReferences(
                                db,
                                table,
                                p0,
                              ).impostazioneRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.utenteId == item.id,
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

typedef $$UtenteTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $UtenteTable,
      UtenteData,
      $$UtenteTableFilterComposer,
      $$UtenteTableOrderingComposer,
      $$UtenteTableAnnotationComposer,
      $$UtenteTableCreateCompanionBuilder,
      $$UtenteTableUpdateCompanionBuilder,
      (UtenteData, $$UtenteTableReferences),
      UtenteData,
      PrefetchHooks Function({
        bool emozioneRegistrataRefs,
        bool impostazioneRefs,
      })
    >;
typedef $$ConsiglioTableCreateCompanionBuilder =
    ConsiglioCompanion Function({
      Value<int> id,
      required String testo,
      required int valoreIniziale,
      required int valoreFinale,
    });
typedef $$ConsiglioTableUpdateCompanionBuilder =
    ConsiglioCompanion Function({
      Value<int> id,
      Value<String> testo,
      Value<int> valoreIniziale,
      Value<int> valoreFinale,
    });

class $$ConsiglioTableFilterComposer
    extends Composer<_$AppDataBase, $ConsiglioTable> {
  $$ConsiglioTableFilterComposer({
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

  ColumnFilters<String> get testo => $composableBuilder(
    column: $table.testo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valoreIniziale => $composableBuilder(
    column: $table.valoreIniziale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valoreFinale => $composableBuilder(
    column: $table.valoreFinale,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsiglioTableOrderingComposer
    extends Composer<_$AppDataBase, $ConsiglioTable> {
  $$ConsiglioTableOrderingComposer({
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

  ColumnOrderings<String> get testo => $composableBuilder(
    column: $table.testo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valoreIniziale => $composableBuilder(
    column: $table.valoreIniziale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valoreFinale => $composableBuilder(
    column: $table.valoreFinale,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsiglioTableAnnotationComposer
    extends Composer<_$AppDataBase, $ConsiglioTable> {
  $$ConsiglioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get testo =>
      $composableBuilder(column: $table.testo, builder: (column) => column);

  GeneratedColumn<int> get valoreIniziale => $composableBuilder(
    column: $table.valoreIniziale,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valoreFinale => $composableBuilder(
    column: $table.valoreFinale,
    builder: (column) => column,
  );
}

class $$ConsiglioTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $ConsiglioTable,
          ConsiglioData,
          $$ConsiglioTableFilterComposer,
          $$ConsiglioTableOrderingComposer,
          $$ConsiglioTableAnnotationComposer,
          $$ConsiglioTableCreateCompanionBuilder,
          $$ConsiglioTableUpdateCompanionBuilder,
          (
            ConsiglioData,
            BaseReferences<_$AppDataBase, $ConsiglioTable, ConsiglioData>,
          ),
          ConsiglioData,
          PrefetchHooks Function()
        > {
  $$ConsiglioTableTableManager(_$AppDataBase db, $ConsiglioTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsiglioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsiglioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsiglioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> testo = const Value.absent(),
                Value<int> valoreIniziale = const Value.absent(),
                Value<int> valoreFinale = const Value.absent(),
              }) => ConsiglioCompanion(
                id: id,
                testo: testo,
                valoreIniziale: valoreIniziale,
                valoreFinale: valoreFinale,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String testo,
                required int valoreIniziale,
                required int valoreFinale,
              }) => ConsiglioCompanion.insert(
                id: id,
                testo: testo,
                valoreIniziale: valoreIniziale,
                valoreFinale: valoreFinale,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsiglioTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $ConsiglioTable,
      ConsiglioData,
      $$ConsiglioTableFilterComposer,
      $$ConsiglioTableOrderingComposer,
      $$ConsiglioTableAnnotationComposer,
      $$ConsiglioTableCreateCompanionBuilder,
      $$ConsiglioTableUpdateCompanionBuilder,
      (
        ConsiglioData,
        BaseReferences<_$AppDataBase, $ConsiglioTable, ConsiglioData>,
      ),
      ConsiglioData,
      PrefetchHooks Function()
    >;
typedef $$EmozioneRegistrataTableCreateCompanionBuilder =
    EmozioneRegistrataCompanion Function({
      required int utenteId,
      required String emozioneNome,
      required List<String> motivazioneTesto,
      required DateTime dataRegistrazione,
      Value<int> rowid,
    });
typedef $$EmozioneRegistrataTableUpdateCompanionBuilder =
    EmozioneRegistrataCompanion Function({
      Value<int> utenteId,
      Value<String> emozioneNome,
      Value<List<String>> motivazioneTesto,
      Value<DateTime> dataRegistrazione,
      Value<int> rowid,
    });

final class $$EmozioneRegistrataTableReferences
    extends
        BaseReferences<
          _$AppDataBase,
          $EmozioneRegistrataTable,
          EmozioneRegistrataData
        > {
  $$EmozioneRegistrataTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UtenteTable _utenteIdTable(_$AppDataBase db) => db.utente.createAlias(
    $_aliasNameGenerator(db.emozioneRegistrata.utenteId, db.utente.id),
  );

  $$UtenteTableProcessedTableManager get utenteId {
    final $_column = $_itemColumn<int>('utente_id')!;

    final manager = $$UtenteTableTableManager(
      $_db,
      $_db.utente,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utenteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EmozioneTable _emozioneNomeTable(_$AppDataBase db) =>
      db.emozione.createAlias(
        $_aliasNameGenerator(
          db.emozioneRegistrata.emozioneNome,
          db.emozione.nome,
        ),
      );

  $$EmozioneTableProcessedTableManager get emozioneNome {
    final $_column = $_itemColumn<String>('emozione_nome')!;

    final manager = $$EmozioneTableTableManager(
      $_db,
      $_db.emozione,
    ).filter((f) => f.nome.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_emozioneNomeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmozioneRegistrataTableFilterComposer
    extends Composer<_$AppDataBase, $EmozioneRegistrataTable> {
  $$EmozioneRegistrataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get motivazioneTesto => $composableBuilder(
    column: $table.motivazioneTesto,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dataRegistrazione => $composableBuilder(
    column: $table.dataRegistrazione,
    builder: (column) => ColumnFilters(column),
  );

  $$UtenteTableFilterComposer get utenteId {
    final $$UtenteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteId,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtenteTableFilterComposer(
            $db: $db,
            $table: $db.utente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmozioneTableFilterComposer get emozioneNome {
    final $$EmozioneTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emozioneNome,
      referencedTable: $db.emozione,
      getReferencedColumn: (t) => t.nome,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmozioneTableFilterComposer(
            $db: $db,
            $table: $db.emozione,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmozioneRegistrataTableOrderingComposer
    extends Composer<_$AppDataBase, $EmozioneRegistrataTable> {
  $$EmozioneRegistrataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get motivazioneTesto => $composableBuilder(
    column: $table.motivazioneTesto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataRegistrazione => $composableBuilder(
    column: $table.dataRegistrazione,
    builder: (column) => ColumnOrderings(column),
  );

  $$UtenteTableOrderingComposer get utenteId {
    final $$UtenteTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteId,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtenteTableOrderingComposer(
            $db: $db,
            $table: $db.utente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmozioneTableOrderingComposer get emozioneNome {
    final $$EmozioneTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emozioneNome,
      referencedTable: $db.emozione,
      getReferencedColumn: (t) => t.nome,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmozioneTableOrderingComposer(
            $db: $db,
            $table: $db.emozione,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmozioneRegistrataTableAnnotationComposer
    extends Composer<_$AppDataBase, $EmozioneRegistrataTable> {
  $$EmozioneRegistrataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<List<String>, String> get motivazioneTesto =>
      $composableBuilder(
        column: $table.motivazioneTesto,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get dataRegistrazione => $composableBuilder(
    column: $table.dataRegistrazione,
    builder: (column) => column,
  );

  $$UtenteTableAnnotationComposer get utenteId {
    final $$UtenteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteId,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtenteTableAnnotationComposer(
            $db: $db,
            $table: $db.utente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmozioneTableAnnotationComposer get emozioneNome {
    final $$EmozioneTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emozioneNome,
      referencedTable: $db.emozione,
      getReferencedColumn: (t) => t.nome,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmozioneTableAnnotationComposer(
            $db: $db,
            $table: $db.emozione,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmozioneRegistrataTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $EmozioneRegistrataTable,
          EmozioneRegistrataData,
          $$EmozioneRegistrataTableFilterComposer,
          $$EmozioneRegistrataTableOrderingComposer,
          $$EmozioneRegistrataTableAnnotationComposer,
          $$EmozioneRegistrataTableCreateCompanionBuilder,
          $$EmozioneRegistrataTableUpdateCompanionBuilder,
          (EmozioneRegistrataData, $$EmozioneRegistrataTableReferences),
          EmozioneRegistrataData,
          PrefetchHooks Function({bool utenteId, bool emozioneNome})
        > {
  $$EmozioneRegistrataTableTableManager(
    _$AppDataBase db,
    $EmozioneRegistrataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmozioneRegistrataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmozioneRegistrataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmozioneRegistrataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> utenteId = const Value.absent(),
                Value<String> emozioneNome = const Value.absent(),
                Value<List<String>> motivazioneTesto = const Value.absent(),
                Value<DateTime> dataRegistrazione = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmozioneRegistrataCompanion(
                utenteId: utenteId,
                emozioneNome: emozioneNome,
                motivazioneTesto: motivazioneTesto,
                dataRegistrazione: dataRegistrazione,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int utenteId,
                required String emozioneNome,
                required List<String> motivazioneTesto,
                required DateTime dataRegistrazione,
                Value<int> rowid = const Value.absent(),
              }) => EmozioneRegistrataCompanion.insert(
                utenteId: utenteId,
                emozioneNome: emozioneNome,
                motivazioneTesto: motivazioneTesto,
                dataRegistrazione: dataRegistrazione,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmozioneRegistrataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({utenteId = false, emozioneNome = false}) {
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
                    if (utenteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.utenteId,
                                referencedTable:
                                    $$EmozioneRegistrataTableReferences
                                        ._utenteIdTable(db),
                                referencedColumn:
                                    $$EmozioneRegistrataTableReferences
                                        ._utenteIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (emozioneNome) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.emozioneNome,
                                referencedTable:
                                    $$EmozioneRegistrataTableReferences
                                        ._emozioneNomeTable(db),
                                referencedColumn:
                                    $$EmozioneRegistrataTableReferences
                                        ._emozioneNomeTable(db)
                                        .nome,
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

typedef $$EmozioneRegistrataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $EmozioneRegistrataTable,
      EmozioneRegistrataData,
      $$EmozioneRegistrataTableFilterComposer,
      $$EmozioneRegistrataTableOrderingComposer,
      $$EmozioneRegistrataTableAnnotationComposer,
      $$EmozioneRegistrataTableCreateCompanionBuilder,
      $$EmozioneRegistrataTableUpdateCompanionBuilder,
      (EmozioneRegistrataData, $$EmozioneRegistrataTableReferences),
      EmozioneRegistrataData,
      PrefetchHooks Function({bool utenteId, bool emozioneNome})
    >;
typedef $$MotivazioneTableCreateCompanionBuilder =
    MotivazioneCompanion Function({required String testo, Value<int> rowid});
typedef $$MotivazioneTableUpdateCompanionBuilder =
    MotivazioneCompanion Function({Value<String> testo, Value<int> rowid});

class $$MotivazioneTableFilterComposer
    extends Composer<_$AppDataBase, $MotivazioneTable> {
  $$MotivazioneTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get testo => $composableBuilder(
    column: $table.testo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MotivazioneTableOrderingComposer
    extends Composer<_$AppDataBase, $MotivazioneTable> {
  $$MotivazioneTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get testo => $composableBuilder(
    column: $table.testo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MotivazioneTableAnnotationComposer
    extends Composer<_$AppDataBase, $MotivazioneTable> {
  $$MotivazioneTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get testo =>
      $composableBuilder(column: $table.testo, builder: (column) => column);
}

class $$MotivazioneTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $MotivazioneTable,
          MotivazioneData,
          $$MotivazioneTableFilterComposer,
          $$MotivazioneTableOrderingComposer,
          $$MotivazioneTableAnnotationComposer,
          $$MotivazioneTableCreateCompanionBuilder,
          $$MotivazioneTableUpdateCompanionBuilder,
          (
            MotivazioneData,
            BaseReferences<_$AppDataBase, $MotivazioneTable, MotivazioneData>,
          ),
          MotivazioneData,
          PrefetchHooks Function()
        > {
  $$MotivazioneTableTableManager(_$AppDataBase db, $MotivazioneTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MotivazioneTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MotivazioneTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MotivazioneTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> testo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MotivazioneCompanion(testo: testo, rowid: rowid),
          createCompanionCallback:
              ({
                required String testo,
                Value<int> rowid = const Value.absent(),
              }) => MotivazioneCompanion.insert(testo: testo, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MotivazioneTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $MotivazioneTable,
      MotivazioneData,
      $$MotivazioneTableFilterComposer,
      $$MotivazioneTableOrderingComposer,
      $$MotivazioneTableAnnotationComposer,
      $$MotivazioneTableCreateCompanionBuilder,
      $$MotivazioneTableUpdateCompanionBuilder,
      (
        MotivazioneData,
        BaseReferences<_$AppDataBase, $MotivazioneTable, MotivazioneData>,
      ),
      MotivazioneData,
      PrefetchHooks Function()
    >;
typedef $$ImpostazioneTableCreateCompanionBuilder =
    ImpostazioneCompanion Function({
      required int cronologia,
      required bool notifiche,
      Value<int> utenteId,
    });
typedef $$ImpostazioneTableUpdateCompanionBuilder =
    ImpostazioneCompanion Function({
      Value<int> cronologia,
      Value<bool> notifiche,
      Value<int> utenteId,
    });

final class $$ImpostazioneTableReferences
    extends
        BaseReferences<_$AppDataBase, $ImpostazioneTable, ImpostazioneData> {
  $$ImpostazioneTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UtenteTable _utenteIdTable(_$AppDataBase db) => db.utente.createAlias(
    $_aliasNameGenerator(db.impostazione.utenteId, db.utente.id),
  );

  $$UtenteTableProcessedTableManager get utenteId {
    final $_column = $_itemColumn<int>('utente_id')!;

    final manager = $$UtenteTableTableManager(
      $_db,
      $_db.utente,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utenteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImpostazioneTableFilterComposer
    extends Composer<_$AppDataBase, $ImpostazioneTable> {
  $$ImpostazioneTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cronologia => $composableBuilder(
    column: $table.cronologia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifiche => $composableBuilder(
    column: $table.notifiche,
    builder: (column) => ColumnFilters(column),
  );

  $$UtenteTableFilterComposer get utenteId {
    final $$UtenteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteId,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtenteTableFilterComposer(
            $db: $db,
            $table: $db.utente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImpostazioneTableOrderingComposer
    extends Composer<_$AppDataBase, $ImpostazioneTable> {
  $$ImpostazioneTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cronologia => $composableBuilder(
    column: $table.cronologia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifiche => $composableBuilder(
    column: $table.notifiche,
    builder: (column) => ColumnOrderings(column),
  );

  $$UtenteTableOrderingComposer get utenteId {
    final $$UtenteTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteId,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtenteTableOrderingComposer(
            $db: $db,
            $table: $db.utente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImpostazioneTableAnnotationComposer
    extends Composer<_$AppDataBase, $ImpostazioneTable> {
  $$ImpostazioneTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cronologia => $composableBuilder(
    column: $table.cronologia,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifiche =>
      $composableBuilder(column: $table.notifiche, builder: (column) => column);

  $$UtenteTableAnnotationComposer get utenteId {
    final $$UtenteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteId,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtenteTableAnnotationComposer(
            $db: $db,
            $table: $db.utente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImpostazioneTableTableManager
    extends
        RootTableManager<
          _$AppDataBase,
          $ImpostazioneTable,
          ImpostazioneData,
          $$ImpostazioneTableFilterComposer,
          $$ImpostazioneTableOrderingComposer,
          $$ImpostazioneTableAnnotationComposer,
          $$ImpostazioneTableCreateCompanionBuilder,
          $$ImpostazioneTableUpdateCompanionBuilder,
          (ImpostazioneData, $$ImpostazioneTableReferences),
          ImpostazioneData,
          PrefetchHooks Function({bool utenteId})
        > {
  $$ImpostazioneTableTableManager(_$AppDataBase db, $ImpostazioneTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImpostazioneTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImpostazioneTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImpostazioneTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> cronologia = const Value.absent(),
                Value<bool> notifiche = const Value.absent(),
                Value<int> utenteId = const Value.absent(),
              }) => ImpostazioneCompanion(
                cronologia: cronologia,
                notifiche: notifiche,
                utenteId: utenteId,
              ),
          createCompanionCallback:
              ({
                required int cronologia,
                required bool notifiche,
                Value<int> utenteId = const Value.absent(),
              }) => ImpostazioneCompanion.insert(
                cronologia: cronologia,
                notifiche: notifiche,
                utenteId: utenteId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImpostazioneTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({utenteId = false}) {
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
                    if (utenteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.utenteId,
                                referencedTable: $$ImpostazioneTableReferences
                                    ._utenteIdTable(db),
                                referencedColumn: $$ImpostazioneTableReferences
                                    ._utenteIdTable(db)
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

typedef $$ImpostazioneTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDataBase,
      $ImpostazioneTable,
      ImpostazioneData,
      $$ImpostazioneTableFilterComposer,
      $$ImpostazioneTableOrderingComposer,
      $$ImpostazioneTableAnnotationComposer,
      $$ImpostazioneTableCreateCompanionBuilder,
      $$ImpostazioneTableUpdateCompanionBuilder,
      (ImpostazioneData, $$ImpostazioneTableReferences),
      ImpostazioneData,
      PrefetchHooks Function({bool utenteId})
    >;

class $AppDataBaseManager {
  final _$AppDataBase _db;
  $AppDataBaseManager(this._db);
  $$EmozioneTableTableManager get emozione =>
      $$EmozioneTableTableManager(_db, _db.emozione);
  $$UtenteTableTableManager get utente =>
      $$UtenteTableTableManager(_db, _db.utente);
  $$ConsiglioTableTableManager get consiglio =>
      $$ConsiglioTableTableManager(_db, _db.consiglio);
  $$EmozioneRegistrataTableTableManager get emozioneRegistrata =>
      $$EmozioneRegistrataTableTableManager(_db, _db.emozioneRegistrata);
  $$MotivazioneTableTableManager get motivazione =>
      $$MotivazioneTableTableManager(_db, _db.motivazione);
  $$ImpostazioneTableTableManager get impostazione =>
      $$ImpostazioneTableTableManager(_db, _db.impostazione);
}
