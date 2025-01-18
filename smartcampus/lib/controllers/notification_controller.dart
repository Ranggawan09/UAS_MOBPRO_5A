import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  var notifications = <Map<String, String>>[].obs;

  // Add a new notification to the list
  void addNotification({required String title, required String body}) {
    notifications.add({"title": title, "body": body});
  }

  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications (for iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Get the FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.notification?.title}, ${message.notification?.body}');
      Get.snackbar(
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'You have a new notification',
        snackPosition: SnackPosition.TOP,
      );
      NotificationController.to.addNotification(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? 'No Body',
      );
    });

    // Handle app opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
        NotificationController.to.addNotification(
          title: message.notification?.title ?? 'No Title',
          body: message.notification?.body ?? 'No Body',
        );
      }
    });
  }
}
