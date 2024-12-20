import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  String? _selectedCategory;
  String? _selectedProduct;
  List<String> _categories = [];
  List<String> _products = [];

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imageUrlController = TextEditingController();

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

  Future<void> _fetchProducts(String categoryName) async {
    try {
      var categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: categoryName)
          .get();

      if (categorySnapshot.docs.isNotEmpty) {
        var categoryId = categorySnapshot.docs.first.id;
        var productSnapshot = await _firestore
            .collection('categories')
            .doc(categoryId)
            .collection('products')
            .get();

        setState(() {
          _products = productSnapshot.docs.map((doc) => doc['name'] as String).toList();
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // Fetch product details for editing
  Future<void> _fetchProductDetails(String categoryName, String productName) async {
    try {
      var categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: categoryName)
          .get();

      if (categorySnapshot.docs.isEmpty) return;

      var categoryId = categorySnapshot.docs.first.id;
      var productSnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        var productData = productSnapshot.docs.first.data();
        setState(() {
          _nameController.text = productData['name'];
          _priceController.text = productData['price'].toString();
          _quantityController.text = productData['quantityInStock'].toString();
          _imageUrlController.text = productData['imageUrl'];
        });
      }
    } catch (e) {
      print("Error fetching product details: $e");
    }
  }

  // Update product details
  Future<void> _updateProduct() async {
    try {
      if (_selectedCategory == null || _selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a category and a product')));
        return;
      }

      var categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: _selectedCategory)
          .get();

      if (categorySnapshot.docs.isEmpty) return;

      var categoryId = categorySnapshot.docs.first.id;
      var productSnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products')
          .where('name', isEqualTo: _selectedProduct)
          .get();

      if (productSnapshot.docs.isEmpty) return;

      var productId = productSnapshot.docs.first.id;

      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products')
          .doc(productId)
          .update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'quantityInStock': int.parse(_quantityController.text),
        'imageUrl': _imageUrlController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product updated successfully')));
    } catch (e) {
      print("Error updating product: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text('Select Category'),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedProduct = null;
                  _products.clear();
                  _nameController.clear();
                  _priceController.clear();
                  _quantityController.clear();
                  _imageUrlController.clear();
                });
                if (value != null) {
                  _fetchProducts(value);
                }
              },
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedProduct,
              hint: Text('Select Product'),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
                if (value != null && _selectedCategory != null) {
                  _fetchProductDetails(_selectedCategory!, value);
                }
              },
              items: _products.map((product) {
                return DropdownMenuItem<String>(
                  value: product,
                  child: Text(product),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity in Stock',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Update Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
