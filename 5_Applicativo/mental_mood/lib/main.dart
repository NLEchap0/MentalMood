import 'package:flutter/material.dart';
import 'package:mental_mood/Pages/emotion_selection_page.dart';
import 'package:provider/provider.dart';
import 'package:mental_mood/Utils/database_util.dart';

import 'DataBase/database.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    //Inizializzazione database...
    final db = AppDataBase();

    //Popolamento emozioni predefinite
    DatabaseUtil dbUtil = DatabaseUtil();
    await dbUtil.populateDefaultEmotions(db);

    runApp(
      Provider(
        create: (_) => db,
        dispose: (_, AppDataBase db) => db.close(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: EmotionSelectionPage(),
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