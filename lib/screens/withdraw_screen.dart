import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpr/screens/withdraw_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithDrawScreen extends StatefulWidget {
  final double saldo;
  final String uid;

  const WithDrawScreen({
    Key? key,
    required this.saldo,
    required this.uid,
  }) : super(key: key);

  @override
  State<WithDrawScreen> createState() => _WithDrawScreenState();
}

class _WithDrawScreenState extends State<WithDrawScreen> {
  final TextEditingController _pointController =
      TextEditingController(text: '0');
  TextEditingController resultController = TextEditingController(text: '0');
  TextEditingController result = TextEditingController(text: '0');

  // Formater currency
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _pointController.dispose();
    resultController.dispose();
    result.dispose();
    super.dispose();
  }

  void _calculateResult(double point) {
    final x = point * 200;
    result.text = formatter.format(x);
    resultController.text = x.toString();
  }

  Future<void> _checkPointIsCorrect() async {
    try {
      double withdrawalAmount = double.parse(_pointController.text);

      if (withdrawalAmount < 50.0) {
        showSnackbar('Minimal penarikan adalah 50 poin');
        return;
      }

      if (withdrawalAmount > widget.saldo) {
        showSnackbar('Jumlah saldo anda tidak cukup');
        return;
      }

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);

      double updatedBalance = widget.saldo - withdrawalAmount;

      await userDocRef.update({'saldo': updatedBalance});

      DocumentReference transactionDocRef =
          await FirebaseFirestore.instance.collection('transactions').add({
        'userId': widget.uid,
        'inoutmoney': double.parse(resultController.text),
        'status': 'Proses',
        'type': 'Withdraw',
        'admin': '-',
        'timestamp': FieldValue.serverTimestamp(),
      });

      String transactionId = transactionDocRef.id;
      _navigatorToWithDrawDetailScreen(transactionId);
    } catch (error) {
      showSnackbar('Terjadi kesalahan: $error');
    }
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

  void _navigatorToWithDrawDetailScreen(String transactionId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WithDrawDetailScreen(
          transactionId: transactionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'Tukar Poin',
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
                  'Kamu dapat menukarkan poinmu dengan uang cash atau reward yang lain.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Masukkan poin (min 50)',
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
                  controller: _pointController,
                  onChanged: (value) {
                    _calculateResult(value.isEmpty ? 0 : double.parse(value));
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
                  controller: result,
                ),
                const SizedBox(height: 25),
                const Text(
                  'Hasil konversi merupakan uang yang dapat kamu tukarkan di gerai-gerai terdekat kami.',
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
                    'Tukar',
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
