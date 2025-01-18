import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Email
            TextField(
              controller: authController.emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),

            // Input Password
            TextField(
              controller: authController.passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),

            // Tombol Login
            Obx(() => authController.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () {
                if (authController.emailController.text.isEmpty ||
                    authController.passwordController.text.isEmpty) {
                  Get.snackbar('Error', 'All fields are required');
                  return;
                }

                // Panggil fungsi login
                authController.login(
                  authController.emailController.text.trim(),
                  authController.passwordController.text.trim(),
                );
              },
              child: Text('Login'),
            )),
            SizedBox(height: 16),

            // Tombol Login dengan Biometrik
            Obx(() {
              if (authController.isBiometricEnabled.value) {
                return ElevatedButton.icon(
                  onPressed: () {
                    authController.loginWithBiometrics();
                  },
                  icon: Icon(Icons.fingerprint),
                  label: Text('Login with Biometrics'),
                );
              } else {
                return Container(); // Tidak menampilkan tombol jika biometrik tidak aktif
              }
            }),
            SizedBox(height: 16),

            // Navigasi ke halaman Register
            TextButton(
              onPressed: () {
                Get.toNamed('/register');
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
