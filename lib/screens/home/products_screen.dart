import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatefulWidget {
  final String categoryId; // Category ID passed from CategoriesScreen

  ProductsScreen({required this.categoryId});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add product to the cart and decrement QuantityInStock
  Future<void> _addToCart(Map<String, dynamic> productData, String productId) async {
    final DocumentReference productRef = _firestore
        .collection('categories')
        .doc(widget.categoryId)
        .collection('products')
        .doc(productId);

    try {
      // Run a Firestore transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        // Fetch the product document
        DocumentSnapshot productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception("Product does not exist!");
        }

        // Get current QuantityInStock
        int currentStock = productSnapshot['quantityInStock'] ?? 0;

        // Check if the product is in stock
        if (currentStock <= 0) {
          throw Exception("Product is out of stock!");
        }

        // Add product to the cart
        await _firestore.collection('cart').add({
          'productId': productId,
          'name': productData['name'],
          'price': productData['price'],
          'imageUrl': productData['imageUrl'], // Add imageUrl to the cart
          'quantity': 1, // Default quantity
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Decrement the QuantityInStock
        transaction.update(productRef, {'quantityInStock': currentStock - 1});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${productData['name']} added to cart!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
                subtitle: Text('\$${productData['price']} - Stock: ${productData['quantityInStock']}'),
                leading: productData['imageUrl'] != null
                    ? Image.network(
                  productData['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : Container(width: 50, height: 50, color: Colors.grey), // Placeholder if no image
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
