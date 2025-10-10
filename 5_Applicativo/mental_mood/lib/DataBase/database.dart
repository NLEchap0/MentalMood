import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
part 'database.g.dart';

class Emozione extends Table{ //the emotion table of the database
  TextColumn get nome => text()(); //the name value of the emotion
  TextColumn get imgPath => text()(); //the path of the image of the emotion
  IntColumn get valore => integer()(); //the value of the emotion
  @override
  Set<Column> get primaryKey => {nome};
}

class Utente extends Table{ //the user table of the database
  TextColumn get username=> text()(); //the username of the user
  TextColumn get nome => text()(); //the full name of the user
  IntColumn get dataNascita => integer()(); //the date of birth of the user
  @override
  Set<Column> get primaryKey => {username};
}

class Consiglio extends Table{ //the advice table of the database
  IntColumn get id => integer().autoIncrement()(); //the id of the advice
  TextColumn get testo => text()(); //the content of the advice
  IntColumn get valoreIniziale => integer()(); //the initial value of the advice
  IntColumn get valoreFinale => integer()(); //the final value of the advice
  @override
  Set<Column> get primaryKey => {id};
}


class EmozioneRegistrata extends Table {
  TextColumn get utenteUsername => text().references(Utente, #username)();
  TextColumn get emozioneNome => text().references(Emozione, #nome)();
  DateTimeColumn get dataRegistrazione => dateTime()();
  @override
  Set<Column> get primaryKey => {utenteUsername, emozioneNome, dataRegistrazione};
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
@DriftDatabase(tables: [Emozione, Utente, Consiglio, EmozioneRegistrata])
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
  Future<List<EmozioneRegistrataData>> getEmozioneRegistrataList() async{
    return await select(emozioneRegistrata).get();
  }
}

