
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';
import 'package:mental_mood/Pages/menu.dart';
import 'package:mental_mood/Utils/database_util.dart';
import 'package:mental_mood/Utils/settings_util.dart';
import 'package:provider/provider.dart';

class UserSettingsPage extends StatefulWidget {
  final UtenteData? user;
  const UserSettingsPage({super.key, required this.user});


  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  String _selectedCronologiaValue = "MAI";
  String _selectedNotificaValue = "SI";
  Future<List<ImpostazioneData>>? _settingsFuture;




  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inizializza il Future solo una volta
    if (_settingsFuture == null && widget.user != null) {
      final dataBase = Provider.of<AppDataBase>(context);
      _settingsFuture = dataBase.getImpostazioni(widget.user!.id);
    }
  }

  void _updateCronologia(AppDataBase db, String? newValue, bool currentNotifiche) async {
    if (newValue == null || newValue == _selectedCronologiaValue) return;
    final int valueForDb = SettingsUtil().cronologiaStringToInt(newValue);
    setState(() {
      _selectedCronologiaValue = newValue;
    });

    try {
      final updatedSettings = ImpostazioneCompanion(
        utenteId: Value(widget.user!.id),
        cronologia: Value(valueForDb),
        notifiche: Value(currentNotifiche),
      );
      await db.updateImpostazioni(updatedSettings);
      setState(() {
        _settingsFuture = db.getImpostazioni(widget.user!.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di salvataggio: $e'), backgroundColor: Colors.red),
      );
    }
  }



  void _updateNotifica(AppDataBase db, String? newValue, int currentCronologia) async {
    if (newValue == null || newValue == _selectedNotificaValue) return;
    final bool valueForDb = SettingsUtil().notificaStringToBool(newValue);
    setState(() {
      _selectedNotificaValue = newValue;
    });

    try {
      final updatedSettings = ImpostazioneCompanion(
        utenteId: Value(widget.user!.id),
        cronologia: Value(currentCronologia),
        notifiche: Value(valueForDb),
      );
      await db.updateImpostazioni(updatedSettings);
      setState(() {
        _settingsFuture = db.getImpostazioni(widget.user!.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di salvataggio: $e'), backgroundColor: Colors.red),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    final dataBase = Provider.of<AppDataBase>(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text("Bentornato, ",style: TextStyle(color: Colors.black, fontSize: 67)),
                    Text(
                        widget.user!.username,
                        style: TextStyle(color: Colors.black, fontSize: 67)
                    ),
                  ],
                ),
              ),






              FutureBuilder<List<ImpostazioneData>>(
                future: dataBase.getImpostazioni(widget.user?.id),
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Errore: ${snapshot.error}"));
                  }
                  if(!snapshot.hasData || snapshot.data!.isEmpty) {
                    Future.delayed(Duration.zero, () {
                      DatabaseUtil dbUtil = DatabaseUtil();
                      dbUtil.populateDefaultSettings(dataBase, widget.user!)
                          .then((_) => setState(() {}));
                    });
                  }

                  final ImpostazioneData impostazioni = snapshot.data!.first;

                  final String dbCronologiaString = SettingsUtil().cronologiaIntToString(impostazioni.cronologia);
                  if(_selectedCronologiaValue != dbCronologiaString){
                    Future.microtask(() => setState(() {
                      _selectedCronologiaValue = dbCronologiaString;
                    }));
                  }

                  List<String> cronologiaItems = ["MAI", "30 giorni", "60 giorni", "90 giorni"];


                  final String dbNotificaString = SettingsUtil().notificaBoolToString(impostazioni.notifiche);
                  if(_selectedNotificaValue != dbNotificaString){
                    Future.microtask(() => setState(() {
                      _selectedNotificaValue = dbNotificaString;
                    }));
                  }

                  List<String> notificaItems = ["SI", "NO"];

                  return Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Eliminazioni dati ogni: ", style: const TextStyle(fontSize: 30)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                              child: DropdownButton<String>(
                                alignment: AlignmentGeometry.center,
                                underline: Container(height: 0),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 36,),
                                value: _selectedCronologiaValue,
                                onChanged: (newValue){
                                  _updateCronologia(dataBase, newValue, impostazioni.notifiche);
                                },
                                items: cronologiaItems.map((String selezione){
                                  return DropdownMenuItem<String>(
                                      value: selezione,
                                      child: Center(child: Text(selezione, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.normal)))
                                  );
                                }).toList(),
                              ),
                            )
                          ]
                      ),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Notifiche di promemoria: ", style: const TextStyle(fontSize: 30)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                              child: DropdownButton<String>(
                                alignment: AlignmentGeometry.center,
                                underline: Container(height: 0),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 36,),
                                value: _selectedNotificaValue,
                                onChanged: (newValue){
                                  _updateNotifica(dataBase, newValue, impostazioni.cronologia);
                                },
                                items: notificaItems.map((String selezione){
                                  return DropdownMenuItem<String>(
                                    value: selezione,
                                    child: Center(child: Text(selezione, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.normal)))
                                  );
                                }).toList(),
                              ),
                            ),
                          ]
                      ),




                      Text("Cronologia: ${impostazioni.cronologia}", style: const TextStyle(fontSize: 30)),
                      Text("Notifiche: ${impostazioni.notifiche ? 'Attive' : 'Disattive'}", style: const TextStyle(fontSize: 30)),
                    ],
                  );
                },
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


