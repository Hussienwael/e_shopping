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
  String? _selectedCategory;
  List<String> _categories = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

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

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _imageUrlController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    try {
      var categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: _selectedCategory)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category not found')));
        return;
      }

      var categoryId = categorySnapshot.docs.first.id;

      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products')
          .add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'quantityInStock': int.parse(_quantityController.text),
        'imageUrl': _imageUrlController.text,
        'categoryId': categoryId,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
      Navigator.pop(context);
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity in Stock'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              SizedBox(height: 20),

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
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Add Product Button
              ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
