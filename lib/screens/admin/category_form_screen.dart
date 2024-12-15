import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryFormScreen extends StatefulWidget {
  final String? categoryId; // Optional categoryId to edit an existing category

  CategoryFormScreen({this.categoryId}); // Constructor accepts an optional categoryId

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _isEditing = true;
      _fetchCategoryDetails();
    }
  }

  // Fetch the category details if categoryId is provided (for editing)
  Future<void> _fetchCategoryDetails() async {
    try {
      var categorySnapshot = await _firestore
          .collection('categories')
          .doc(widget.categoryId)
          .get();

      if (categorySnapshot.exists) {
        var categoryData = categorySnapshot.data() as Map<String, dynamic>;
        _nameController.text = categoryData['name'];
      }
    } catch (e) {
      print("Error fetching category details: $e");
    }
  }

  // Function to add a new category or update an existing category
  Future<void> _saveCategory() async {
    try {
      if (_isEditing) {
        // Update category if editing
        await _firestore.collection('categories').doc(widget.categoryId).update({
          'name': _nameController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category updated successfully')));
      } else {
        // Add new category if not editing
        await _firestore.collection('categories').add({
          'name': _nameController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category added successfully')));
      }
    } catch (e) {
      print("Error saving category: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save category')));
    }
  }

  // Function to delete a category
  Future<void> _deleteCategory() async {
    try {
      await _firestore.collection('categories').doc(widget.categoryId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category deleted successfully')));
      Navigator.pop(context); // Navigate back after deleting
    } catch (e) {
      print("Error deleting category: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Category' : 'Add Category')),
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
              onPressed: _saveCategory,
              child: Text(_isEditing ? 'Update Category' : 'Add Category'),
            ),
            if (_isEditing) ...[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteCategory,
                child: Text('Delete Category'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
