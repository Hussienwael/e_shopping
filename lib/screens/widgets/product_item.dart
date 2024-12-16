import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String imageUrl; // Add imageUrl parameter
  final VoidCallback onAddToCart; // Add to cart callback

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl, // Initialize imageUrl
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          leading: imageUrl.isNotEmpty
              ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
              : Container(width: 50, height: 50), // Placeholder if imageUrl is missing
          title: Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          trailing: IconButton(
            icon: Icon(Icons.add_shopping_cart),
            color: Theme.of(context).primaryColor,
            onPressed: onAddToCart,
          ),
        ),
      ),
    );
  }
}
//done
