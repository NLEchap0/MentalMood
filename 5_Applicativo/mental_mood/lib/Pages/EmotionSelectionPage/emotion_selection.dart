import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class EmotionSeletionWidget extends StatefulWidget {
  final ValueChanged<EmozioneData> onEmozioneSelected;
  final List<EmozioneData> emozioni;
  final EmozioneData? emozioneSelected;

  const EmotionSeletionWidget({super.key, required this.emozioni, required this.onEmozioneSelected, this.emozioneSelected});

  @override
  State<EmotionSeletionWidget> createState() => _EmotionSeletionWidgetState();
}

class _EmotionSeletionWidgetState extends State<EmotionSeletionWidget> {
  @override
  Widget build(BuildContext context) {
    return listEmozioniUI(widget.emozioni, widget.emozioneSelected);
  }

  Widget listEmozioniUI(List<EmozioneData> listEmozioni, EmozioneData? emozioneSelected) {
    print('🎨 Building lista con ${listEmozioni.length} emozioni');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: listEmozioni.length,
      itemBuilder: (context, index) {
        EmozioneData emozione = listEmozioni[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: emozioneSelected == emozione ? Colors.lightBlue.shade50 : null,
          shape: emozioneSelected == emozione
              ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.blue, width: 2),
          )
              : null,
          child: ListTile(/*
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
            ),*/
            title: Text(
              emozione.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            /*subtitle: Text("Valore: ${emozione.valore}"),*/
            onTap: () async {
              widget.onEmozioneSelected(emozione);
              //final db = AppDataBase(); // oppure usa il provider se ce l’hai
              //await db.deleteEmozione(emozione.nome);
            },
          ),
        );
      },
    );
  }
}
