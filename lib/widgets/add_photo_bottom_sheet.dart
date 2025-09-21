import 'package:flutter/material.dart';

class AddPhotoBottomSheet extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromGallery;

  const AddPhotoBottomSheet({
    super.key,
    required this.onTakePhoto,
    required this.onChooseFromGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Photo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              onTakePhoto();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              onChooseFromGallery();
            },
          ),
        ],
      ),
    );
  }
  
  static void show(
    BuildContext context, {
    required VoidCallback onTakePhoto,
    required VoidCallback onChooseFromGallery,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddPhotoBottomSheet(
        onTakePhoto: onTakePhoto,
        onChooseFromGallery: onChooseFromGallery,
      ),
    );
  }
}
