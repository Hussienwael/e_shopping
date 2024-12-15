import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatefulWidget {
  final String categoryId; // Category ID passed from CategoriesScreen

  ProductsScreen({required this.categoryId}); // Add image URL to this attributes

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add product to the cart
  Future<void> _addToCart(Map<String, dynamic> productData, String productId) async {
    try {
      await _firestore.collection('cart').add({
        'productId': productId,
        'name': productData['name'],
        'price': productData['price'],
        'imageUrl': productData['imageUrl'], // Add imageUrl to the cart
        'quantity': 1, // Default quantity
        'addedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${productData['name']} added to cart!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('categories')
            .doc(widget.categoryId)
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products available'));
          }

          var products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              var productData = product.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(productData['name']),
                subtitle: Text('\$${productData['price']}'),
                leading: productData['imageUrl'] != null
                    ? Image.network(productData['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : Container(width: 50, height: 50), // Placeholder if imageUrl is missing
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _addToCart(productData, product.id),
                ),

              );
            },
          );
        },
      ),
    );
  }
}
