import 'package:flutter/material.dart';
import 'package:mpr/screens/transaction_history_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WithDrawDetailScreen extends StatefulWidget {
  final String transactionId;

  const WithDrawDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<WithDrawDetailScreen> createState() => _WithDrawDetailScreenState();
}

class _WithDrawDetailScreenState extends State<WithDrawDetailScreen> {
  // Variables declaration
  String uid = '';
  String status = '';
  double withdrawalAmount = 0.0;
  String date = '';

  // Formater currency
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _getDataTransaction();
  }

  // Navigate to Transaction History Screen
  void _navigatorToTransactionHistoryScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TransactionHistoryScreen(
          uid: uid,
        ),
      ),
    );
  }

  // Show Snackbar
  void showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(
        seconds: 3,
      ),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    // Display the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Delete transaction
  Future<void> _deleteTransaction() async {
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      double saldoCancel = withdrawalAmount / 200;

      await userDocRef.update({'saldo': FieldValue.increment(saldoCancel)});

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transactionId)
          .delete();

      _navigatorToTransactionHistoryScreen();
    } catch (e) {
      showSnackbar(
        'Terjadi kesalahan saat membatalkan penukaran: $e',
      );
    }
  }

  Future<void> _getDataTransaction() async {
    try {
      DocumentSnapshot transactionDocSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transactionId)
          .get();

      if (transactionDocSnapshot.exists) {
        Map<String, dynamic> transactionData =
            transactionDocSnapshot.data() as Map<String, dynamic>;

        Timestamp transactionTimestamp = transactionData['timestamp'];

        setState(() {
          uid = transactionData['userId'];
          status = transactionData['status'];
          withdrawalAmount = transactionData['inoutmoney'];
          date = DateFormat('dd MMMM yyyy, HH:mm')
              .format(transactionTimestamp.toDate());
        });
      } else {
        showSnackbar('Transaksi tidak ditemukan');
      }
    } catch (error) {
      showSnackbar('Terjadi kesalahan: $error');
    }
  }

  Widget _buildTransactionInfo() {
    return Column(
      children: [
        Text(
          'Status: $status',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        QrImageView(
          data: widget.transactionId,
          version: QrVersions.auto,
          size: 250,
          gapless: false,
        ),
        const SizedBox(height: 10),
        const Text(
          'Total Uang',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formatter.format(withdrawalAmount),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Tanggal tukar: $date',
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'Detail Tukar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        leading: IconButton(
          onPressed: _navigatorToTransactionHistoryScreen,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Silakan scan QR Code ke petugas terdekat',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildTransactionInfo(),
                ],
              ),
              Visibility(
                visible: (status == 'Proses'),
                child: GestureDetector(
                  onTap: _deleteTransaction,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Batalkan Penukaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
