import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  // Class vars.
  final TextEditingController _newMsgController = TextEditingController();

  // Class Methods.
  void _submitMessage() async{
    final newMsgText = _newMsgController.text;

    if (newMsgText.trim().isEmpty) {
      // Show Snack Message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message cannot be empty'),
        ),
      );
      return;
    }

    // Close the Keyboard.
    // By removing the focus from the Text field.
    FocusScope.of(context).unfocus();
    _newMsgController.clear();

    // Else send to firebase if Msg is not empty.

    // 1. Get the user details already in firestore.
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

    //print('User data retrieved from Firestore: ${userData.data()}');

    // 2. Push the user message alongwith his details.
    FirebaseFirestore.instance.collection('chat').add({
      'text': newMsgText,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  void dispose() {
    _newMsgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          // TextInput Field of New Msg.
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
              controller: _newMsgController,
            ),
          ),

          // Send Btn
          IconButton(
            onPressed: _submitMessage, 
            icon: const Icon(Icons.send), 
            color: Theme.of(context).colorScheme.primary
          ),
        ],
      ),
    );
  }
}
