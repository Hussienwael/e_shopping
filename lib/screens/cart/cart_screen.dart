import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Remove product from Firestore cart
  Future<void> removeFromCart(String productId) async {
    await _firestore.collection('cart').doc(productId).delete();
  }

  // Update product quantity in Firestore
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
    } else {
      await _firestore.collection('cart').doc(productId).update({'quantity': quantity});
    }
  }

  // Function to decrement quantity in the products collection
  Future<void> decrementProductQuantity(String productId, int quantity) async {
    try {
      var productSnapshot = await _firestore.collection('products').doc(productId).get();
      if (productSnapshot.exists) {
        var productData = productSnapshot.data()!;
        int stockQuantity = productData['quantityInStock'];
        if (stockQuantity >= quantity) {
          await _firestore.collection('products').doc(productId).update({
            'quantityInStock': stockQuantity - quantity,
          });
        } else {
          throw 'Insufficient stock';
        }
      }
    } catch (e) {
      print("Error decrementing quantity: $e");
    }
  }

  // Function to add a transaction record
  Future<void> addTransaction(List<Map<String, dynamic>> cartItems, double totalPrice) async {
    try {
      var transaction = await _firestore.collection('transactions').add({
        'products': cartItems,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Transaction added: ${transaction.id}");
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  // Function to handle order submission
  Future<void> submitOrder(List<QueryDocumentSnapshot> cartItems, double totalPrice, BuildContext context) async {
    try {
      // Decrement the quantity for each product
      for (var cartItem in cartItems) {
        var productId = cartItem.id;
        var quantity = cartItem['quantity'];
        await decrementProductQuantity(productId, quantity);
      }

      // Add the transaction record to Firestore
      List<Map<String, dynamic>> cartProductDetails = cartItems.map((item) {
        return {
          'productId': item.id,
          'name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
        };
      }).toList();

      await addTransaction(cartProductDetails, totalPrice);

      // After submission, remove all items from the cart
      for (var cartItem in cartItems) {
        await removeFromCart(cartItem.id);
      }

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted! Total: \$${totalPrice.toStringAsFixed(2)}')),
      );
    } catch (e) {
      print("Error submitting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Your cart is empty!'));
          }

          final cartItems = snapshot.data!.docs;

          // Calculate total price
          double totalPrice = cartItems.fold(0.0, (sum, item) {
            return sum + (item['price'] * item['quantity']);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];

                    return ListTile(
                      leading: cartItem['imageUrl'] != null
                          ? Image.network(
                        cartItem['imageUrl'], // Display product image from Firestore
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : SizedBox(width: 50, height: 50), // Placeholder if image is not available
                      title: Text(cartItem['name'] ?? 'No Name'),
                      subtitle: Text('Price: \$${cartItem['price']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => updateQuantity(
                              cartItem.id,
                              cartItem['quantity'] - 1,
                            ),
                          ),
                          Text('${cartItem['quantity']}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => updateQuantity(
                              cartItem.id,
                              cartItem['quantity'] + 1,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => removeFromCart(cartItem.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total: \$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  submitOrder(cartItems, totalPrice, context); // Pass context here
                },
                child: Text('Submit Order'),
              ),
            ],
          );
        },
      ),
    );
  }
}
