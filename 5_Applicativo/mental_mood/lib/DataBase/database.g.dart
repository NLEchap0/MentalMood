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
  List<GeneratedColumn> get $columns => [username, nome, dataNascita];
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
  Set<GeneratedColumn> get $primaryKey => {username};
  @override
  UtenteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UtenteData(
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
  final String username;
  final String nome;
  final DateTime dataNascita;
  const UtenteData({
    required this.username,
    required this.nome,
    required this.dataNascita,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['username'] = Variable<String>(username);
    map['nome'] = Variable<String>(nome);
    map['data_nascita'] = Variable<DateTime>(dataNascita);
    return map;
  }

  UtenteCompanion toCompanion(bool nullToAbsent) {
    return UtenteCompanion(
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
      username: serializer.fromJson<String>(json['username']),
      nome: serializer.fromJson<String>(json['nome']),
      dataNascita: serializer.fromJson<DateTime>(json['dataNascita']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'username': serializer.toJson<String>(username),
      'nome': serializer.toJson<String>(nome),
      'dataNascita': serializer.toJson<DateTime>(dataNascita),
    };
  }

  UtenteData copyWith({
    String? username,
    String? nome,
    DateTime? dataNascita,
  }) => UtenteData(
    username: username ?? this.username,
    nome: nome ?? this.nome,
    dataNascita: dataNascita ?? this.dataNascita,
  );
  UtenteData copyWithCompanion(UtenteCompanion data) {
    return UtenteData(
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
          ..write('username: $username, ')
          ..write('nome: $nome, ')
          ..write('dataNascita: $dataNascita')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(username, nome, dataNascita);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UtenteData &&
          other.username == this.username &&
          other.nome == this.nome &&
          other.dataNascita == this.dataNascita);
}

class UtenteCompanion extends UpdateCompanion<UtenteData> {
  final Value<String> username;
  final Value<String> nome;
  final Value<DateTime> dataNascita;
  final Value<int> rowid;
  const UtenteCompanion({
    this.username = const Value.absent(),
    this.nome = const Value.absent(),
    this.dataNascita = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UtenteCompanion.insert({
    required String username,
    required String nome,
    required DateTime dataNascita,
    this.rowid = const Value.absent(),
  }) : username = Value(username),
       nome = Value(nome),
       dataNascita = Value(dataNascita);
  static Insertable<UtenteData> custom({
    Expression<String>? username,
    Expression<String>? nome,
    Expression<DateTime>? dataNascita,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (username != null) 'username': username,
      if (nome != null) 'nome': nome,
      if (dataNascita != null) 'data_nascita': dataNascita,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UtenteCompanion copyWith({
    Value<String>? username,
    Value<String>? nome,
    Value<DateTime>? dataNascita,
    Value<int>? rowid,
  }) {
    return UtenteCompanion(
      username: username ?? this.username,
      nome: nome ?? this.nome,
      dataNascita: dataNascita ?? this.dataNascita,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (dataNascita.present) {
      map['data_nascita'] = Variable<DateTime>(dataNascita.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtenteCompanion(')
          ..write('username: $username, ')
          ..write('nome: $nome, ')
          ..write('dataNascita: $dataNascita, ')
          ..write('rowid: $rowid')
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

class $EmozioneRegistrataTable extends EmozioneRegistrata
    with TableInfo<$EmozioneRegistrataTable, EmozioneRegistrataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmozioneRegistrataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _utenteUsernameMeta = const VerificationMeta(
    'utenteUsername',
  );
  @override
  late final GeneratedColumn<String> utenteUsername = GeneratedColumn<String>(
    'utente_username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES utente (username)',
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
  static const VerificationMeta _motivazioneTestoMeta = const VerificationMeta(
    'motivazioneTesto',
  );
  @override
  late final GeneratedColumn<String> motivazioneTesto = GeneratedColumn<String>(
    'motivazione_testo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motivazione (testo)',
    ),
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
    utenteUsername,
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
    if (data.containsKey('utente_username')) {
      context.handle(
        _utenteUsernameMeta,
        utenteUsername.isAcceptableOrUnknown(
          data['utente_username']!,
          _utenteUsernameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utenteUsernameMeta);
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
    if (data.containsKey('motivazione_testo')) {
      context.handle(
        _motivazioneTestoMeta,
        motivazioneTesto.isAcceptableOrUnknown(
          data['motivazione_testo']!,
          _motivazioneTestoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motivazioneTestoMeta);
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
    utenteUsername,
    emozioneNome,
    motivazioneTesto,
    dataRegistrazione,
  };
  @override
  EmozioneRegistrataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmozioneRegistrataData(
      utenteUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utente_username'],
      )!,
      emozioneNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emozione_nome'],
      )!,
      motivazioneTesto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivazione_testo'],
      )!,
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
}

class EmozioneRegistrataData extends DataClass
    implements Insertable<EmozioneRegistrataData> {
  final String utenteUsername;
  final String emozioneNome;
  final String motivazioneTesto;
  final DateTime dataRegistrazione;
  const EmozioneRegistrataData({
    required this.utenteUsername,
    required this.emozioneNome,
    required this.motivazioneTesto,
    required this.dataRegistrazione,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['utente_username'] = Variable<String>(utenteUsername);
    map['emozione_nome'] = Variable<String>(emozioneNome);
    map['motivazione_testo'] = Variable<String>(motivazioneTesto);
    map['data_registrazione'] = Variable<DateTime>(dataRegistrazione);
    return map;
  }

  EmozioneRegistrataCompanion toCompanion(bool nullToAbsent) {
    return EmozioneRegistrataCompanion(
      utenteUsername: Value(utenteUsername),
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
      utenteUsername: serializer.fromJson<String>(json['utenteUsername']),
      emozioneNome: serializer.fromJson<String>(json['emozioneNome']),
      motivazioneTesto: serializer.fromJson<String>(json['motivazioneTesto']),
      dataRegistrazione: serializer.fromJson<DateTime>(
        json['dataRegistrazione'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'utenteUsername': serializer.toJson<String>(utenteUsername),
      'emozioneNome': serializer.toJson<String>(emozioneNome),
      'motivazioneTesto': serializer.toJson<String>(motivazioneTesto),
      'dataRegistrazione': serializer.toJson<DateTime>(dataRegistrazione),
    };
  }

  EmozioneRegistrataData copyWith({
    String? utenteUsername,
    String? emozioneNome,
    String? motivazioneTesto,
    DateTime? dataRegistrazione,
  }) => EmozioneRegistrataData(
    utenteUsername: utenteUsername ?? this.utenteUsername,
    emozioneNome: emozioneNome ?? this.emozioneNome,
    motivazioneTesto: motivazioneTesto ?? this.motivazioneTesto,
    dataRegistrazione: dataRegistrazione ?? this.dataRegistrazione,
  );
  EmozioneRegistrataData copyWithCompanion(EmozioneRegistrataCompanion data) {
    return EmozioneRegistrataData(
      utenteUsername: data.utenteUsername.present
          ? data.utenteUsername.value
          : this.utenteUsername,
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
          ..write('utenteUsername: $utenteUsername, ')
          ..write('emozioneNome: $emozioneNome, ')
          ..write('motivazioneTesto: $motivazioneTesto, ')
          ..write('dataRegistrazione: $dataRegistrazione')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    utenteUsername,
    emozioneNome,
    motivazioneTesto,
    dataRegistrazione,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmozioneRegistrataData &&
          other.utenteUsername == this.utenteUsername &&
          other.emozioneNome == this.emozioneNome &&
          other.motivazioneTesto == this.motivazioneTesto &&
          other.dataRegistrazione == this.dataRegistrazione);
}

class EmozioneRegistrataCompanion
    extends UpdateCompanion<EmozioneRegistrataData> {
  final Value<String> utenteUsername;
  final Value<String> emozioneNome;
  final Value<String> motivazioneTesto;
  final Value<DateTime> dataRegistrazione;
  final Value<int> rowid;
  const EmozioneRegistrataCompanion({
    this.utenteUsername = const Value.absent(),
    this.emozioneNome = const Value.absent(),
    this.motivazioneTesto = const Value.absent(),
    this.dataRegistrazione = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmozioneRegistrataCompanion.insert({
    required String utenteUsername,
    required String emozioneNome,
    required String motivazioneTesto,
    required DateTime dataRegistrazione,
    this.rowid = const Value.absent(),
  }) : utenteUsername = Value(utenteUsername),
       emozioneNome = Value(emozioneNome),
       motivazioneTesto = Value(motivazioneTesto),
       dataRegistrazione = Value(dataRegistrazione);
  static Insertable<EmozioneRegistrataData> custom({
    Expression<String>? utenteUsername,
    Expression<String>? emozioneNome,
    Expression<String>? motivazioneTesto,
    Expression<DateTime>? dataRegistrazione,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (utenteUsername != null) 'utente_username': utenteUsername,
      if (emozioneNome != null) 'emozione_nome': emozioneNome,
      if (motivazioneTesto != null) 'motivazione_testo': motivazioneTesto,
      if (dataRegistrazione != null) 'data_registrazione': dataRegistrazione,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmozioneRegistrataCompanion copyWith({
    Value<String>? utenteUsername,
    Value<String>? emozioneNome,
    Value<String>? motivazioneTesto,
    Value<DateTime>? dataRegistrazione,
    Value<int>? rowid,
  }) {
    return EmozioneRegistrataCompanion(
      utenteUsername: utenteUsername ?? this.utenteUsername,
      emozioneNome: emozioneNome ?? this.emozioneNome,
      motivazioneTesto: motivazioneTesto ?? this.motivazioneTesto,
      dataRegistrazione: dataRegistrazione ?? this.dataRegistrazione,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (utenteUsername.present) {
      map['utente_username'] = Variable<String>(utenteUsername.value);
    }
    if (emozioneNome.present) {
      map['emozione_nome'] = Variable<String>(emozioneNome.value);
    }
    if (motivazioneTesto.present) {
      map['motivazione_testo'] = Variable<String>(motivazioneTesto.value);
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
          ..write('utenteUsername: $utenteUsername, ')
          ..write('emozioneNome: $emozioneNome, ')
          ..write('motivazioneTesto: $motivazioneTesto, ')
          ..write('dataRegistrazione: $dataRegistrazione, ')
          ..write('rowid: $rowid')
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
  late final $MotivazioneTable motivazione = $MotivazioneTable(this);
  late final $EmozioneRegistrataTable emozioneRegistrata =
      $EmozioneRegistrataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    emozione,
    utente,
    consiglio,
    motivazione,
    emozioneRegistrata,
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
      required String username,
      required String nome,
      required DateTime dataNascita,
      Value<int> rowid,
    });
typedef $$UtenteTableUpdateCompanionBuilder =
    UtenteCompanion Function({
      Value<String> username,
      Value<String> nome,
      Value<DateTime> dataNascita,
      Value<int> rowid,
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
          db.utente.username,
          db.emozioneRegistrata.utenteUsername,
        ),
      );

  $$EmozioneRegistrataTableProcessedTableManager get emozioneRegistrataRefs {
    final manager =
        $$EmozioneRegistrataTableTableManager(
          $_db,
          $_db.emozioneRegistrata,
        ).filter(
          (f) => f.utenteUsername.username.sqlEquals(
            $_itemColumn<String>('username')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _emozioneRegistrataRefsTable($_db),
    );
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
      getCurrentColumn: (t) => t.username,
      referencedTable: $db.emozioneRegistrata,
      getReferencedColumn: (t) => t.utenteUsername,
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

class $$UtenteTableOrderingComposer
    extends Composer<_$AppDataBase, $UtenteTable> {
  $$UtenteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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
          getCurrentColumn: (t) => t.username,
          referencedTable: $db.emozioneRegistrata,
          getReferencedColumn: (t) => t.utenteUsername,
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
          PrefetchHooks Function({bool emozioneRegistrataRefs})
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
                Value<String> username = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<DateTime> dataNascita = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UtenteCompanion(
                username: username,
                nome: nome,
                dataNascita: dataNascita,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String username,
                required String nome,
                required DateTime dataNascita,
                Value<int> rowid = const Value.absent(),
              }) => UtenteCompanion.insert(
                username: username,
                nome: nome,
                dataNascita: dataNascita,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UtenteTableReferences(db, table, e)),
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
                      UtenteData,
                      $UtenteTable,
                      EmozioneRegistrataData
                    >(
                      currentTable: table,
                      referencedTable: $$UtenteTableReferences
                          ._emozioneRegistrataRefsTable(db),
                      managerFromTypedResult: (p0) => $$UtenteTableReferences(
                        db,
                        table,
                        p0,
                      ).emozioneRegistrataRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.utenteUsername == item.username,
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
      PrefetchHooks Function({bool emozioneRegistrataRefs})
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
typedef $$MotivazioneTableCreateCompanionBuilder =
    MotivazioneCompanion Function({required String testo, Value<int> rowid});
typedef $$MotivazioneTableUpdateCompanionBuilder =
    MotivazioneCompanion Function({Value<String> testo, Value<int> rowid});

final class $$MotivazioneTableReferences
    extends BaseReferences<_$AppDataBase, $MotivazioneTable, MotivazioneData> {
  $$MotivazioneTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $EmozioneRegistrataTable,
    List<EmozioneRegistrataData>
  >
  _emozioneRegistrataRefsTable(_$AppDataBase db) =>
      MultiTypedResultKey.fromTable(
        db.emozioneRegistrata,
        aliasName: $_aliasNameGenerator(
          db.motivazione.testo,
          db.emozioneRegistrata.motivazioneTesto,
        ),
      );

  $$EmozioneRegistrataTableProcessedTableManager get emozioneRegistrataRefs {
    final manager =
        $$EmozioneRegistrataTableTableManager(
          $_db,
          $_db.emozioneRegistrata,
        ).filter(
          (f) => f.motivazioneTesto.testo.sqlEquals(
            $_itemColumn<String>('testo')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _emozioneRegistrataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> emozioneRegistrataRefs(
    Expression<bool> Function($$EmozioneRegistrataTableFilterComposer f) f,
  ) {
    final $$EmozioneRegistrataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.testo,
      referencedTable: $db.emozioneRegistrata,
      getReferencedColumn: (t) => t.motivazioneTesto,
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

  Expression<T> emozioneRegistrataRefs<T extends Object>(
    Expression<T> Function($$EmozioneRegistrataTableAnnotationComposer a) f,
  ) {
    final $$EmozioneRegistrataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.testo,
          referencedTable: $db.emozioneRegistrata,
          getReferencedColumn: (t) => t.motivazioneTesto,
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
          (MotivazioneData, $$MotivazioneTableReferences),
          MotivazioneData,
          PrefetchHooks Function({bool emozioneRegistrataRefs})
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$MotivazioneTableReferences(db, table, e),
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
                      MotivazioneData,
                      $MotivazioneTable,
                      EmozioneRegistrataData
                    >(
                      currentTable: table,
                      referencedTable: $$MotivazioneTableReferences
                          ._emozioneRegistrataRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MotivazioneTableReferences(
                            db,
                            table,
                            p0,
                          ).emozioneRegistrataRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.motivazioneTesto == item.testo,
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
      (MotivazioneData, $$MotivazioneTableReferences),
      MotivazioneData,
      PrefetchHooks Function({bool emozioneRegistrataRefs})
    >;
typedef $$EmozioneRegistrataTableCreateCompanionBuilder =
    EmozioneRegistrataCompanion Function({
      required String utenteUsername,
      required String emozioneNome,
      required String motivazioneTesto,
      required DateTime dataRegistrazione,
      Value<int> rowid,
    });
typedef $$EmozioneRegistrataTableUpdateCompanionBuilder =
    EmozioneRegistrataCompanion Function({
      Value<String> utenteUsername,
      Value<String> emozioneNome,
      Value<String> motivazioneTesto,
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

  static $UtenteTable _utenteUsernameTable(_$AppDataBase db) =>
      db.utente.createAlias(
        $_aliasNameGenerator(
          db.emozioneRegistrata.utenteUsername,
          db.utente.username,
        ),
      );

  $$UtenteTableProcessedTableManager get utenteUsername {
    final $_column = $_itemColumn<String>('utente_username')!;

    final manager = $$UtenteTableTableManager(
      $_db,
      $_db.utente,
    ).filter((f) => f.username.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utenteUsernameTable($_db));
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

  static $MotivazioneTable _motivazioneTestoTable(_$AppDataBase db) =>
      db.motivazione.createAlias(
        $_aliasNameGenerator(
          db.emozioneRegistrata.motivazioneTesto,
          db.motivazione.testo,
        ),
      );

  $$MotivazioneTableProcessedTableManager get motivazioneTesto {
    final $_column = $_itemColumn<String>('motivazione_testo')!;

    final manager = $$MotivazioneTableTableManager(
      $_db,
      $_db.motivazione,
    ).filter((f) => f.testo.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motivazioneTestoTable($_db));
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
  ColumnFilters<DateTime> get dataRegistrazione => $composableBuilder(
    column: $table.dataRegistrazione,
    builder: (column) => ColumnFilters(column),
  );

  $$UtenteTableFilterComposer get utenteUsername {
    final $$UtenteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteUsername,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.username,
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

  $$MotivazioneTableFilterComposer get motivazioneTesto {
    final $$MotivazioneTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motivazioneTesto,
      referencedTable: $db.motivazione,
      getReferencedColumn: (t) => t.testo,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotivazioneTableFilterComposer(
            $db: $db,
            $table: $db.motivazione,
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
  ColumnOrderings<DateTime> get dataRegistrazione => $composableBuilder(
    column: $table.dataRegistrazione,
    builder: (column) => ColumnOrderings(column),
  );

  $$UtenteTableOrderingComposer get utenteUsername {
    final $$UtenteTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteUsername,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.username,
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

  $$MotivazioneTableOrderingComposer get motivazioneTesto {
    final $$MotivazioneTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motivazioneTesto,
      referencedTable: $db.motivazione,
      getReferencedColumn: (t) => t.testo,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotivazioneTableOrderingComposer(
            $db: $db,
            $table: $db.motivazione,
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
  GeneratedColumn<DateTime> get dataRegistrazione => $composableBuilder(
    column: $table.dataRegistrazione,
    builder: (column) => column,
  );

  $$UtenteTableAnnotationComposer get utenteUsername {
    final $$UtenteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utenteUsername,
      referencedTable: $db.utente,
      getReferencedColumn: (t) => t.username,
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

  $$MotivazioneTableAnnotationComposer get motivazioneTesto {
    final $$MotivazioneTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motivazioneTesto,
      referencedTable: $db.motivazione,
      getReferencedColumn: (t) => t.testo,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotivazioneTableAnnotationComposer(
            $db: $db,
            $table: $db.motivazione,
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
          PrefetchHooks Function({
            bool utenteUsername,
            bool emozioneNome,
            bool motivazioneTesto,
          })
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
                Value<String> utenteUsername = const Value.absent(),
                Value<String> emozioneNome = const Value.absent(),
                Value<String> motivazioneTesto = const Value.absent(),
                Value<DateTime> dataRegistrazione = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmozioneRegistrataCompanion(
                utenteUsername: utenteUsername,
                emozioneNome: emozioneNome,
                motivazioneTesto: motivazioneTesto,
                dataRegistrazione: dataRegistrazione,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String utenteUsername,
                required String emozioneNome,
                required String motivazioneTesto,
                required DateTime dataRegistrazione,
                Value<int> rowid = const Value.absent(),
              }) => EmozioneRegistrataCompanion.insert(
                utenteUsername: utenteUsername,
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
          prefetchHooksCallback:
              ({
                utenteUsername = false,
                emozioneNome = false,
                motivazioneTesto = false,
              }) {
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
                        if (utenteUsername) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.utenteUsername,
                                    referencedTable:
                                        $$EmozioneRegistrataTableReferences
                                            ._utenteUsernameTable(db),
                                    referencedColumn:
                                        $$EmozioneRegistrataTableReferences
                                            ._utenteUsernameTable(db)
                                            .username,
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
                        if (motivazioneTesto) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motivazioneTesto,
                                    referencedTable:
                                        $$EmozioneRegistrataTableReferences
                                            ._motivazioneTestoTable(db),
                                    referencedColumn:
                                        $$EmozioneRegistrataTableReferences
                                            ._motivazioneTestoTable(db)
                                            .testo,
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
      PrefetchHooks Function({
        bool utenteUsername,
        bool emozioneNome,
        bool motivazioneTesto,
      })
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
  $$MotivazioneTableTableManager get motivazione =>
      $$MotivazioneTableTableManager(_db, _db.motivazione);
  $$EmozioneRegistrataTableTableManager get emozioneRegistrata =>
      $$EmozioneRegistrataTableTableManager(_db, _db.emozioneRegistrata);
}
