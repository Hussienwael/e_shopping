import 'package:flutter/material.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';
import 'delete_category_screen.dart';

class CategoryFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCategoryButton(
              context,
              label: 'Add Category',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCategoryScreen()),
                );
              },
            ),
            _buildCategoryButton(
              context,
              label: 'Edit Category',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCategoryScreen()),
                );
              },
            ),
            _buildCategoryButton(
              context,
              label: 'Delete Category',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteCategoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        title: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.blueAccent),
        onTap: onPressed,
      ),
    );
  }
}
