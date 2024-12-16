import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final String searchQuery; // Accepts search query from HomeScreen

  CategoriesScreen({this.searchQuery = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No categories available'));
          }

          // Filter categories based on the search query
          var categories = snapshot.data!.docs.where((doc) {
            if (searchQuery.isEmpty) return true; // Show all if no query
            return doc['name']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
          }).toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              var category = categories[index];

              return ListTile(
                title: Text(category['name']), // Display category name
                onTap: () {
                  // Navigate to the Products Screen when a category is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsScreen(
                        categoryId: category.id, // Pass the categoryId to ProductsScreen
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
//done
