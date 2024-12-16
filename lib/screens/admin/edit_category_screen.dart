import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCategoryScreen extends StatefulWidget {
  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCategoryId;

  Future<void> _updateCategory(BuildContext context) async {
    if (_selectedCategoryId == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a category and enter a new name')),
      );
      return;
    }

    try {
      await _firestore.collection('categories').doc(_selectedCategoryId).update({
        'name': _nameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error updating category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading categories'));
                  }

                  final categories = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      var categoryId = category.id;
                      var categoryName = category['name'];

                      return ListTile(
                        title: Text(categoryName),
                        trailing: Radio<String>(
                          value: categoryId,
                          groupValue: _selectedCategoryId,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                              _nameController.text = categoryName;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'New Category Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updateCategory(context),
              child: Text('Update Category'),
            ),
          ],
        ),
      ),
    );
  }
}
