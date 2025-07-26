import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// For Firebase
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 63, 17, 177))),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
          {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

// StreamBuilder is a widget that listens to a stream 
// and automatically rebuilds the UI whenever new data comes in.

// Perfect for chat apps, update UI on each arrival of each message.

