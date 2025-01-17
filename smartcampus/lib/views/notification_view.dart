import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import '../controllers/notification_controller.dart';

class NotificationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.to;

    Future<void> sendPushNotification(String title, String body) async {
      const String fcmUrl = 'https://fcm.googleapis.com/v1/projects/smartcampus-5a/messages:send';

      // Masukkan konten file Service Account JSON Anda di sini
      final serviceAccount = ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "smartcampus-5a",
        "private_key_id": "9aefab9428fd55dae2e5643f1f46e651467e0948",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDSPAUlcpE1LUAq\nyRYB/JpwK+FWTwB0ruZFYt3abBCFaNBIl4Yfdxxq202hZtcMUIwR0SaKcty9VJO/\nPdEg+SC99DUf4dzNWoO7KLRm4p37KTVMUcY1RY+0tCaIJZsKa1xZ59LkHbIBoLnj\nbSZwnfaffehjWCEvvrI3r7K9swQNVkR+vmUtJF3Tv9v+1RxxRiwflSFhQg14+Jua\n3epRvBIB5QgfYYDztvmznasqKc4aeCCc7JZpNUTo4BMcx6ngJNvYBwJijzcAFzXM\nkE3k0ghK0bE4VXWGJVgfDS225phh5Nw2yZv1O9+o/NkgnxRnx4LPa11PtweHqaee\noi/r+m91AgMBAAECggEACX1uGgpO5bXyNJGOgxkc+5KaLGQ1OA8rvoFqVFFrztSJ\nZQ159Men/7wrMphK0s0mqtM5yHwg3Lxe+FNZB60B6QaHXgtlr9tgdj1YegshaH9W\ntD2TaJTdmiGbr6pK57CATbVPlBPcai261mT3Rul1LYPoeTuMMUnhZO7IbxRlSsNq\nKaAsn1xYazmxlNLmV7qhPB9NoByEm9p3dQeqbZgkofQz+KryRoakF5xMwkgQyPHS\nmZJzsD1lZo45kfLr8i7MVTHRjtTU2+q7bzHnX/carHsPwL0nzCWeQO7ZlBf8c265\neUUe0UNu7ERJ4omqRxZlCBakObCiWD8wyA/WsqnB7QKBgQD2Hv/dEegvKg9Urin7\nVBdxRGdrV4rvfa0wsZtpvkJWuy3wiMxrWpbor7634EyX3htvWtCaPXldLlllx9qD\n4fEFbw8hW5v83Oh9FQf2LOa8SmQIgpO7FfJik7zOXv0sqnHpbymA9+h5+rxUGGBP\niajz6Y0lKSV17MIg7W+HfGq25wKBgQDarEUZ7freBTSKU/GrhBNFxEIC0QW3Hebz\nxFPTzOoQPtNsqduk8jTAqOrU1eStTq8OP9rb8t+AlTRBfmuzaUwqwO7BrIt4JbLU\nlmsD/hYpvaVldebVlYvalYQiSIRx2mxDsNCzqYJXQVf1I6EWx7wvqtm4oHOCWznR\nlLtYwEnHQwKBgQCdX0r5X0bYSYuN+OMtKiLnMPbz4wEai4CfPyGBpr8iWANS5xXW\nmxEdbaqERm6TONjQBgCWbzJYC5fsBbNKWsFTWSUSjlIaiGI8AKObnDBZOzPlYSD3\nIlxe/dpfFsvJsJ6vxX2DUoEa5eFf4EpM8VfPxomStlGWqrGifk+vETXnBwKBgQDT\nFrkd7rzc1emCHsaL61MvZeTTEzORMSxg5ISHUKgiRoORweZls+l4kZcfHdtB8VLL\nTpjW+f0HAwEOuBr/dgYwv027Z/S6ZqnazdlAYWbDpG6lIstSIqp+txZ2gcpYnaEl\nNupAhMFtuYZO/bXjZ6wh16uUrk7S531I82pmojiWQQKBgQCaCVH+tklJOpIyO76/\ncL2MfW5q+cA5T9JoF/c2AlrRTXK7zi2ORk5tZShBLhRvbFhWMyBjY93pc/VXa7Qj\nZjLMlzxtbT/5t036JNzcfOuCUeK/827umO0cmAZeYPAQbhLpkaV0bZ8Tf9w3Gk+0\nNjM6CPlZ1oQwdXN+N/hu+yrIOg==\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-msxof@smartcampus-5a.iam.gserviceaccount.com",
        "client_id": "118270901379749461023",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-msxof%40smartcampus-5a.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      });

      try {
        final authClient = await clientViaServiceAccount(
          serviceAccount,
          ['https://www.googleapis.com/auth/firebase.messaging'],
        );

        final response = await authClient.post(
          Uri.parse(fcmUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "message": {
              "topic": "general", // Target spesifik topik
              "notification": {
                "title": title,
                "body": body,
              },
              "data": {
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                "status": "done"
              }
            }
          }),
        );

        if (response.statusCode == 200) {
          print('Push notification sent successfully');
          Get.snackbar('Push Notification', 'Notification sent successfully.');
        } else {
          print('Failed to send push notification: ${response.body}');
          Get.snackbar('Error', 'Failed to send push notification.');
        }

        authClient.close();
      } catch (e) {
        print('Error sending push notification: $e');
        Get.snackbar('Error', 'An error occurred while sending notification.');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert),
            onPressed: () {
              controller.addNotification(
                title: 'Test Notification',
                body: 'This is an in-app test notification.',
              );
              Get.snackbar('Test Notification', 'This is an in-app test notification.');
            },
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              sendPushNotification('Push Test', 'This is a test push notification.');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(child: Text('No notifications yet.'));
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return ListTile(
              title: Text(notification['title'] ?? 'No Title'),
              subtitle: Text(notification['body'] ?? 'No Body'),
              leading: Icon(Icons.notifications),
            );
          },
        );
      }),
    );
  }
}
