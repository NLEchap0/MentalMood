import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_mood/Utils/database_util.dart';
import 'DataBase/database.dart';
import 'Pages/UserSelectionPage/user_selection_page.dart';

void main() async {
  //Assicura inizializzazione di FlutterBinding (necessario per Provider)
  WidgetsFlutterBinding.ensureInitialized();

  try {
    //Inizializzazione database
    final db = AppDataBase();

    //Popolamento predefiniti: emozioni, motivazioni, consigli
    DatabaseUtil dbUtil = DatabaseUtil();
    await dbUtil.populateDefaultEmotions(db);
    await dbUtil.populateDefaultMotivations(db);
    await dbUtil.populateDefaultSuggestions(db);

    runApp(
      Provider(
        create: (_) => db,
        dispose: (_, AppDataBase db) => db.close(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false, // Toglie il banner di debug in fase di sviluppo
          home: UserSelectionPage(), // Fa visualizzare la pagina di selezione dell'utente
        ),
      ),
    );
  } catch (e) {
    print('ERRORE CRITICO: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Errore: $e'),
          ),
        ),
      ),
    );
  }
}