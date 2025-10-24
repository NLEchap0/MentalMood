import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class EmotionSeletionWidget extends StatelessWidget {
  final ValueChanged<EmozioneData> onEmozioneSelected;
  final List<EmozioneData> emozioni;

  const EmotionSeletionWidget({super.key, required this.emozioni, required this.onEmozioneSelected});

  @override
  Widget build(BuildContext context) {
    return listEmozioniUI(emozioni);
  }

  Widget listEmozioniUI(List<EmozioneData> listEmozioni) {
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
            onTap: () async {
              onEmozioneSelected(emozione);
              //final db = AppDataBase(); // oppure usa il provider se ce l’hai
              //await db.deleteEmozione(emozione.nome);
            },
          ),
        );
      },
    );
  }
}
