import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Import necessari per la gestione dei fusi orari
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart'; // Necessario per TimeOfDay

class NotificationService {
  // Use a singleton pattern to ensure only one instance handles notifications
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // METODO PER CONFIGURARE IL FUSO ORARIO LOCALE
  Future<void> _configureLocalTimeZone() async {
    // Inizializza tutti i database di fusi orari
    tz.initializeTimeZones();
    // Ottieni il nome del fuso orario locale del dispositivo
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // Imposta il fuso orario locale per la programmazione
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // INITIALIZE
  Future<void> initNotification() async{
    if(_isInitialized) return;

    // PASSO FONDAMENTALE: inizializzazione dei fusi orari
    await _configureLocalTimeZone();

    // prepare android init settings
    const initSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // prepare ios init settings
    const initSettingsIOS =DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // finally, initialize the plugin
    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  // NOTIFICATIONS DETAIL SETUP - This method provides the required channel settings.
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id_1', // IMPORTANT: Use a unique ID here
          'Notifiche Generiche',
          channelDescription: 'Canale per le notifiche generiche dell\'app.',
          importance: Importance.max,
          priority: Priority.high,
          // Optional: add sound, vibration settings if needed
        ),
        iOS: DarwinNotificationDetails()
    );
  }

  // SHOW NOTIFICATION (per notifica immediata)
  Future<void> showNotification({
    int id = 0, // Default ID to 0 if not provided
    String? title,
    String? body,
  }) async {
    // CRITICAL FIX: Use the configured notificationDetails() method
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  // ----------------------------------------------------------------------
  // NUOVA FUNZIONE: PROGRAMMAZIONE GIORNALIERA RICORRENTE
  // ----------------------------------------------------------------------

  // Helper method to determine the next instance of the given time
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Se l'orario programmato è già passato oggi, programma per domani
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // SCHEDULE DAILY NOTIFICATION
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time, // Orario in cui la notifica deve apparire (es. 9:00)
  }) async {
    // Rimuoviamo i parametri 'androidScheduleMode' e 'uiLocalNotificationDateInterpretation'
    // per risolvere l'errore di compilazione sulla versione del pacchetto dell'utente.
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      notificationDetails(),
      // La notifica si ripete quotidianamente all'orario specificato
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  // FUNZIONE PER ANNULLARE TUTTE LE NOTIFICHE PROGRAMMATE
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}