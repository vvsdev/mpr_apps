import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mpr/screens/withdraw_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String uid;

  const TransactionHistoryScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Riwayat Transaksi',
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
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: TransactionList(uid: widget.uid),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final String uid;

  TransactionList({
    Key? key,
    required this.uid,
  }) : super(key: key);

  // Formater currency
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada history transaksi'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final transaction = snapshot.data!.docs[index];
            final transactionId = transaction.id;
            final date = DateFormat('dd/MM/yyyy, HH:mm')
                .format(transaction['timestamp'].toDate());
            final type = transaction['type'];
            final status = transaction['status'];
            final admin = transaction['admin'];
            final inOutMoney = transaction['inoutmoney'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 0,
              color: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey.shade500,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text('Status: $status'),
                      type == "Withdraw"
                          ? Text('Jumlah: ${formatter.format(inOutMoney)}')
                          : Text(
                              'Jumlah: ${inOutMoney.ceil().toString()} poin'),
                      Text('Tanggal: $date'),
                      admin != '-'
                          ? Text('Admin: $admin')
                          : const Text('Admin: Menunggu Approval'),
                    ],
                  ),
                  onTap: () {
                    if (type == 'Withdraw') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WithDrawDetailScreen(
                              transactionId: transactionId),
                        ),
                      );
                    } else {}
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
