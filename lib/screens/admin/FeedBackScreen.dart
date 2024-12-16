import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _productNameController =
  TextEditingController(); // For product name input
  double _rating = 0;

  // Function to submit feedback
  void _submitFeedback() async {
    if (_feedbackController.text.isNotEmpty &&
        _productNameController.text.isNotEmpty &&
        _rating > 0) {
      try {
        // Add feedback to Firestore
        await FirebaseFirestore.instance.collection('feedback').add({
          'productName': _productNameController.text, // Product name field
          'comment': _feedbackController.text, // User's comment
          'rating': _rating, // User's rating
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear the feedback form after submission
        _feedbackController.clear();
        _productNameController.clear();
        setState(() {
          _rating = 0; // Reset rating
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Feedback submitted successfully!")),
        );
      } catch (e) {
        print("Error submitting feedback: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting feedback")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter product name, feedback, and rating")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: 'Enter Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            Text("Rate your experience:"),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text("Submit Feedback"),
            ),
            SizedBox(height: 20),
            Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feedback')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No feedback available"));
                  }

                  final feedbackList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: feedbackList.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbackList[index];
                      final productName =
                          feedback['productName'] ?? 'Unknown Product';
                      final comment = feedback['comment'] ?? 'No Comment';
                      final rating = feedback['rating'] ?? 'No Rating';

                      return Card(
                        child: ListTile(
                          title: Text("Product: $productName"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Rating: $rating / 5"),
                              Text("Comment: $comment"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}