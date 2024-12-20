import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/FeedBackFormScreen.dart';

class CartScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> removeFromCart(String productId) async {
    await _firestore.collection('cart').doc(productId).delete();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
    } else {
      await _firestore.collection('cart').doc(productId).update({'quantity': quantity});
    }
  }

  Future<void> submitTransaction(BuildContext context, List<QueryDocumentSnapshot> cartItems, double totalPrice) async {
    try {
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      List<Map<String, dynamic>> transactionProducts = cartItems.map((item) {
        return {
          'productId': item['productId'] ?? '',
          'name': item['name'] ?? 'No Name',
          'quantity': item['quantity'] ?? 1,
          'price': item['price'] ?? 0.0,
          'total': item['price'] * item['quantity'],
        };
      }).toList();

      await _firestore.collection('transactions').doc(orderId).set({
        'orderId': orderId,
        'products': transactionProducts,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      for (var item in cartItems) {
        await _firestore.collection('cart').doc(item.id).delete();
      }

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
    print('Error submitting transaction: $e');
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to submit order. Please try again later.')),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
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

          double totalPrice = cartItems.fold(0.0, (sum, item) {
            int quantity = item['quantity'] is int ? item['quantity'] : 1;
            return sum + (item['price'] * quantity);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    final imageUrl = cartItem['imageUrl'];
                    final quantity = cartItem['quantity'] ?? 1;

                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.image, size: 50, color: Colors.grey), // Placeholder icon
                        title: Text(
                          cartItem['name'] ?? 'No Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Price: \$${cartItem['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => updateQuantity(
                                cartItem.id,
                                quantity - 1,
                              ),
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => updateQuantity(
                                cartItem.id,
                                quantity + 1,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => removeFromCart(cartItem.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Total: \$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: cartItems.isEmpty
                      ? null
                      : () => submitTransaction(context, cartItems, totalPrice),
                  child: Text('Submit Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
