import 'package:flutter/material.dart';
import '../../DataBase/database.dart';

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
        firstDate: DateTime(1900),
        lastDate: DateTime.now()
    );

    if(pickedDate != null){
      setState(() {
        _dataNascitaSelezionata = pickedDate;
        dataNascitaController.text = _formatDate(pickedDate);
      });
    }
  }

  Future<void> _saveUser() async {
    if (usernameController.text.isEmpty || nomeController.text.isEmpty || _dataNascitaSelezionata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, compila tutti i campi!')),
      );
      return;
    }

    final db = AppDataBase(); // o prendi dal Provider se lo usi

    final utente = UtenteCompanion.insert(
      username: usernameController.text,
      nome: nomeController.text,
      dataNascita: _dataNascitaSelezionata!,
    );

    await db.into(db.utente).insert(utente);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utente salvato con successo! 🥳')),
    );
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
