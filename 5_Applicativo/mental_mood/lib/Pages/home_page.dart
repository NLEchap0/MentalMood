import 'dart:math';

import 'package:mental_mood/Utils/notification_util.dart';
import 'package:flutter/material.dart';
import 'package:mental_mood/Pages/menu.dart';
import 'package:provider/provider.dart';
import '../DataBase/database.dart';

class HomePage extends StatefulWidget {
  final UtenteData? user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppDataBase dataBase;

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndDeleteOldStorage();
      setState(() {});
    });
  }

  void _checkAndDeleteOldStorage() async{
    if(widget.user != null){
      final dataBase = Provider.of<AppDataBase>(context, listen: false);
      List<ImpostazioneData> impostazioni = await dataBase.getImpostazioni(widget.user?.id);
      if(impostazioni.isNotEmpty){
        final int cronologiaValue = impostazioni.first.cronologia;
          switch (cronologiaValue) {
            case 1:
              return;
            case 2:
              await dataBase.deleteOldEmozioniRegistrate(30);
              break;
            case 3:
              await dataBase.deleteOldEmozioniRegistrate(60);
              break;
            case 4:
              await dataBase.deleteOldEmozioniRegistrate(90);
              break;
            default:
              print('Warning: Unhandled cronologia setting value: $cronologiaValue');
              break;
          }
      }
    }
  }

  final TimeOfDay dailyNotificationTime = const TimeOfDay(hour: 10, minute: 0);
  final TimeOfDay dailyNotificationTime2 = const TimeOfDay(hour: 15, minute: 40);
  final TimeOfDay dailyNotificationTime3 = const TimeOfDay(hour: 20, minute: 0);

  // Flag per eseguire la logica di scheduling una sola volta
  bool _isScheduled = false;

  Future<List<EmozioneRegistrataData>> _getRegistrazioni() async {
    final userId = widget.user?.id;
    if (userId != null) {
      return dataBase.getEmozioniRegistrateByUserId(userId);
    }
    return [];
  }

  Future<ConsiglioData> _getConsiglio() async {
    List<ConsiglioData> consigli = await dataBase.getConsiglioList();
    List<EmozioneRegistrataData> emozioni = await dataBase.getEmozioniRegistrateByUserId(widget.user!.id);
    List<EmozioneData> emozioniValide = [];
    List<ConsiglioData> consigliValidi = [];

    for(var i = 0; i < emozioni.length; i++){
      DateTime data = emozioni[i].dataRegistrazione;
      if(data.isAfter(DateTime.now().subtract(const Duration(days: 2)))){
        emozioniValide.add(await dataBase.getEmozioneByName(emozioni[i].emozioneNome));
      }
    }

    if (emozioniValide.isEmpty) {
      return ConsiglioData(
        id: -1,
        valoreIniziale: 0,
        valoreFinale: 10,
        testo: "Non abbiamo dati recenti o sufficienti. Ricorda di prenderti cura di te e registrare le tue emozioni!",
      );
    }

    double sommaValori = 0;
    for (var emozione in emozioniValide) {
      sommaValori += emozione.valore;
    }

    double media = 0;
    if (emozioniValide.isNotEmpty) {
      media = sommaValori / emozioniValide.length;
    }

    for (var i = 0; i < consigli.length; i++) {
      if(media >= consigli[i].valoreIniziale && media <= consigli[i].valoreFinale){
        consigliValidi.add(consigli[i]);
      }
    }

    final random = Random();
    int numeroRandom = random.nextInt(consigliValidi.length);

    return consigliValidi[numeroRandom];
  }

  @override
  Widget build(BuildContext context) {
    dataBase = Provider.of<AppDataBase>(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover,
            )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text("Bentornato/a!",style: TextStyle(color: Colors.black, fontSize: 67)),
                  ],
                ),
              ),
              FutureBuilder<ConsiglioData>(
                future: _getConsiglio(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Errore: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                        child: Text("Dati insufficienti per mostrare consigli.",
                            style: TextStyle(fontSize: 18, color: Colors.grey)));
                  }

                  // Mostra la lista dei risultati
                  final consiglio = snapshot.data!;


                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text(
                                    "Consiglio per te:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8,),
                              Text(
                                consiglio.testo,
                                style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text("Emozioni registrate:",style: TextStyle(color: Colors.black, fontSize: 39)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: Row(
                  children: [
                    Text("(dalla più recente alla più vecchia)",style: TextStyle(color: Colors.black, fontSize: 24)),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder<List<EmozioneRegistrataData>>(
                  future: _getRegistrazioni(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Errore: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("Nessuna emozione registrata trovata.",
                              style: TextStyle(fontSize: 18, color: Colors.grey)));
                    }

                    // Mostra la lista dei risultati
                    final registrazioni = snapshot.data!;
                    return ListView.builder(
                      itemCount: registrazioni.length,
                      itemBuilder: (context, index) {
                        final registrazione = registrazioni[index];

                        // Prepara la lista di motivazioni
                        // La lista di stringhe viene unita per essere mostrata
                        final motivazioniString = registrazione.motivazioneTesto.join(', ');

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              "Emozione: ${registrazione.emozioneNome}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                            ),
                            subtitle: Text(
                              "Motivazioni: ${motivazioniString.isEmpty ? "Nessuna motivazione selezionata." : motivazioniString}"
                              "\nData: ${registrazione.dataRegistrazione.toLocal().toString().substring(0, 16)}",
                              style: const TextStyle(fontSize: 20),
                            ),
                            leading: const Icon(Icons.favorite_border), // Icona a tua scelta
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: Menu(user: widget.user),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

