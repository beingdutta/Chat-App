import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  
  // Class Vars.
  final void Function (File pickedImage) onImagePick;
  
  // Constructor.
  const UserImagePicker({
    super.key,
    required this.onImagePick,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {

  // Class vars
  File? _pickedImageFile;

  // Class Methods
  void pickImage() async{

    // Get the image.
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    // If camera is closed, Return.
    if (pickedImage == null){
      return;
    }

    // Update the UI, on image being selected.
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    // Call the method which has been passed from parent widget
    widget.onImagePick(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40, 
          backgroundColor: Colors.grey, 
          foregroundImage: 
          _pickedImageFile!=null? FileImage(_pickedImageFile!): null
        ),
        TextButton.icon(
          onPressed: pickImage,
          icon: const Icon(Icons.image),
          label: Text('Add Image', style: TextStyle(
            color: Theme.of(context).colorScheme.primary)
          ),
        ),
      ],
    );
  }
}
