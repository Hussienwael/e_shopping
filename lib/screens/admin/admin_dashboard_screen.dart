import 'package:e_shopping/screens/admin/transaction_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import '../auth/login_screen.dart';
import 'FeedBackListScreen.dart';
import 'category_form_screen.dart'; // Import Category Form Screen
import 'product_form_screen.dart'; // Import Product Form Screen (Create your product screen)

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
                // Perform Firebase logout
                await FirebaseAuth.instance.signOut();
                // Navigate to the login screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate directly to LoginScreen
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
            // Button to manage products
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductFormScreen()), // Navigate to product management
                );
              },
              child: Text('Manage Products'),
            ),

            // Button to manage categories
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryFormScreen()), // Navigate to category management
                );
              },
              child: Text('Manage Categories'),
            ),

            // Button to generate transaction reports
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionReportScreen()), // Navigate to report generation
                );
              },
              child: Text('Generate Transaction Reports'),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbackListScreen()),
                  );
                },
                child: Text('View Feedback'),
                ),
          ],
        ),
      ),
    );
  }
}
