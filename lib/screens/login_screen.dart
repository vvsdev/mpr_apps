import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mpr/screens/regis_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // User input
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();

  // Instance firebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading indicator
  bool isLoading = false;

  // Login logic
  Future<void> _loginWithEmailAndPassword() async {
    // Loading state
    setState(() {
      isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _userEmail.text,
        password: _userPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackBarIfError('User tidak ditemukan');
      } else if (e.code == 'wrong-password') {
        _showSnackBarIfError('Password Anda salah');
      } else {
        _showSnackBarIfError(e.code);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Snackbar popup
  void _showSnackBarIfError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Navigate to registration screen
  void _navigateToRegisScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const RegisScreen(),
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
                    'Selamat datang kembali, silakan login',
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

                  // Input text email
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

                  // Lupa password
                  GestureDetector(
                    onTap: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Lupa Password?'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Button login
                  GestureDetector(
                    onTap: _loginWithEmailAndPassword,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Login',
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
                        'Belum punya akun?',
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: _navigateToRegisScreen,
                        child: const Text(
                          ' Daftar disini',
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
