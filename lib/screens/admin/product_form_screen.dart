import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedCategory; // To store the selected category ID
  List<String> _categories = []; // To hold category names

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when screen is loaded
  }

  // Function to fetch categories from Firestore
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

  // Function to add a product to Firestore
  Future<void> addProduct() async {
    try {
      // Get the category document reference by matching the selected category
      var categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: _selectedCategory)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category not found')));
        return;
      }

      var categoryId = categorySnapshot.docs.first.id; // Get category document ID

      // Add the product to the category's subcollection of products
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products') // Subcollection under category
          .add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'quantityInStock': int.parse(_quantityController.text),
        'imageUrl': _imageUrlController.text,
        'categoryId': categoryId, // Store the category ID in the product
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
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
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Product Name')),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price')),
            TextField(controller: _quantityController, decoration: InputDecoration(labelText: 'Quantity in Stock')),
            TextField(controller: _imageUrlController, decoration: InputDecoration(labelText: 'Image URL')),

            // Category Dropdown
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
              onPressed: addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
