import 'package:flutter/cupertino.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DataBase/database.dart';
import 'EmotionSelectionPage/emotion_selection.dart';

class EmotionSelectionPage extends StatefulWidget {
  const EmotionSelectionPage({super.key});

  @override
  State<EmotionSelectionPage> createState() => _EmotionSelectionPageState();
}

class _EmotionSelectionPageState extends State<EmotionSelectionPage> {
  late AppDataBase dataBase;

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
      body: FutureBuilder<List<EmozioneData>>(
        future: _getEmozioneFromDataBase(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Expanded(
                    child: EmotionSeletionWidget(snapshot: snapshot),
                ),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
              ],
            ),
          );
        },
      ),
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
/*
  void _navigateToDetail(String title, EmozioneCompanion emozioneCompanion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmotionSelectionPage(
          title: title,
          emozioneCompanion: emozioneCompanion,
        ),
      ),
    );
  }*/
}

