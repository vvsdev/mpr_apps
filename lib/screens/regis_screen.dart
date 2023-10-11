import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mpr/screens/home_screen.dart';
import 'package:mpr/screens/login_screen.dart';

class RegisScreen extends StatefulWidget {
  const RegisScreen({super.key});

  @override
  State<RegisScreen> createState() => _RegisScreenState();
}

class _RegisScreenState extends State<RegisScreen> {
  // User input
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();
  final TextEditingController _userConfirmationPassword =
      TextEditingController();

  // Instance firebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading indicator
  bool isLoading = false;

  // Registration logic
  Future<void> _registrationWithEmailAndPassword() async {
    // Check if password not same with confirmation password
    if (_userPassword.text != _userConfirmationPassword.text) {
      showSnackbar('Password konfirmasi tidak sama dengan password');
    } else {
      setState(() {
        isLoading = true;
      });

      // Registration process
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _userEmail.text,
          password: _userPassword.text,
        );

        // Get user credential
        User? user = userCredential.user;

        // Set initiation balance of user
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': _userName.text,
            'saldo': 0.0,
            'role': 'user',
          });
        }

        showSnackbar('Pendaftaran berhasil! UserID: ${user?.uid}');

        // Navigate to login screen
        _navigateToHomeScreen();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showSnackbar('Password terlalu lemah');
        } else if (e.code == 'email-already-in-use') {
          showSnackbar('Email sudah terpakai oleh user lain');
        } else {
          showSnackbar(e.code);
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Snackbar popup
  void showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(
          seconds: 3), // Optional: How long the snackbar will be displayed
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // You can add an action to the snackbar here
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    // Display the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Navigate to login screen
  void _navigateToLoginScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  // Navigate to home screen
  void _navigateToHomeScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  // Logo
                  Image.asset(
                    'assets/images/mpr_logo_2.png',
                    width: 150,
                  ),

                  const SizedBox(height: 45),

                  // Welcoming text
                  const Text(
                    'Selamat datang, silakan daftarkan diri',
                    style: TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    controller: _userEmail,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                    ),
                    autocorrect: false,
                    controller: _userName,
                  ),

                  const SizedBox(height: 15),

                  // Input password
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                    ),
                    obscureText: true,
                    controller: _userPassword,
                  ),

                  const SizedBox(height: 15),

                  // Input password confirmation
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                    ),
                    obscureText: true,
                    controller: _userConfirmationPassword,
                  ),

                  const SizedBox(height: 20),

                  // Button login
                  GestureDetector(
                    onTap: _registrationWithEmailAndPassword,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun?',
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: _navigateToLoginScreen,
                        child: const Text(
                          ' Login disini',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Loading indicator
                  if (isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
