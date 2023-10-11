import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mpr/screens/home_screen.dart';

class DepositScreen extends StatefulWidget {
  final String uid;
  final double saldo;

  const DepositScreen({
    Key? key,
    required this.uid,
    required this.saldo,
  }) : super(key: key);

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  // User input controller
  //final TextEditingController _adminInputController = TextEditingController();
  final TextEditingController _massInputController = TextEditingController();
  final TextEditingController _covertResult = TextEditingController();

  String selectedValue = 'Fatih Ahmad A';

  // Mass coverter to point function
  // Input in Kilograms
  void _convertMassToPoint(double mass) {
    final result = mass * 10;
    _covertResult.text = result.ceil().toString();
  }

  // Insert the result to database
  Future<void> _checkPointIsCorrect() async {
    try {
      double depositAmount = double.parse(_covertResult.text);

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);

      double updatedBalance = widget.saldo + depositAmount;

      await userDocRef.update({'saldo': updatedBalance});

      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': widget.uid,
        'inoutmoney': double.parse(_covertResult.text),
        'status': 'Berhasil',
        'admin': selectedValue,
        'type': 'Deposit',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _navigatorToHomeScreen();
    } catch (error) {
      showSnackbar('Terjadi kesalahan: $error');
    }
  }

  // Navigation to home screen
  void _navigatorToHomeScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'Buang Sampah',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Silakan timbang sampahmu dan masukkan hasilnya ke aplikasi untuk dikonversi',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Masukkan nama admin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // TextFormField(
                //   decoration: InputDecoration(
                //     enabledBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.grey.shade500),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.grey.shade500),
                //     ),
                //     fillColor: Colors.grey.shade200,
                //     filled: true,
                //   ),
                //   autocorrect: false,
                //   controller: _adminInputController,
                // ),
                DropdownButton<String>(
                  value: selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items: <String>[
                    'Fatih Ahmad A',
                    'Admin',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Masukkan berat (Kg)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  controller: _massInputController,
                  onChanged: (value) {
                    _convertMassToPoint(
                        value.isEmpty ? 0 : double.parse(value));
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  'Hasil konversi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                  ),
                  enabled: false,
                  controller: _covertResult,
                ),
                const SizedBox(height: 25),
                const Text(
                  'Selamat kamu telah mengumpulkan poin, dengan menekan tombol buang maka poin kamu akan masuk ke saldo',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            GestureDetector(
              onTap: _checkPointIsCorrect,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Buang',
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
