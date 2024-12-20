import 'package:e_shopping/screens/admin/best_selling_screen.dart';
import 'package:e_shopping/screens/admin/transaction_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'FeedBackListScreen.dart';
import 'category_form_screen.dart';
import 'product_form_screen.dart';
import 'best_selling_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDashboardButton(
              context,
              label: 'Manage Products',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductFormScreen()),
                );
              },
            ),
            _buildDashboardButton(
              context,
              label: 'Manage Categories',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryFormScreen()),
                );
              },
            ),
            _buildDashboardButton(
              context,
              label: 'Generate Transaction Reports',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionReportScreen()),
                );
              },
            ),
            _buildDashboardButton(
              context,
              label: 'View Feedback',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackListScreen()),
                );
              },
            ),
            _buildDashboardButton(
              context,
              label: 'View Best Sales',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BestSellingProductsChart()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a card button
  Widget _buildDashboardButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        title: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.blueAccent),
        onTap: onPressed,
      ),
    );
  }
}
