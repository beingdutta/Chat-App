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
  void _submitMessage() {
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

    // Else send to firebase if Msg is not empty.

    _newMsgController.clear();


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
