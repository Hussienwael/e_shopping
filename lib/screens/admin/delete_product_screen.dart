import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteProductScreen extends StatefulWidget {
  @override
  _DeleteProductScreenState createState() => _DeleteProductScreenState();
}

class _DeleteProductScreenState extends State<DeleteProductScreen> {
  String? _selectedCategory;
  String? _selectedProduct;
  List<String> _categories = [];
  List<String> _products = [];

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

  Future<void> _deleteProduct() async {
    try {
      if (_selectedCategory == null || _selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a category and a product')));
        return;
      }

      // Get category ID
      var categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: _selectedCategory)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category not found')));
        return;
      }

      var categoryId = categorySnapshot.docs.first.id;

      var productSnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products')
          .where('name', isEqualTo: _selectedProduct)
          .get();

      if (productSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product not found')));
        return;
      }

      var productId = productSnapshot.docs.first.id;

      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('products')
          .doc(productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted successfully')));
      setState(() {
        _products.remove(_selectedProduct);
        _selectedProduct = null;
      });
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Product'), backgroundColor: Colors.red),
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedProduct,
              hint: Text('Select Product'),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
              items: _products.map((product) {
                return DropdownMenuItem<String>(
                  value: product,
                  child: Text(product),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _deleteProduct,
              child: Text('Delete Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
