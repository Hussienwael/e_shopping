import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/FeedBackFormScreen.dart';

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

  // Submit the transaction records into Firestore
  Future<void> submitTransaction(BuildContext context, List<QueryDocumentSnapshot> cartItems, double totalPrice) async {
    try {
      // Step 1: Generate a unique order ID
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      // Step 2: Prepare transaction data
      List<Map<String, dynamic>> transactionProducts = cartItems.map((item) {
        return {
          'productId': item['productId'] ?? '',
          'name': item['name'] ?? 'No Name',
          'quantity': item['quantity'] ?? 1,
          'price': item['price'] ?? 0.0,
          'total': item['price'] * item['quantity'],
        };
      }).toList();

      // Step 3: Add the transaction to the transactions table
      await _firestore.collection('transactions').doc(orderId).set({
        'orderId': orderId,
        'products': transactionProducts,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp to Firestore document
      });

      // Step 4: Clear the cart collection
      for (var item in cartItems) {
        await _firestore.collection('cart').doc(item.id).delete();
      }

      // Step 5: Navigate to Feedback Form screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted successfully! Total: \$${totalPrice.toStringAsFixed(2)}')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackFormScreen(orderId: orderId),
        ),
      );
    } catch (e) {
      // Handle any errors that occur
      print('Error submitting transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cart').snapshots(), // Fetch cart items in real-time
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
                        cartItem['imageUrl'],
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
                onPressed: () => submitTransaction(context, cartItems, totalPrice),
                child: Text('Submit Order'),
              ),
            ],
          );
        },
      ),
    );
  }
}
//nn
