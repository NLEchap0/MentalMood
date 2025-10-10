import '../DataBase/database.dart';

class DatabaseUtil {
  Future<void> populateDefaultEmotions(AppDataBase db) async {
    try {
      //Verifica emozioni esistenti
      final existingEmotions = await db.getEmozioneList();

      if (existingEmotions.isEmpty) {
        //Inserimento emozioni predefinite

        // Inserisci una per una per debugging
        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Disperato / Depresso',
            imgPath: 'assets/images/sad.png',
            valore: 0
        ));
        print('   - Inserito: Disperato / Depresso');

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Triste',
            imgPath: 'assets/images/sad.png',
            valore: 1
        ));
        print('   - Inserito: Triste');

        // Continua con le altre...
        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Ansioso / Stressato',
            imgPath: 'assets/images/anxious.png',
            valore: 2
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Arrabbiato',
            imgPath: 'assets/images/angry.png',
            valore: 3
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Indifferente / Apatico',
            imgPath: 'assets/images/uncertain.png',
            valore: 4
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Neutrale / Stabile',
            imgPath: 'assets/images/uncertain.png',
            valore: 5
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Sereno / Calmo',
            imgPath: 'assets/images/ok.png',
            valore: 6
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Soddisfatto / Contento',
            imgPath: 'assets/images/ok.png',
            valore: 7
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Felice',
            imgPath: 'assets/images/happy.png',
            valore: 8
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Entusiasta / Euforico',
            imgPath: 'assets/images/happy.png',
            valore: 9
        ));
      }
    } catch (e) {
      print('Errore durante il popolamento del database: $e');
      rethrow;
    }
  }
}



/*import '../DataBase/database.dart';

class DatabaseUtil {
  Future<void> populateDefaultEmotions(AppDataBase db) async {
    try {
      // Verifica se ci sono già emozioni nel database
      final existingEmotions = await db.getEmozioneList();

      if (existingEmotions.isEmpty) {
        // Usa un batch per inserimenti multipli più efficienti
        await db.batch((batch) {
          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Disperato / Depresso',
              imgPath: 'assets/images/sad.png',
              valore: 0
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Triste',
              imgPath: 'assets/images/sad.png',
              valore: 1
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Ansioso / Stressato',
              imgPath: 'assets/images/anxious.png',
              valore: 2
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Arrabbiato',
              imgPath: 'assets/images/angry.png',
              valore: 3
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Indifferente / Apatico',
              imgPath: 'assets/images/uncertain.png',
              valore: 4
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Neutrale / Stabile',
              imgPath: 'assets/images/uncertain.png',
              valore: 5
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Sereno / Calmo',
              imgPath: 'assets/images/ok.png',
              valore: 6
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Soddisfatto / Contento',
              imgPath: 'assets/images/ok.png',
              valore: 7
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Felice',
              imgPath: 'assets/images/happy.png',
              valore: 8
          ));

          batch.insert(db.emozione, EmozioneCompanion.insert(
              nome: 'Entusiasta / Euforico',
              imgPath: 'assets/images/happy.png',
              valore: 9
          ));
        });

        print('Emozioni predefinite inserite con successo');
      } else {
        print('Emozioni già presenti nel database: ${existingEmotions.length}');
      }
    } catch (e) {
      print('Errore durante il popolamento del database: $e');
    }
  }
}*/