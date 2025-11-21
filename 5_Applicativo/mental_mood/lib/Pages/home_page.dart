import 'package:flutter/material.dart';
import 'package:mental_mood/Pages/menu.dart';
import 'package:provider/provider.dart';
import '../DataBase/database.dart';

import '../Utils/notification_util.dart';

class HomePage extends StatefulWidget {
  final UtenteData? user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppDataBase dataBase;

  @override void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndScheduleNotifications();
    });
  }

  void _checkAndScheduleNotifications() async{
    if(widget.user != null){
      final dataBase = Provider.of<AppDataBase>(context, listen: false);

      print("Tentativo di scheduling delle notifiche");

      NotificationUtil().scheduleIfEnabled(
          dataBase,
          widget.user,
          dailyNotificationTime,
          dailyNotificationTime2,
          dailyNotificationTime3
      );

      print("Notifiche programmate correttamente.");
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
                    Text("Bentornato, ",style: TextStyle(color: Colors.black, fontSize: 67)),
                    Text(
                        widget.user!.nome,
                        style: TextStyle(color: Colors.black, fontSize: 67)
                    ),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              "Motivazioni: $motivazioniString\nData: ${registrazione.dataRegistrazione.toLocal().toString().substring(0, 16)}",
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

