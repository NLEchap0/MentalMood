import 'package:flutter/material.dart';
import 'package:mental_mood/Pages/UserAddPage/user_add_page.dart';
import 'package:mental_mood/Pages/UserSelectionPage/user_selection.dart';
import 'package:mental_mood/Pages/home_page.dart';
import 'package:provider/provider.dart';

import '../../DataBase/database.dart';
import '../../Utils/notification_util.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  late AppDataBase dataBase;
  var deleteUtenti = false;

  UtenteData? _selectedUser;
  void _handleUserSelection(UtenteData utente) async {
    if (deleteUtenti) {
      try {
        await dataBase.deleteUser(utente.id);
        setState(() {});
      } catch (e) {
        print('Errore durante l\'eliminazione: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore DB: $e')),
        );
      }
    } else {
      _selectedUser = utente;

      try {
        print("Tentativo di schedulazione notifiche per utente: ${utente.nome}");

        // Qui passo 3 orari standard.
        await NotificationUtil().scheduleIfEnabled(
            dataBase,
            utente,
            const TimeOfDay(hour: 9, minute: 0),  // Notifica 1
            const TimeOfDay(hour: 14, minute: 05), // Notifica 2
            const TimeOfDay(hour: 21, minute: 0)  // Notifica 3
        );
      } catch (e) {
        print("Errore nella schedulazione notifiche: $e");
      }
      if (!mounted) return;

      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(user: _selectedUser)));
    }
  }

  void _deleteUtenti() {
    setState(() {
      deleteUtenti = !deleteUtenti;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataBase = Provider.of<AppDataBase>(context);
  }

  @override
  Widget build(BuildContext context) {
    //dataBase = Provider.of<AppDataBase>(context);

    return Scaffold(
        backgroundColor: Colors.yellow[200],
        appBar: AppBar(
          title: const Text("Seleziona un utente da utilizzare"),
          backgroundColor: Colors.orangeAccent,
          elevation: 4,
        ),
        body:SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () { _deleteUtenti(); },
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 24,),
                    Text(
                        deleteUtenti ? "Termina eliminazioni" : "Elimina utenti",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                )
              ),
              FutureBuilder<List<UtenteData>>(
                future: _getUtenteFromDataBase(),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.black, size: 208),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAddPage()));
                            },)
                        ],
                      ),
                    );
                  }

                  // Se tutto è ok, mostra la lista degli utenti
                  final utenti = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Passiamo la lista di dati PRONTA e la callback
                        UserSeletionWidget(
                          utenti: utenti,
                          onUtenteSelected: _handleUserSelection,
                          deleteUtenti: deleteUtenti,
                        ),
                        IconButton(icon: const Icon(Icons.add_circle, color: Colors.black, size: 208),
                          onPressed: () {
                           Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) => const UserAddPage()
                               )
                           ).then((_) {
                             setState(() {});
                           });
                          },
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

  Future<List<UtenteData>> _getUtenteFromDataBase() async {
    try {
      // Recupero emozioni dal database
      final result = await dataBase.getUtenteList();
      // Emozioni recuperate
      return result;
    } catch (e) {
      print('Errore nel recupero emozioni: $e');
      rethrow;
    }
  }
}

