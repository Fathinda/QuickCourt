import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        _showMessage(
            context, "Email belum diverifikasi. Silakan cek email Anda.");
        return;
      }

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false);
        await sendTokenToLaravel(context, user);
      }
    } catch (e) {
      _showMessage(context, "Login Gagal: $e");
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false);

        final tokenSuccess = await sendTokenToLaravel(context, user);

        if (!tokenSuccess) {
          _showMessage(context, "Gagal login ke server. Coba lagi.");
          return null;
        }

        return userCredential;
      } else {
        _showMessage(context, "User tidak ditemukan saat login Google.");
        return null;
      }
    } catch (e) {
      _showMessage(context, "Google Sign-In gagal: $e");
      return null;
    }
  }

  Future<bool> sendTokenToLaravel(BuildContext context, User user) async {
    try {
      final idToken = await user.getIdToken(true);
      final displayName = user.displayName;

      final response = await http.post(
        Uri.parse('http://192.168.1.12:8000/api/firebase-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'display_name': displayName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('laravel_token', data['token']);
        await prefs.setString('name', data['user']['name']);
        return true;
      } else {
        _showMessage(context, "Login Laravel gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      _showMessage(context, "Gagal kirim token: $e");
      return false;
    }
  }

  Future<void> continueAsGuest(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
