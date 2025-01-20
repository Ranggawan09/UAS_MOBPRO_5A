import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?; // Ambil data dari arguments
    final role = arguments?['role'] ?? 'Unknown';

    // Mendapatkan user saat ini dari FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User'; // Jika nama kosong, default menjadi "User"
    final userEmail = user?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: Text('Nama Aplikasi'), // Nama aplikasi
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Get.toNamed('/notifications'); // Navigasi ke halaman NotificationView
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Get.toNamed('/profile'); // Navigasi ke halaman ProfileView
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to SmartCampus!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Your name: $userName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Your email: $userEmail',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 16),
            Text('Your role: $role',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
