import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPhoto extends StatefulWidget {
  const AddPhoto({
    super.key,
    required this.onPickImage,
  });

  final void Function(File pickedImage) onPickImage;
  @override
  State<AddPhoto> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AddPhoto> {
  File? pickedImageFile;

  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundImage:
              pickedImageFile != null ? FileImage(pickedImageFile!) : null,
        ),
        InkWell(
          onTap: pickImage,
          child: Text(
            pickedImageFile != null ? 'Change photo' : 'Add photo',
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
