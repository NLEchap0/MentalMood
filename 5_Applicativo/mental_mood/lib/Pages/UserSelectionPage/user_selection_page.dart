import 'package:flutter/material.dart';
import 'package:mental_mood/Pages/UserAddPage/user_add_page.dart';
import 'package:mental_mood/Pages/UserSelectionPage/user_selection.dart';
import 'package:provider/provider.dart';

import '../../DataBase/database.dart';
import '../EmotionSelectionPage/emotion_selection.dart';
import '../EmotionSelectionPage/emotion_visualizer.dart';
import '../EmotionSelectionPage/motivation_selection.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  late AppDataBase dataBase;

  UtenteData? _selectedUser;
  void _handleUserSelection(UtenteData utente) {
    setState(() {
      _selectedUser = utente;
      print('Utente selezionato: ${utente.username}');
    });
  }

  @override
  Widget build(BuildContext context) {
    dataBase = Provider.of<AppDataBase>(context);

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
                          const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.red,),
                          const Text(
                            "Nessun utente trovato",
                            style: TextStyle(fontSize: 20),
                          ),
                          const Text(
                            "Prova a riavviare l'app",
                            style: TextStyle(fontSize: 20),
                          ),
                          IconButton(icon: const Icon(Icons.add_circle, color: Colors.black, size: 208), onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAddPage()));},)
                        ],
                      ),
                    );
                  }

                  // Se tutto è ok, mostra la lista delle emozioni
                  final utenti = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Passiamo la lista di dati PRONTA e la callback
                        UserSeletionWidget(
                          utenti: utenti,
                          onUtenteSelected: _handleUserSelection,
                        ),
                        IconButton(icon: const Icon(Icons.add_circle, color: Colors.black, size: 208), onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAddPage()));},)
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

