import 'package:flutter/material.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';
import 'delete_category_screen.dart';

class CategoryFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCategoryScreen()),
                );
              },
              child: Text('Add Category'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCategoryScreen()),
                );
              },
              child: Text('Edit Category'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteCategoryScreen()),
                );
              },
              child: Text('Delete Category'),
            ),
          ],
        ),
      ),
    );
  }
}
//done
