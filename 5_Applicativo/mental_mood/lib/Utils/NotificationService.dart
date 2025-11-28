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
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // METODO PER CONFIGURARE IL FUSO ORARIO LOCALE
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      // Prova a prendere il fuso orario del dispositivo
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // FALLBACK: Se fallisce, usa UTC o un fuso orario di default sicuro
      print("Errore fuso orario, uso default UTC: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel',
          'Promemoria Giornalieri',
          channelDescription: 'Canale per i promemoria.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails()
    );
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
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    _isInitialized = true;


    const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
      'daily_notification_channel',
      'Promemoria Giornalieri',
      description: 'Canale per i promemoria.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }



  // SHOW NOTIFICATION (per notifica immediata)
  Future<void> showNotification({
    int id = 0, // Default ID to 0 if not provided
    String? title,
    String? body,
  }) async {
    return flutterLocalNotificationsPlugin.show(id, title, body, _notificationDetails());
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
    required TimeOfDay time,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      _notificationDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      // La notifica si ripete quotidianamente all'orario specificato
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // FUNZIONE PER ANNULLARE TUTTE LE NOTIFICHE PROGRAMMATE
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}