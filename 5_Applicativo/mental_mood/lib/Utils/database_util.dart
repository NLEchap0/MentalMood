import '../DataBase/database.dart';

class DatabaseUtil {
  Future<void> populateDefaultEmotions(AppDataBase db) async {
    try {
      //Verifica emozioni esistenti
      final existingEmotions = await db.getEmozioneList();

      if (existingEmotions.isEmpty) {
        //Inserimento emozioni predefinite

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


        await db.into(db.motivazione).insert(MotivazioneCompanion.insert(
            testo: "Altro"
        ));
        print('   - Inserito: Altro');
      }
    } catch (e) {
      print('Errore durante il popolamento del database: $e');
      rethrow;
    }
  }

  Future<void> populateDefaultSettings(AppDataBase db, UtenteData utente) async {
    try {
      //Verifica impostazioni esistenti

      final existingSettings = await db.getImpostazioni(utente.id);
      if (existingSettings.isEmpty) {
        //Inserimento impostazioni predefinite

        await db.into(db.impostazione).insert(ImpostazioneCompanion.insert(
          cronologia: 4,
          notifiche: true,
        ));
        print(
            '   - Inserito: Cronologia: 0, Notifiche: true all\'utente ${utente
                .username}');
      }
    } catch (e) {
      print('Errore durante il popolamento del database: $e');
      rethrow;
    }
  }


  Future<void> populateDefaultSuggestions(AppDataBase db) async {
    try {
      //Verifica consigli esistenti

      final existingSuggestions = await db.getConsiglioList();
      if (existingSuggestions.isEmpty) {
        //Inserimento consigli predefiniti

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Parla con una persona a te fidata di come ti senti, potrebbe aiutarti a superare questo momento difficile.",
            valoreIniziale: 0,
            valoreFinale: 2
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Se ti può aiutare, prova ad andare in un luogo che ti porta calma e ascolta musica rilassante.",
            valoreIniziale: 0,
            valoreFinale: 2
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Impegnati a fare un'attività che stai procrastinando, ti aiuterà a sentirti utile.",
            valoreIniziale: 3,
            valoreFinale: 4
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Se ti senti sopraffatto, nota 5 cose che puoi vedere, 4 che puoi toccare, 3 che puoi sentire, 2 che puoi annusare e 1 che puoi gustare.",
            valoreIniziale: 3,
            valoreFinale: 4
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Pianifica qualcosa che ti fa piacere fare, come guardare una serie TV o altro.",
            valoreIniziale: 3,
            valoreFinale: 4
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Pensa e annota ciò per cui sei grato oggi.",
            valoreIniziale: 5,
            valoreFinale: 6
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Impegnati in un'attività che ti assorbe completamente, come un hobby, un puzzle, o suonare uno strumento.",
            valoreIniziale: 5,
            valoreFinale: 6
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Fai una piccola cosa per rendere più facile il tuo risveglio o la giornata domani.",
            valoreIniziale: 5,
            valoreFinale: 6
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Chiama un amico o un familiare e racconta loro perché sei felice.",
            valoreIniziale: 7,
            valoreFinale: 8
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Usa la tua energia positiva per fare qualcosa di gentile per qualcun altro, come offrire aiuto, fare un complimento, ecc.",
            valoreIniziale: 7,
            valoreFinale: 8
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Smetti di pensare al futuro o a cosa farai dopo e immergiti completamente nel presente.",
            valoreIniziale: 9,
            valoreFinale: 10
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Usa l'ondata di energia per avviare o progredire significativamente in un obiettivo importante.",
            valoreIniziale: 9,
            valoreFinale: 10
        ));
        print(
            "   - Inserito: Consiglio"
        );

        await db.into(db.consiglio).insert(ConsiglioCompanion.insert(
            testo: "Assicurati di rimanere ancorato alle tue esigenze di base: non saltare un pasto, dormi a sufficienza.",
            valoreIniziale: 9,
            valoreFinale: 10
        ));
        print(
            "   - Inserito: Consiglio"
        );
      }
    } catch (e) {
      print('Errore durante il popolamento del database: $e');
      rethrow;
    }
  }
}