import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        "private_key_id": "f38cfa542d3cbcee49c2835734efb3c80b5927a9",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCz/7n+wRbSRMSp\nR5LFg1w1HCNP+RtEM+iHP9Jw1q1M2ebMzxXZbpzVhY9MFTp3MuIEeoAuOFg0D/UL\nLy8ip6DVtVHflENIgaeHosw/prllY3y46/dqYWgqeTy5dt2aJ5tOSb54mlrUQuQg\nPP8DTetda/yl/KBWL6QHlN3zjH/+CDfL4bFTNR1BX50kY4kcHPmZzN3kvKoGWVCM\nr7StvfYK2UrFblToe1BLGBPvdMJujurC/fML1Y8q1UwDrHcqQmKELMWWWblJkpMr\nU3YZ7DEjQoPQOEg0P7xwTnfpjBpS9mIYa+uHSaQN9a2nXSliJlhsAVOCNS4iRyMZ\nbvei26zhAgMBAAECggEAAJ7Qo2sDMv+TbXFulTFwFYtGqGGHiWdD5YZv6V1mDMIi\nAGH01XJjBj3e+fBHSq6hVopdC3u8exZ0feDAYPZSsLXepb5/Ml5nB0nFejEvCaVL\ngmAm0sYp656OGeYJ2ryI9Z69sjD2/+0Il/9Z0ic4ONLU1LYfj9h7cF7AGpUpAkU/\nvw061AZ3bhWY5CoHmMU2Hi2P4QE0nfNEVJnK3RrRwAFNSLWlGVI80lB/feK43TCl\nL7NuOfQMXKgXBG/vduaWlZ0z3s+Az4Upc6mUoKP3l1sb7gb5Vyxjs8bp7DxqYne7\n8BStqZLxEP19omq4Iq1MG9FGz65EgRZjFpYXoJeZaQKBgQDn30EM4gVW5W1KPEvL\nxa4oXv+z8N/olThmLw4Zl7QsJHA1rfDTtWJ9qwL1nvIm7p7aCOJgjYjYQpQqA4dl\nTOy2hqyvA5CYkr6u/Rr58QNq43oqwwn7DNOlN+C/YzD29lki6Tpxr1WxStvRxGv5\nR13XXb0sGeEYFgGQ3Q79IUmyCQKBgQDGuqUHUq00YUyYmJAl1ZZ4YrDD36Y3RwrH\nqiLZrfxaUgWVt2BBD5TD1SFhULFb/SomJuugysYxyZD63lbEIY99k3z9MwR+DJHn\nfxQHvSG/OXa0aqa67IJ5WgPOvTls4TnCTGM11rOctATkWYuM4BDbmGJTX70jYz1L\n/0BtVYl6GQKBgQDNisNQVz9ic0g5SU/rV9X1ZZkH+puRwk1Xj5jRKQCHLNnnS8Sy\n9xRSz/h0oSyJRHe+UafS7UQEaKiMwcoRC2q+to13KxLPnS25UxbJv1NHOlT+eRxs\n1kb7K5hoL9ak5WXIo7SyODofSnun7JXGSPQvyKG76Uj3H/LNZpg13X9FeQKBgQC8\n9X2zb9aHRrkZI390qhlwEI75QDAAwYkrfseyaW/YxcLPr9RTKKiQaJhbuulZiWhJ\nbJqBgi1f68Px9fVUeoDAq7ud2aO84uDc2IVIMnrjI5WOSRaOCBKrpn6WVnBC6gkM\niauP5r1UFAvOwKIjam49DzD3C8KA4nzHRUaSb1HQCQKBgQCL9LyBUMIjmx821mwq\nWFwl3RDPscV5F7brfBOafuWa+41lt3glsOiIl9B00+ggWX0bngBgLEtCAgWqGwzj\n3HTcdPrGSM/IjbLlUvkdYmHTfMcE20XqQLhPKIyU968DteIKK4D9F7u+f1QXNVeU\n6XzB0Ad64Itlq5mTOzG9bjCihg==\n-----END PRIVATE KEY-----\n",
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
