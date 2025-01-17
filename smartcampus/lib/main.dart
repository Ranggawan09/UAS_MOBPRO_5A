import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import '../controllers/notification_controller.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize NotificationController
  Get.put(NotificationController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NotificationController.initialize(); // Initialize FCM

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartCampus',
      initialRoute: AppRoutes.LOGIN,
      getPages: AppRoutes.pages,
    );
  }
}
