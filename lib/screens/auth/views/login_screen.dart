import 'package:flutter/material.dart';
import 'package:quick_court_booking/constants.dart';
import 'package:quick_court_booking/entry_point.dart';
import 'package:quick_court_booking/helper/loading_helper.dart';
import 'package:quick_court_booking/route/route_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quick_court_booking/route/screen_export.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    LoadingHelper.showLoading(context);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email belum diverifikasi. Silakan cek email Anda."),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false);
        await sendTokenToLaravel(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Gagal: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    LoadingHelper.showLoading(context);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false);

        final tokenSuccess = await sendTokenToLaravel(user);

        if (!tokenSuccess) {
          if (!mounted) return null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal login ke server. Coba lagi.")),
          );
          return null;
        }

        if (!mounted) return null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EntryPoint()),
        );
        return userCredential;
      } else {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("User tidak ditemukan saat login Google.")),
        );
        return null;
      }
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In gagal: $e")),
      );
      return null;
    }
  }

  Future<bool> sendTokenToLaravel(User user) async {
    try {
      final idTokenResult = await user.getIdTokenResult(true);
      final idToken = idTokenResult.token;
      await Clipboard.setData(ClipboardData(text: idToken!));
      print("🔥 Token copied to clipboard.");
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

        print('✅ Token Laravel disimpan: ${data['token']}');

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Laravel gagal: ${response.body}")),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal kirim token: $e")),
      );
      return false;
    }
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const EntryPoint()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login_quickcourt.jpg",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                      "Log in with your data that you entered during registration."),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                  SizedBox(
                      height: size.height > 700
                          ? size.height * 0.1
                          : defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Log in"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Image.asset(
                        "assets/icons/google.png",
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        "Login With Google",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final userCred = await signInWithGoogle();
                        if (userCred != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Signed in as ${userCred.user?.email}")),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: continueAsGuest,
                      child: const Text("Lewati (Masuk sebagai Tamu)"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
