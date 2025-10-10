import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';
import 'package:provider/provider.dart';

class EmotionSeletionWidget extends StatefulWidget {
  final AsyncSnapshot<List<EmozioneData>> snapshot;
  const EmotionSeletionWidget({super.key, required this.snapshot});

  @override
  State<EmotionSeletionWidget> createState() => _EmotionSeletionWidgetState();
}

class _EmotionSeletionWidgetState extends State<EmotionSeletionWidget> {
  late AppDataBase db;
  late TextEditingController descriptionEditingController;
  late TextEditingController imgPathEditingController;
  @override
  Widget build(BuildContext context) {
    db = Provider.of<AppDataBase>(context);
    return controlloDatiEmozioni(widget.snapshot);
  }


  Widget controlloDatiEmozioni(AsyncSnapshot<List<EmozioneData>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Caricamento emozioni..."),
          ],
        ),
      );
    }
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "Errore nel caricamento:",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "${snapshot.error}",
              textAlign: TextAlign.center,
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
            Icon(Icons.sentiment_dissatisfied, size: 64),
            SizedBox(height: 20),
            Text(
              "Nessuna emozione trovata",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text("Prova a riavviare l'app"),
          ],
        ),
      );
    }

    // Se tutto è ok, mostra la lista delle emozioni
    final emozioni = snapshot.data!;
    return listEmozioniUI(emozioni);
  }

  Widget listEmozioniUI(List<EmozioneData> listEmozioni) {
    print('🎨 Building lista con ${listEmozioni.length} emozioni');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listEmozioni.length,
      itemBuilder: (context, index) {
        EmozioneData emozione = listEmozioni[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                emozione.imgPath,
              ),
            ),
            title: Text(
              emozione.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            /*subtitle: Text("Valore: ${emozione.valore}"),*/
            onTap: () {/*
              _navigateToDetail(
                emozione.nome,
                EmozioneCompanion(
                  nome: Value(emozione.nome),
                  imgPath: Value(emozione.imgPath),
                  valore: Value(emozione.valore),
                ),
              );*/
            },
          ),
        );
      },
    );
  }
}
