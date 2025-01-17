import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _profileImage; // Untuk menyimpan foto profil sementara
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isBiometricEnabled = false; // Status biometrik

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Muat gambar profil dari local storage saat inisialisasi
    _loadBiometricPreference(); // Muat preferensi biometrik
    if (_currentUser != null) {
      _nameController.text = _currentUser!.displayName ?? '';
      _emailController.text = _currentUser!.email ?? '';
    }
  }

  // Fungsi Memilih Gambar
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _saveProfileImage(_profileImage!); // Simpan ke local storage
    }
  }

  // Simpan Gambar ke Local Storage
  Future<void> _saveProfileImage(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedImage = File('${directory.path}/profile_image.jpg');
    await file.copy(savedImage.path);
  }

  // Muat Gambar dari Local Storage
  Future<void> _loadProfileImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final savedImage = File('${directory.path}/profile_image.jpg');

    if (await savedImage.exists()) {
      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  // Simpan preferensi biometrik
  Future<void> _saveBiometricPreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', isEnabled);
    setState(() {
      _isBiometricEnabled = isEnabled;
    });
  }

  // Muat preferensi biometrik
  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }

  // Fungsi Update Nama
  Future<void> _updateName() async {
    try {
      if (_currentUser != null) {
        await _currentUser!.updateDisplayName(_nameController.text);
        await _currentUser!.reload();
        setState(() {
          _currentUser = FirebaseAuth.instance.currentUser;
        });
        Get.snackbar('Success', 'Name updated successfully.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update name: $e');
    }
  }

  // Fungsi Update Email
  Future<void> _updateEmail() async {
    try {
      if (_currentUser != null) {
        await _currentUser!.updateEmail(_emailController.text);
        await _currentUser!.reload();
        setState(() {
          _currentUser = FirebaseAuth.instance.currentUser;
        });
        Get.snackbar('Success', 'Email updated successfully.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update email: $e');
    }
  }

  // Fungsi Update Password
  Future<void> _updatePassword() async {
    try {
      if (_passwordController.text.isNotEmpty) {
        await _currentUser!.updatePassword(_passwordController.text);
        Get.snackbar('Success', 'Password updated successfully.');
      } else {
        Get.snackbar('Error', 'Password cannot be empty.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update password: $e');
    }
  }

  // Fungsi untuk Mengaktifkan Biometrik
  Future<void> _toggleBiometric() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!canCheckBiometrics) {
        Get.snackbar('Error', 'Biometric authentication is not available.');
        return;
      }

      setState(() {
        _isBiometricEnabled = !_isBiometricEnabled;
      });

      await _saveBiometricPreference(_isBiometricEnabled);

      if (_isBiometricEnabled) {
        Get.snackbar('Success', 'Biometric authentication enabled.');
      } else {
        Get.snackbar('Success', 'Biometric authentication disabled.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle biometric: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _currentUser?.displayName ?? 'User';
    final email = _currentUser?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login'); // Navigasi ke halaman login
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                displayName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: _updateName,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: _updateEmail,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: _updatePassword,
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _toggleBiometric,
                icon: Icon(Icons.fingerprint),
                label: Text(_isBiometricEnabled ? 'Disable Biometrics' : 'Enable Biometrics'),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Academic History'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.toNamed('/academic-history'); // Navigasi ke riwayat akademik
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Language Settings'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.toNamed('/settings'); // Navigasi ke pengaturan bahasa
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Get.offAllNamed('/login'); // Logout dan navigasi ke login
                },
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
