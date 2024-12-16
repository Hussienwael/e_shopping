import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategoryScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addCategory(BuildContext context) async {
    try {
      await _firestore.collection('categories').add({
        'name': _nameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category added successfully')));
      Navigator.pop(context);
    } catch (e) {
      print("Error adding category: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addCategory(context),
              child: Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}
