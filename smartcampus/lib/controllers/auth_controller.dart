import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // TextEditingController untuk email, nama dan password
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  // RxString untuk selectedRole
  var selectedRole = ''.obs;

  // State loading
  var isLoading = false.obs;

  // State biometrik
  var isBiometricEnabled = false.obs;

  // Firebase instances
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Local Authentication instance
  final LocalAuthentication localAuth = LocalAuthentication();

  // Fungsi Login
  Future<void> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'Email and password cannot be empty.');
        return;
      }

      isLoading(true);

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      // Cek apakah email sudah diverifikasi
      if (user != null && !user.emailVerified) {
        Get.snackbar('Error', 'Please verify your email before logging in.');
        auth.signOut();
        return;
      }

      // Ambil data role dari Firestore
      DocumentSnapshot userDoc = await firestore.collection('users').doc(user?.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        String role = userDoc.get('role') ?? 'unknown';

        // Simpan ke state GetX
        Get.offAllNamed('/home', arguments: {'role': role});
      } else {
        Get.snackbar('Error', 'User data not found in Firestore.');
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }


  // Fungsi Login dengan Biometric Authentication
  Future<void> loginWithBiometrics() async {
    try {
      // Cek apakah biometrik tersedia
      bool canAuthenticate = await localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        Get.snackbar('Error', 'Biometric authentication is not available.');
        return;
      }

      // Verifikasi biometrik
      bool authenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        User? currentUser = auth.currentUser;

        if (currentUser != null) {
          DocumentSnapshot userDoc = await firestore.collection('users').doc(currentUser.uid).get();

          if (userDoc.exists && userDoc.data() != null) {
            String role = userDoc.get('role') ?? 'unknown';

            // Simpan ke state GetX
            Get.offAllNamed('/home', arguments: {'role': role});
          } else {
            Get.snackbar('Error', 'User data not found in Firestore.');
          }
        } else {
          Get.snackbar('Error', 'No authenticated user found.');
        }
      } else {
        Get.snackbar('Error', 'Biometric authentication failed.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Biometric authentication error: $e');
    }
  }

  // Fungsi Register
  Future<void> register(String name, String email, String password, String role) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
        Get.snackbar('Error', 'All fields are required.');
        return;
      }

      isLoading(true);

      // Buat akun baru di Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Simpan data pengguna ke Firestore
      await firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Perbarui nama pengguna di Firebase Authentication
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());

        // Kirim email verifikasi
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          Get.snackbar(
            'Verification Email Sent',
            'Please check your email to verify your account before logging in.',
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }


  // Kirim ulang email verifikasi
  Future<void> resendVerificationEmail() async {
    try {
      User? user = auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar('Verification Email Sent', 'A new verification email has been sent to your email address.');
      } else {
        Get.snackbar('Error', 'User not found or email is already verified.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send verification email: $e');
    }
  }



  // Fungsi untuk Menangani Error FirebaseAuth
  void _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        Get.snackbar('Error', 'No user found for that email.');
        break;
      case 'wrong-password':
        Get.snackbar('Error', 'Incorrect password.');
        break;
      case 'email-already-in-use':
        Get.snackbar('Error', 'The email address is already in use.');
        break;
      case 'weak-password':
        Get.snackbar('Error', 'The password is too weak.');
        break;
      default:
        Get.snackbar('Error', e.message ?? 'An unknown error occurred.');
        break;
    }
  }

  // Simpan status biometrik ke SharedPreferences
  Future<void> saveBiometricPreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', isEnabled);
    isBiometricEnabled.value = isEnabled;
  }

  // Muat status biometrik dari SharedPreferences
  Future<void> loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    isBiometricEnabled.value = prefs.getBool('biometricEnabled') ?? false;
  }

  @override
  void onInit() {
    super.onInit();
    loadBiometricPreference(); // Muat preferensi biometrik saat inisialisasi
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
