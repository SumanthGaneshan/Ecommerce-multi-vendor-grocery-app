import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickeImage) imagePickFn;

  UserImagePicker(this.imagePickFn);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if(image != null){
      setState(() {
        _pickedImage = File(image.path);
      });
      widget.imagePickFn(_pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          // backgroundColor: Theme.of(context).primaryColor,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : NetworkImage("https://i.pinimg.com/736x/3e/eb/36/3eeb3639646fcb2679e1196d3e02dbc7.jpg") as ImageProvider,
        ),
        TextButton.icon(
          icon: Icon(
            Icons.camera,
            color: Colors.grey[800],
          ),
          style: TextButton.styleFrom(
              primary: Colors.black, minimumSize: Size(130, 45)),
          label: Text(
            "Upload Image",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}
