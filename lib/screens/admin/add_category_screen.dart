import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategoryScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addCategory(BuildContext context) async {
    try {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a category name')));
        return;
      }
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
      appBar: AppBar(
        title: Text('Add Category'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => _addCategory(context),
              child: Text('Add Category'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
