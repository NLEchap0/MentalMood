import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class MotivationSeletionWidget extends StatelessWidget {
  final ValueChanged<MotivazioneData> onMotivazioneSelected;
  final List<MotivazioneData> motivazioni;

  const MotivationSeletionWidget({super.key, required this.motivazioni, required this.onMotivazioneSelected});

  @override
  Widget build(BuildContext context) {
    return listMotivazioniUI(motivazioni);
  }

  Widget listMotivazioniUI(List<MotivazioneData> listMotivazioni) {
    print('🎨 Building lista con ${listMotivazioni.length} motivazioni');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: listMotivazioni.length,
      itemBuilder: (context, index) {
        MotivazioneData motivazione = listMotivazioni[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              motivazione.testo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              onMotivazioneSelected(motivazione);
              //final db = AppDataBase(); // oppure usa il provider se ce l’hai
              //await db.deleteMotivazione(motivazione.testo);
            },
          ),
        );
      },
    );
  }
}
