import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Since firebase Storage needs Credit card details(Though has Free Tier)
// We are using Cloudinary for uploading our user images.

final _firebase = FirebaseAuth.instance;
final cloudinary = CloudinaryPublic('dtbdiamid', 'Flutter');

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Class vars.
  final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredUserName = '';
  String _enteredPassword = '';
  File? _selectedImage;
  bool _isUploadingNAuthenticating = false;
  bool _isLogin = true;

  // Class Methods.

  // Method to be passed to child widget.
  void _onSelectImage(File pickedImage) {
    _selectedImage = pickedImage;
  }

  void _submit() async {
    setState(() {
      _isUploadingNAuthenticating = true;
    });

    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }
    // If not retuned save the form details.
    _formKey.currentState!.save();

    // Both might throw error,
    // so wrapping with a single try-catch block.
    try {
      // When User Has Account Already.
      // Login the user. (if Case)
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        // When "Sign Up". (Else case)
        // Create the user account.
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Upload Image only during New Sign Ups.
        if (_selectedImage != null) {
          try {
            final response = await cloudinary.uploadFile(
              CloudinaryFile.fromFile(
                _selectedImage!.path,
                resourceType: CloudinaryResourceType.Image,
                folder: 'user_images', // optional
              ),
            );

            final imageUrl = response.secureUrl;
            print('Uploaded image URL: $imageUrl');
            
            // ******* FireStore Database Saving ***********
            // Save the Email, Password, Username, Image URL to Firestore Database.
            await FirebaseFirestore.instance.collection('users').
            doc(userCredentials.user!.uid).set({
              'username': _enteredUserName,
              'email': _enteredEmail,
              'image_url': imageUrl,
            });
          } on CloudinaryException catch (e) {
            print('Cloudinary upload error: ${e.message}');
            // handle error (show message, rollback, etc.)
          }
        }
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Authentication failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo Container
              Container(
                margin: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),

              // Btn Group card.
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Conditional Image Picker Widget.
                          // Will be displayed (_isLogin = false)
                          // That is when it is Sign Up.
                          if (!_isLogin) 
                            UserImagePicker(onImagePick: _onSelectImage),

                          // User Name Field. (Only During Sign-Up)
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'username'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.isEmpty || value.trim().length < 4) {
                                  return 'Please enter at least 4 characters.';
                                }
                                // If username is valid, NULL is returned.
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUserName = value!;
                              },
                            ),

                          // Email field
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'email'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              // If email is valid, NULL is returned.
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),

                          // Password Field.
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password should be greater than 6 chars.';
                              }
                              // If password is valid, NULL is returned.
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),

                          // Vertical Spacing.
                          const SizedBox(height: 12),

                          // Circular Progress Btn.
                          // when the form is not being submitted.
                          if (_isUploadingNAuthenticating) CircularProgressIndicator(),

                          // Signup Btn.
                          if (!_isUploadingNAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Login' : 'Signup'),
                            ),

                          // Login Btn.
                          if (!_isUploadingNAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = _isLogin ? false : true;
                                });
                              },
                              child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
