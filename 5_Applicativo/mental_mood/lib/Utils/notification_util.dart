import 'package:flutter/material.dart';
import '../DataBase/database.dart';
import 'NotificationService.dart';

class NotificationUtil {
  // Funzione che contiene la logica condizionale di scheduling
  void scheduleIfEnabled(AppDataBase db, UtenteData? utente, TimeOfDay dailyNotificationTime, TimeOfDay dailyNotificationTime2, TimeOfDay dailyNotificationTime3) async {
    if (utente?.id == null) return;
    final idUtente = utente!.id;

    final List<ImpostazioneData> impostazioniList = await db.getImpostazioni(idUtente);

    bool isNotificationEnabled = false;

    if (impostazioniList.isNotEmpty) {
      final impostazione = impostazioniList.first;
      isNotificationEnabled = impostazione.notifiche;
    }

    if (isNotificationEnabled) {
      // 3. Se abilitato, programma la notifica
      NotificationService().scheduleDailyNotification(
        id: 100,
        title: "Promemoria Giornaliero",
        body: "È ora di registrare il tuo umore mentale e i tuoi progressi!",
        time: dailyNotificationTime,
      );
      NotificationService().scheduleDailyNotification(
        id: 101,
        title: "Promemoria Giornaliero",
        body: "È ora di registrare il tuo umore mentale e i tuoi progressi!",
        time: dailyNotificationTime2,
      );
      NotificationService().scheduleDailyNotification(
        id: 102,
        title: "Promemoria Giornaliero",
        body: "È ora di registrare il tuo umore mentale e i tuoi progressi!",
        time: dailyNotificationTime3,
      );
      // Feedback opzionale in console
      debugPrint("Notifica giornaliera automatica programmata in _scheduleIfEnabled().");
    } else {
      // 4. Se disabilitato, annulla le notifiche precedenti
      NotificationService().cancelAllNotifications();
      debugPrint("Notifica automatica annullata in _scheduleIfEnabled().");
    }
  }
}