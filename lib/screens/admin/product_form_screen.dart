import 'package:flutter/material.dart';
import 'add_product_screen.dart';  // Corrected import
import 'edit_product_screen.dart'; // Corrected import
import 'delete_product_screen.dart'; // Corrected import

class ProductFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductAddScreen()), // Navigating to Add Product screen
                );
              },
              child: Text('Add Product'),
            ),
            SizedBox(height: 10), // Added spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProductScreen()), // Navigating to Edit Product screen
                );
              },
              child: Text('Edit Product'),
            ),
            SizedBox(height: 10), // Added spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteProductScreen()), // Navigating to Delete Product screen
                );
              },
              child: Text('Delete Product'),
            ),
          ],
        ),
      ),
    );
  }
}
