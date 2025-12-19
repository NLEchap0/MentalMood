import 'package:flutter/material.dart';
import '../../DataBase/database.dart';
import '../UserSelectionPage/user_selection_page.dart';

/* LOGICA PAGINA QUASI TOTALMENTE CREATA ASSISTITA DALL'UTILIZZO DI GEMINI, POI RIVISIONATA */
class UserAddPage extends StatefulWidget {
  const UserAddPage({super.key});

  @override
  State<UserAddPage> createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  final usernameController = TextEditingController();
  final nomeController = TextEditingController();
  DateTime? _dataNascitaSelezionata;
  final dataNascitaController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    nomeController.dispose();
    dataNascitaController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async{
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _dataNascitaSelezionata ?? DateTime.now(),
        firstDate: DateTime(1925),
        lastDate: DateTime.now()
    );

    if(pickedDate != null){
      setState(() {
        _dataNascitaSelezionata = pickedDate;
        dataNascitaController.text = _formatDate(pickedDate);
      });
    }
  }

  Future<bool> _isUsernameUnique(String username) async {
    final db = AppDataBase();
    // Usiamo una query Count per vedere se esistono utenti con quell'username
    final count = await (db.select(db.utente)
      ..where((u) => u.username.equals(username)))
        .get();

    // Se la lista restituita non è vuota, l'utente esiste
    return count.isEmpty;
  }

  Future<void> _saveUser() async {
    final db = AppDataBase();
    final trimmedUsername = usernameController.text.trim();
    final trimmedNome = nomeController.text.trim();

    if(usernameController.text.isEmpty || nomeController.text.isEmpty || _dataNascitaSelezionata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, compila tutti i campi!'), backgroundColor: Colors.red,),
      );
      return;
    }

    if (!(await _isUsernameUnique(trimmedUsername))) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Questo username è già esistente!'), backgroundColor: Colors.red)
      );
      return;
    }

    final utente = UtenteCompanion.insert(
      username: trimmedUsername,
      nome: trimmedNome,
      dataNascita: _dataNascitaSelezionata!,
    );

    await db.insertUtente(utente);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserSelectionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi Utente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: dataNascitaController,
              decoration: const InputDecoration(
                labelText: 'Data di nascita',
                prefixIcon: Icon(Icons.calendar_month)),
              readOnly: true,
              onTap: (){
                _selectDate();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUser,
              child: const Text('Salva Utente'),
            ),
          ],
        ),
      ),
    );
  }
}
