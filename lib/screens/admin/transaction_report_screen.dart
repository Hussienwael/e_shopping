import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // To format date


class TransactionReportScreen extends StatefulWidget {
    @override
    _TransactionReportScreenState createState() => _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
    final _dateController = TextEditingController();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<QueryDocumentSnapshot> _transactions = [];

    // Function to fetch transactions for a specific date
    Future<void> _generateReport() async {
        try {
        DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
        DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
        DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

        var querySnapshot = await _firestore
            .collection('transactions')
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThanOrEqualTo: endOfDay)
            .get();

        setState(() {
            _transactions = querySnapshot.docs;
        });
        } catch (e) {
        print("Error fetching transactions: $e");
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(title: Text('Transaction Report')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
            children: [
                TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Enter Date (yyyy-MM-dd)'),
                keyboardType: TextInputType.datetime,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                onPressed: _generateReport,
                child: Text('Generate Report'),
                ),
                SizedBox(height: 20),
                Expanded(
                child: ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                    var transaction = _transactions[index];
                    var transactionData = transaction.data() as Map<String, dynamic>;
                    return ListTile(
                        title: Text('Transaction ID: ${transaction.id}'),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                        Text('Amount: \$${transactionData['totalPrice']}'),
                                        Text('Date: ${transactionData['timestamp'].toDate()}'), ],
                        ),
                    );
                    },
                ),
                ),
            ],
            ),
        ),
        );
    }
}
