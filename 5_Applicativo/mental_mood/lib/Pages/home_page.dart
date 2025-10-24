import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:mental_mood/DataBase/database.dart';
import 'package:provider/provider.dart';

import 'EmotionSelectionPage/emotion_selection_page.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppDataBase dataBase;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    dataBase = Provider.of<AppDataBase>(context);
    return Scaffold(
        backgroundColor: Colors.yellow[200],
        body: FutureBuilder<List<EmozioneData>>(
            builder: (context, snapshot){
              if(snapshot.hasData){
                List<EmozioneData>? listEmozioni = snapshot.data;
                if(listEmozioni!=null ){
                  if(listEmozioni.isEmpty){
                    return Center(
                      child: Text(
                        "Non sono state trovate emozioni. Riprova più tardi.",
                        style: TextStyle(fontSize: 60),
                      ),
                    );
                  }else{
                   return listEmozioniUI(listEmozioni);
                  }
                }
              }else if(snapshot.hasError){
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 60),
                  ),
                );
              }
              return Center(
                child: Text(
                    "Non sono state trovate emozioni. Riprova più tardi.",
                    style: TextStyle(fontSize: 60),
                ),
              );
            },
            future: _getEmozioneFromDataBase(),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _navigateToDetail('Aggiungi nuova emozione', EmozioneCompanion(
            nome: Value(''),
            imgPath: Value(''),
            valore: Value(0),
          ));
        },
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black, width: 2),
        ),
        child: const Icon(Icons.add),
      )
    );
  }
  Future<List<EmozioneData>> _getEmozioneFromDataBase() async{
    return await dataBase.getEmozioneList();
  }
  Widget listEmozioniUI(List<EmozioneData> listEmozioni) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: listEmozioni.length,
        itemBuilder: (context, index) {
          EmozioneData emozione = listEmozioni[index];
          return Card(
            child: ListTile(
              title: Text(emozione.nome),
              subtitle: Text("Valore: ${emozione.valore}"), // Leggermente migliorato per chiarezza
              onTap: () {
                _navigateToDetail(
                  emozione.nome,
                  EmozioneCompanion(
                    nome: Value(emozione.nome),
                    imgPath: Value(emozione.imgPath),
                    valore: Value(emozione.valore),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(String title, EmozioneCompanion emozioneCompanion) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EmotionSelectionPage()));
  }
}

