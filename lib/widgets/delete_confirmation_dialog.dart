import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
  
  static void showSingle(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Photo',
        content: 'Are you sure you want to delete this photo? This action cannot be undone.',
        onConfirm: onConfirm,
      ),
    );
  }
  
  static void showMultiple(
    BuildContext context, {
    required int count,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Photos',
        content: 'Are you sure you want to delete $count photo${count == 1 ? '' : 's'}? This action cannot be undone.',
        onConfirm: onConfirm,
      ),
    );
  }
}
