import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAddScreen extends StatefulWidget {
  @override
  _ProductAddScreenState createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategory; // To store the selected category name
  List<String> _categories = []; // To store categories

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when screen is loaded
  }

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      var categorySnapshot = await _firestore.collection('categories').get();
      setState(() {
        _categories = categorySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  // Function to add product to Firestore
  Future<void> _addProduct() async {
    try {
      // Fetch the category ID by the selected category name
      var categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: _selectedCategory)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category not found')));
        return;
      }

      var categoryId = categorySnapshot.docs.first.id; // Get category document ID

      // Add product to the Firestore subcollection under the selected category
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products')
          .add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'quantityInStock': int.parse(_quantityController.text),
        'imageUrl': _imageUrlController.text,
        'categoryId': categoryId, // Store the category ID with the product
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
      Navigator.pop(context); // Navigate back after successful product addition
    } catch (e) {
      print("Error adding product: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity in Stock'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),

            // Dropdown for selecting category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text('Select Category'),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
