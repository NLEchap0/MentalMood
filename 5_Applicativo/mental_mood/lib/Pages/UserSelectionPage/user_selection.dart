import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';

class UserSeletionWidget extends StatelessWidget {
  final ValueChanged<UtenteData> onUtenteSelected;
  final List<UtenteData> utenti;
  final bool deleteUtenti;

  const UserSeletionWidget({super.key, required this.utenti, required this.onUtenteSelected, required this.deleteUtenti});

  @override
  Widget build(BuildContext context) {
    return listUsersUI(utenti, onUtenteSelected, deleteUtenti);
  }
}

Widget listUsersUI(List<UtenteData> listUsers, ValueChanged<UtenteData> onUtenteSelected, bool deleteUtenti) {
  print('🎨 Building lista con ${listUsers.length} utenti');
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    itemCount: listUsers.length,
    itemBuilder: (context, index) {
      UtenteData utente = listUsers[index];
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.black, width: 2.0),
          ),
          child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 50,
                  children: [
                    deleteUtenti
                    ?
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.black,
                      child:
                      Icon(Icons.delete_forever, size: 60, color: Colors.red,),
                    )
                    :
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.black,
                      child: Text(
                        utente.username[0],
                        style: TextStyle(fontSize: 60, color: Colors.white),
                      ),
                    ),
                    Text(
                      utente.nome.length > 18
                          ? '${utente.nome.substring(0, 18)}...'
                          : utente.nome,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ],
                ),
              ),
              onTap: () async{
                onUtenteSelected(utente);
                //final db = AppDataBase();
                //await db.deleteUser(utente.id);
              },
          ),
        ),
      );
    },
  );
}