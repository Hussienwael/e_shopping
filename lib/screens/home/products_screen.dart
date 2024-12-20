import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatefulWidget {
  final String categoryId;

  ProductsScreen({required this.categoryId});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addToCart(Map<String, dynamic> productData, String productId) async {
    final DocumentReference productRef = _firestore
        .collection('categories')
        .doc(widget.categoryId)
        .collection('products')
        .doc(productId);

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception("Product does not exist!");
        }

        int currentStock = productSnapshot['quantityInStock'] ?? 0;

        if (currentStock <= 0) {
          throw Exception("Product is out of stock!");
        }

        QuerySnapshot cartSnapshot = await _firestore
            .collection('cart')
            .where('productId', isEqualTo: productId)
            .get();

        if (cartSnapshot.docs.isEmpty) {
          await _firestore.collection('cart').add({
            'productId': productId,
            'name': productData['name'],
            'price': productData['price'],
            'imageUrl': productData['imageUrl'],
            'quantity': 1,
            'addedAt': FieldValue.serverTimestamp(),
          });

          transaction.update(productRef, {'quantityInStock': currentStock - 1});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${productData['name']} added to cart!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${productData['name']} is already in the cart!')),
          );
        }
      });
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

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    productData['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '\$${productData['price']} - Stock: ${productData['quantityInStock']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: productData['imageUrl'] != null
                      ? Image.network(
                    productData['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add_shopping_cart),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _addToCart(productData, product.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
