import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import notifikasi lokal
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import '../controllers/notification_controller.dart';
import 'package:timezone/data/latest_all.dart' as tz; // Timezone
import 'package:timezone/timezone.dart' as tz;

// Handler pesan Firebase di background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

// Inisialisasi plugin notifikasi lokal
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inisialisasi timezone
  tz.initializeTimeZones();

  // Inisialisasi flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        print('Notification payload: ${response.payload}');
      }
    },
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize NotificationController
  Get.put(NotificationController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize FCM and Notification Controller
    NotificationController.initialize();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartCampus',
      initialRoute: AppRoutes.LOGIN,
      getPages: AppRoutes.pages,
    );
  }
}
