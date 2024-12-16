import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackFormScreen extends StatefulWidget {
  final String orderId; // Order ID passed from the previous screen

  FeedbackFormScreen({required this.orderId});

  @override
  _FeedbackFormScreenState createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  int _rating = 1;

  void submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('feedback').add({
        'orderId': widget.orderId,
        'comment': _commentController.text,
        'rating': _rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feedback submitted!'),
      ));

      // You can then redirect the user back or show a success message
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(labelText: "Your Comment"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Rate your order:'),
              Slider(
                value: _rating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    _rating = value.toInt();
                  });
                },
                label: '$_rating',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitFeedback,
                child: Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}