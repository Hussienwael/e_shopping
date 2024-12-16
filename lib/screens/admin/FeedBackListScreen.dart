import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customer Feedback")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var feedbacks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              var feedback = feedbacks[index];
              return ListTile(
                title: Text('Order ID: ${feedback['orderId']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating: ${feedback['rating']}'),
                    Text('Comment: ${feedback['comment']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

