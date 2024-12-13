import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to log out the user
  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Welcome message
            Text(
              'Welcome, ${user?.displayName ?? 'User'}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Categories list
            Expanded(
              child: ListView(
                children: [
                  CategoryCard(
                    categoryName: 'Electronics',
                    onTap: () {
                      // Navigate to the products of this category
                      Navigator.pushNamed(context, '/electronics');
                    },
                  ),
                  CategoryCard(
                    categoryName: 'Clothing',
                    onTap: () {
                      // Navigate to the products of this category
                      Navigator.pushNamed(context, '/clothing');
                    },
                  ),
                  CategoryCard(
                    categoryName: 'Groceries',
                    onTap: () {
                      // Navigate to the products of this category
                      Navigator.pushNamed(context, '/groceries');
                    },
                  ),
                  // Add more categories as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category Card widget
class CategoryCard extends StatelessWidget {
  final String categoryName;
  final VoidCallback onTap;

  CategoryCard({required this.categoryName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(categoryName),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
