import 'package:flutter/material.dart';
import '../home/products_screen.dart';

class CategoryItem extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  CategoryItem({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          categoryName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          // Navigate to ProductsScreen and pass categoryId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsScreen(
                categoryId: categoryId, // Pass categoryId correctly
              ),
            ),
          );
        },
      ),
    );
  }
}
