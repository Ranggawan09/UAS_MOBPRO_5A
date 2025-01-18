import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  // List of roles
  final List<String> roles = ['mahasiswa', 'dosen', 'staff'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Input
            TextField(
              controller: authController.nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),

            // Email Input
            TextField(
              controller: authController.emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),

            // Password Input
            TextField(
              controller: authController.passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),

            // Role Dropdown
            Text(
              'Select your role:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Obx(() => DropdownButton<String>(
              value: authController.selectedRole.value.isEmpty
                  ? null
                  : authController.selectedRole.value,
              hint: Text('Choose your role'),
              isExpanded: true,
              items: roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                authController.selectedRole.value = value!;
              },
            )),
            SizedBox(height: 20),

            // Register Button
            Obx(() => authController.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () {
                // Validate inputs
                if (authController.nameController.text.isEmpty ||
                    authController.emailController.text.isEmpty ||
                    authController.passwordController.text.isEmpty ||
                    authController.selectedRole.value.isEmpty) {
                  Get.snackbar('Error', 'Please fill all fields');
                  return;
                }

                // Call register function
                authController.register(
                  authController.nameController.text.trim(),
                  authController.emailController.text.trim(),
                  authController.passwordController.text.trim(),
                  authController.selectedRole.value.trim(),
                );
              },
              child: Text('Register'),
            )),
            SizedBox(height: 20),

            // Resend Verification Email Button
            Obx(() {
              if (!authController.isLoading.value) {
                return ElevatedButton.icon(
                  onPressed: () {
                    authController.resendVerificationEmail();
                  },
                  icon: Icon(Icons.email),
                  label: Text('Resend Verification Email'),
                );
              } else {
                return Container(); // Tidak menampilkan tombol jika sedang loading
              }
            }),
          ],
        ),
      ),
    );
  }
}
