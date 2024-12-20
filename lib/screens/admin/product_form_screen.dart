import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'delete_product_screen.dart';

class ProductFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProductButton(
              context,
              label: 'Add Product',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductAddScreen()), // Navigating to Add Product screen
                );
              },
            ),
            _buildProductButton(
              context,
              label: 'Edit Product',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProductScreen()),
                );
              },
            ),
            _buildProductButton(
              context,
              label: 'Delete Product',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteProductScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
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
