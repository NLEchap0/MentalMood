import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class MotivationSeletionWidget extends StatelessWidget {
  final ValueChanged<MotivazioneData> onMotivazioneSelected;
  final List<MotivazioneData> motivazioni;
  final List<MotivazioneData?> motivazioniSelected;

  const MotivationSeletionWidget({super.key, required this.motivazioni, required this.onMotivazioneSelected, required this.motivazioniSelected});

  @override
  Widget build(BuildContext context) {
    return listMotivazioniUI(motivazioni,motivazioniSelected);
  }

  Widget listMotivazioniUI(List<MotivazioneData> listMotivazioni, List<MotivazioneData?> motivazioniSelected) {
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
          color: motivazioniSelected.contains(motivazione) ? Colors.lightBlue.shade50 : null,
          shape: motivazioniSelected.contains(motivazione)
              ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.blue, width: 2),
          )
              : null,
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
