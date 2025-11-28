import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_mood/Utils/database_util.dart';
import 'DataBase/database.dart';
import 'Pages/UserSelectionPage/user_selection_page.dart';
import 'Utils/NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza notifiche
  await NotificationService().initNotification();

  try {
    //Inizializzazione database...
    final db = AppDataBase();

    //Popolamento emozioni predefinite
    DatabaseUtil dbUtil = DatabaseUtil();
    await dbUtil.populateDefaultEmotions(db);
    await dbUtil.populateDefaultMotivations(db);
    await dbUtil.populateDefaultSuggestions(db);

    runApp(
      Provider(
        create: (_) => db,
        dispose: (_, AppDataBase db) => db.close(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          //home: UserSelectionPage(),
          home: UserSelectionPage(),
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