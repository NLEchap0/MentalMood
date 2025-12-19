import 'package:flutter/material.dart';
import 'package:mental_mood/Pages/UserAddPage/user_add_page.dart';
import 'package:mental_mood/Pages/UserSelectionPage/user_selection.dart';
import 'package:mental_mood/Pages/home_page.dart';
import 'package:provider/provider.dart';

import '../../DataBase/database.dart';

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

    return Scaffold(
        backgroundColor: Colors.yellow[200],
        appBar: AppBar(
          title: const Text("Seleziona un utente"),
          elevation: 10,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
        ),
        body:LayoutBuilder(
          builder:(context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: constraints.maxHeight
                ),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/bg.jpg"),
                        fit: BoxFit.cover,
                      )
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteUtenti();
                          },
                          child: Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 24,),
                              Text(
                                deleteUtenti
                                    ? "Disattiva modalità elimina"
                                    : "Attiva modalità elimina",
                                style: TextStyle(fontSize: 24),
                              )
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[200],
                            foregroundColor: Colors.red,
                            minimumSize: Size(450, 60),
                            elevation: 10,
                            side: BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<List<UtenteData>>(
                        future: _getUtenteFromDataBase(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Column(
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
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.add_circle, color: Colors.black,
                                        size: 208),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (
                                              context) => const UserAddPage()));
                                    },)
                                ],
                              ),
                            );
                          }

                          // Se tutto è ok, mostra la lista degli utenti
                          final utenti = snapshot.data!;
                          return Column(
                            children: [
                              // Passiamo la lista di dati PRONTA e la callback
                              UserSeletionWidget(
                                utenti: utenti,
                                onUtenteSelected: _handleUserSelection,
                                deleteUtenti: deleteUtenti,
                              ),
                              IconButton(icon: const Icon(
                                  Icons.add_circle, color: Colors.black,
                                  size: 208),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (
                                              context) => const UserAddPage()
                                      )
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                              ),
                            ],
                          );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      );
  }

  Future<List<UtenteData>> _getUtenteFromDataBase() async {
    try {
      // Recupero utenti dal database
      final result = await dataBase.getUtenteList();
      // Utenti recuperati corretto, quindi passo il risultato alla callback
      return result;
    } catch (e) {
      print('Errore nel recupero emozioni: $e');
      rethrow;
    }
  }
}

