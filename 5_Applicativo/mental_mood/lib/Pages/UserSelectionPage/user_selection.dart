import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class UserSeletionWidget extends StatelessWidget {
  final ValueChanged<UtenteData> onUtenteSelected;
  final List<UtenteData> utenti;

  const UserSeletionWidget({super.key, required this.utenti, required this.onUtenteSelected});

  @override
  Widget build(BuildContext context) {
    return listUsersUI(utenti, onUtenteSelected);
  }
}

Widget listUsersUI(List<UtenteData> listUsers, ValueChanged<UtenteData> onUtenteSelected) {
  print('🎨 Building lista con ${listUsers.length} motivazioni');
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    itemCount: listUsers.length,
    itemBuilder: (context, index) {
      UtenteData utente = listUsers[index];
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(
            utente.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            onUtenteSelected(utente);
            //final db = AppDataBase(); // oppure usa il provider se ce l’hai
            //await db.deleteMotivazione(motivazione.testo);
          },
        ),
      );
    },
  );
}