import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCategoryScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteCategory(BuildContext context) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    try {
      QuerySnapshot query = await _firestore
          .collection('categories')
          .where('name', isEqualTo: _nameController.text)
          .get();

      if (query.docs.isNotEmpty) {
        await _firestore.collection('categories').doc(query.docs.first.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category "${_nameController.text}" deleted successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category not found')),
        );
      }
    } catch (e) {
      print("Error deleting category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Category'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _deleteCategory(context),
              child: Text('Delete Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
