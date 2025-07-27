import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setUpPushNotification() async {
    final firebaseMessagingObject = FirebaseMessaging.instance;

    // Request Permission for showing Push Notifications.
    await firebaseMessagingObject.requestPermission();

    // Address of the device where the app is running.
    final token = await firebaseMessagingObject.getToken();
    //print('Token is: $token');

    firebaseMessagingObject.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Existing Chat Messages
          Expanded(child: ChatMessages()),

          // New Message Field and Send Btn,
          NewMessage(),
        ],
      ),
    );
  }
}
