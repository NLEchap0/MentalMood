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
            nome: 'Disperato o Depresso',
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
            nome: 'Ansioso o Stressato',
            imgPath: 'assets/images/anxious.png',
            valore: 2
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Arrabbiato',
            imgPath: 'assets/images/angry.png',
            valore: 3
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Apatico',
            imgPath: 'assets/images/uncertain.png',
            valore: 4
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Neutrale',
            imgPath: 'assets/images/uncertain.png',
            valore: 5
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Sereno',
            imgPath: 'assets/images/ok.png',
            valore: 6
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Soddisfatto',
            imgPath: 'assets/images/ok.png',
            valore: 7
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Felice',
            imgPath: 'assets/images/happy.png',
            valore: 8
        ));

        await db.into(db.emozione).insert(EmozioneCompanion.insert(
            nome: 'Entusiasta',
            imgPath: 'assets/images/happy.png',
            valore: 9
        ));
      }
    } catch (e) {
      print('Errore durante il popolamento del database: $e');
      rethrow;
    }
  }


  Future<void> populateDefaultMotivations(AppDataBase db) async {
    try {
      //Verifica motivazioni esistenti

      final existingMotivations = await db.getMotivazioneList();
      if (existingMotivations.isEmpty) {
        //Inserimento motivazioni predefinite
        // Inserisci una per una per debugging

        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Relazioni Sociali"
        ));
        print('   - Inserito: Relazioni Sociali');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Esercizio Fisico"
        ));
        print('   - Inserito: Esercizio Fisico');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Raggiungimento di Obiettivi"
        ));
        print('   - Inserito: Raggiungimento di Obiettivi');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Qualità del sonno"
        ));
        print('   - Inserito: Qualità del sonno');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Scuola o Lavoro"
        ));
        print('   - Inserito: Scuola o Lavoro');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Condizioni meteorologiche"
        ));
        print('   - Inserito: Condizioni meteorologiche');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Dolore Fisico o Malattia"
        ));
        print('   - Inserito: Dolore Fisico o Malattia');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Esposizione alla Natura"
        ));
        print('   - Inserito: Esposizione alla Natura');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Musica"
        ));
        print('   - Inserito: Musica');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Disponibilità di Spazi Privati"
        ));
        print('   - Inserito: Disponibilità di Spazi Privati');


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Rumori Improvvisi o Forti"
        ));
        print('   - Inserito: Rumori Improvvisi o Forti');
      }
    } catch (e) {
      print('Errore durante il popolamento del database: $e');
      rethrow;
    }
  }
}