import 'package:e_shopping/screens/admin/transaction_report_screen.dart';
import 'package:flutter/material.dart';
import 'category_form_screen.dart'; // Import Category Form Screen
import 'product_form_screen.dart'; // Import Product Form Screen (Create your product screen)


class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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

            // Button to view feedback


            // Button to generate reports
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionReportScreen()), // Navigate to report generation
                );
              },
              child: Text('Generate Transaction Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
