import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
part 'database.g.dart';


// Questo convertitore gestisce la trasformazione tra List<String> e String JSON
class StringListConverter extends TypeConverter<List<String>, String> {
  // Converte List<String> in String (per il salvataggio nel DB)
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return [];
    }
    // Assumendo che il JSON sia salvato come '[ "motivo1", "motivo2" ]'
    // Usiamo dart:convert per decodificare il JSON
    final decoded = json.decode(fromDb) as List;
    return decoded.map((e) => e.toString()).toList();
  }

  // Converte String in List<String> (per l'utilizzo nell'app)
  @override
  String toSql(List<String> value) {
    // Usiamo dart:convert per codificare la List<String> in una stringa JSON
    return json.encode(value);
  }
}

class Motivazione extends Table{ //the motivation table of the database
  TextColumn get testo => text()(); //the text of the motivation
  @override
  Set<Column> get primaryKey => {testo};
}

class Impostazione extends Table{ //the settings table of the database
  IntColumn get cronologia => integer()(); //the chronology of the settings
  BoolColumn get notifiche => boolean()(); //the notifications of the settings
  IntColumn get utenteId => integer().references(Utente, #id)(); //the id of the user
  @override
  Set<Column> get primaryKey => {utenteId};
}

class Emozione extends Table{ //the emotion table of the database
  TextColumn get nome => text()(); //the name value of the emotion
  TextColumn get imgPath => text()(); //the path of the image of the emotion
  IntColumn get valore => integer()(); //the value of the emotion
  @override
  Set<Column> get primaryKey => {nome};
}

class Utente extends Table{ //the user table of the database
  IntColumn get id => integer().autoIncrement()(); //the id of the user
  TextColumn get username=> text()(); //the username of the user
  TextColumn get nome => text()(); //the name of the user
  DateTimeColumn get dataNascita => dateTime()(); //the date of birth of the user
}

class Consiglio extends Table{ //the advice table of the database
  IntColumn get id => integer().autoIncrement()(); //the id of the advice
  TextColumn get testo => text()(); //the content of the advice
  IntColumn get valoreIniziale => integer()(); //the initial value of the advice
  IntColumn get valoreFinale => integer()(); //the final value of the advice
}

// Join table of Emozione, Utente & Motivazione, with the date of registration
class EmozioneRegistrata extends Table {
  IntColumn get utenteId => integer().references(Utente, #id)();
  TextColumn get emozioneNome => text().references(Emozione, #nome)();
  TextColumn get motivazioneTesto => text().map(StringListConverter())();
  DateTimeColumn get dataRegistrazione => dateTime()();
  @override
  Set<Column> get primaryKey => {utenteId, emozioneNome, dataRegistrazione};
}

LazyDatabase _openConnection(){
  // The LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async{
    // Put the database file, called db.sqlite here,
    // into the documents folder for your app.
    final dbFolder = await  getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path,'db.sqlite'));
    return NativeDatabase(file);
  });
}

// This annotation tells drift to prepare a database
// class that uses the tables we just defined.
@DriftDatabase(tables: [Emozione, Utente, Consiglio, EmozioneRegistrata, Motivazione, Impostazione])
class AppDataBase extends _$AppDataBase{
  // We tell the database where to store the data with this constructor.
  AppDataBase(): super(_openConnection());

  @override
  int get schemaVersion => 1; //the version of the database

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Durante lo sviluppo, la destructiveFallback è la via più semplice.
        // ATTENZIONE: Questo cancellerà tutti i dati utente in caso di upgrade.
        // Va bene per lo sviluppo, ma non per la produzione.
        if (from < 2) { // Esempio per future migrazioni
          // codice per migrare dalla versione 1 alla 2
        }
      },
    );
  }

  // Get all the emotions from DB
  Future<List<EmozioneData>> getEmozioneList() async{
    return await select(emozione).get();
  }
  Future<List<UtenteData>> getUtenteList() async{
    return await select(utente).get();
  }
  Future<List<ConsiglioData>> getConsiglioList() async{
    return await select(consiglio).get();
  }
  Future<List<MotivazioneData>> getMotivazioneList() async{
    return await select(motivazione).get();
  }
  Future<List<ImpostazioneData>> getImpostazioni(idUtente) async{
    return await (select(impostazione)..where((tbl) => tbl.utenteId.equals(idUtente))).get();
  }

  Future<void> deleteMotivazione(testo) async {
    await (delete(motivazione)..where((tbl) => tbl.testo.equals(testo))).go();
  }

  Future<void> deleteEmozione(nome) async {
    await (delete(emozione)..where((tbl) => tbl.nome.equals(nome))).go();
  }

  Future<void> insertUtente(UtenteCompanion utente) async {
    await into(this.utente).insert(utente);
  }

  Future<void> deleteUser(id) async {
    await (delete(utente)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteUsers(utenti) async {
    await delete(utenti).go();
  }

  Future<int> insertEmozioneRegistrata(EmozioneRegistrataCompanion entry) async {
    return into(emozioneRegistrata).insert(entry);
  }

  Future<List<EmozioneRegistrataData>> getEmozioniRegistrateByUserId(int userId) {
    // Query per selezionare tutti i record di EmozioneRegistrata
    return (select(emozioneRegistrata)
    // Filtra solo quelli con l'utenteId corrispondente
      ..where((e) => e.utenteId.equals(userId))
    // Ordina per dataRegistrazione in modo decrescente (i più recenti in alto)
      ..orderBy([
            (t) => OrderingTerm(expression: t.dataRegistrazione, mode: OrderingMode.desc)
      ])
    ).get();
  }

  Future<EmozioneData> getEmozioneByName(String nomeEmozione) {
    return (
      select(emozione)
        ..where((e) => e.nome.equals(nomeEmozione))
      ).getSingle();
  }

  Future<void> updateImpostazioni(ImpostazioneCompanion entry) {
    return (update(impostazione)..where((t) => t.utenteId.equals(entry.utenteId.value))).write(entry);
  }

  Future<int> deleteOldEmozioniRegistrate(int days) async {
    final limitDate = DateTime.now().subtract(Duration(days: days));

    return await (delete(emozioneRegistrata)
      ..where((t) => t.dataRegistrazione.isSmallerThanValue(limitDate))
    ).go();
  }
}

