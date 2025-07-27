import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat')
      .orderBy('createdAt', descending: true)
      .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong....')
          );
        }

        // If we have reached here , that means there was no problem
        // So get the chat list.
        final loadedMessages = snapshot.data!.docs;

        // Else case: IF data has been found.
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40, 
            left: 13, 
            right: 13
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) => 
          Text(loadedMessages[index].data()['text'])      
        );
      },
    );
  }
}
