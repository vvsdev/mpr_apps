import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpr/screens/deposit_screen.dart';
import 'package:mpr/screens/transaction_history_screen.dart';
import 'package:mpr/screens/withdraw_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instance firebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data user
  double saldo = 0;
  String name = '';
  String uid = '';

  // Formater currency
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

  // Get current user data
  void getCurrentUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        uid = user.uid;

        DocumentSnapshot userDocSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDocSnapshot.exists) {
          Map<String, dynamic> userData =
              userDocSnapshot.data() as Map<String, dynamic>;
          setState(() {
            saldo = (userData['saldo'] as num).toDouble();
            name = userData['name'];
          });
        } else {
          _showSnackBarIfError('Dokumen tidak ditemukan');
        }
      }
    } catch (error) {
      _showSnackBarIfError('Terjadi kesalahan: $error');
    }
  }

  // Signout logic
  Future<void> _logoutWithEmailAndPassword() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      _showSnackBarIfError(e.code);
    }
  }

  // Navigator to change point screen
  void _navigatorToChangePointScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WithDrawScreen(
          saldo: saldo,
          uid: uid,
        ),
      ),
    );
  }

  // Navigator to transaction history screen
  void _navigatorToTransactionHistoryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionHistoryScreen(
          uid: uid,
        ),
      ),
    );
  }

  // Navigator to transaction history screen
  void _navigatorToDepositScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DepositScreen(
          uid: uid,
          saldo: saldo,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        leading: IconButton(
          icon: const Icon(Icons.refresh), // Ikon segar (refresh)
          onPressed:
              getCurrentUserData, // Panggil fungsi refresh saat tombol ditekan
        ),
        actions: [
          IconButton(
            onPressed: _logoutWithEmailAndPassword,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.asset(
                        'assets/images/mpr_logo_3.png',
                        width: 70,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi $name',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Kamu ada sampah dari ini?',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 45),
                Card(
                  color: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey.shade900,
                      width: 2.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Saldo',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  ' | DutaSampah',
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formatter.format(saldo),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${formatter.format(saldo * 200)}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              color: Colors.grey.shade900,
                              width: 2,
                              height: 80,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: _navigatorToChangePointScreen,
                                  icon: const Icon(
                                      Icons.currency_exchange_rounded),
                                ),
                                const Text('Tukar'),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed:
                                      _navigatorToTransactionHistoryScreen,
                                  icon: const Icon(Icons.history),
                                ),
                                const Text('Riwayat'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 45),
                const Text(
                  'Terima kasih kamu sudah berkontribusi atas kebersihan lingkungan sekitar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            GestureDetector(
              onTap: _navigatorToDepositScreen,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Buang Sampah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
