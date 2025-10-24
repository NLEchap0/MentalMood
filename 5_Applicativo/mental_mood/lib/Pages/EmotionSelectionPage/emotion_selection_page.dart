import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../DataBase/database.dart';
import 'emotion_selection.dart';
import 'emotion_visualizer.dart';
import 'motivation_selection.dart';

class EmotionSelectionPage extends StatefulWidget {
  const EmotionSelectionPage({super.key});

  @override
  State<EmotionSelectionPage> createState() => _EmotionSelectionPageState();
}

class _EmotionSelectionPageState extends State<EmotionSelectionPage> {
  late AppDataBase dataBase;

  // Variabile per tenere traccia dell'emozione selezionata.
  EmozioneData? _selectedEmozione;
  // Metodo chiamato da EmotionSeletionWidget al tap.
  void _handleEmozioneSelection(EmozioneData emozione) {
    setState(() {
      _selectedEmozione = emozione;
      print('Emozione selezionata: ${emozione.nome}');
    });
  }

  MotivazioneData? _selectedMotivazione;
  void _handleMotivazioneSelection(MotivazioneData motivazione) {
    setState(() {
      _selectedMotivazione = motivazione;
      print('Motivazione selezionata: ${motivazione.testo}');
    });
  }

  @override
  Widget build(BuildContext context) {
    dataBase = Provider.of<AppDataBase>(context);

    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text("Seleziona il tuo stato emotivo attuale"),
        backgroundColor: Colors.orangeAccent,
        elevation: 4,
      ),
      body:SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<EmozioneData>>(
              future: _getEmozioneFromDataBase(),
              builder: (context, snapshot){
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        Text(
                          "Errore nel caricamento:",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "\"${snapshot.error}\"",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Riprova più tardi",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.red,),
                        Text(
                          "Nessuna emozione trovata",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Prova a riavviare l'app",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }

                // Se tutto è ok, mostra la lista delle emozioni
                final emozioni = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Passiamo la lista di dati PRONTA e la callback
                      EmotionSeletionWidget(
                        emozioni: emozioni,
                        onEmozioneSelected: _handleEmozioneSelection,
                      ),
                      // Il visualizzatore riceve lo stato dell'emozione selezionata
                      EmotionVisualizerWidget(emozione: _selectedEmozione),
                    ],
                  ),
                );
              },
            ),
            FutureBuilder<List<MotivazioneData>>(
              future: _getMotivazioneFromDataBase(),
              builder: (context, snapshot){
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        Text(
                          "Errore nel caricamento:",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "\"${snapshot.error}\"",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Riprova più tardi",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.red,),
                        Text(
                          "Nessuna motivazione trovata",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Prova a riavviare l'app",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }

                // Se tutto è ok, mostra la lista delle emozioni
                final motivazioni = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Passiamo la lista di dati PRONTA e la callback
                      MotivationSeletionWidget(
                        motivazioni: motivazioni,
                        onMotivazioneSelected: _handleMotivazioneSelection,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      )
    );
  }

  Future<List<EmozioneData>> _getEmozioneFromDataBase() async {
    try {
      // Recupero emozioni dal database
      final result = await dataBase.getEmozioneList();
      // Emozioni recuperate
      return result;
    } catch (e) {
      print('Errore nel recupero emozioni: $e');
      rethrow;
    }
  }

  Future<List<MotivazioneData>> _getMotivazioneFromDataBase() async{
    try {
      // Recupero emozioni dal database
      final result = await dataBase.getMotivazioneList();
      // Emozioni recuperate
      return result;
    } catch (e) {
      print('Errore nel recupero emozioni: $e');
      rethrow;
    }
  }
}

