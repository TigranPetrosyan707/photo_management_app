import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo.dart';
import 'photo_card.dart';

class DraggablePhotoCard extends StatelessWidget {
  final Photo photo;
  final String heroTag;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Function(int draggedIndex, int targetIndex) onReorder;

  const DraggablePhotoCard({
    super.key,
    required this.photo,
    required this.heroTag,
    required this.index,
    required this.onTap,
    this.onLongPress,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onAccept: (draggedIndex) {
        if (draggedIndex != index) {
          onReorder(draggedIndex, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          delay: const Duration(milliseconds: 500),
          feedback: Material(
            elevation: 8,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image.file(
                File(photo.filePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          childWhenDragging: Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              color: Colors.grey.withOpacity(0.5),
              child: const Icon(
                Icons.drag_handle,
                color: Colors.grey,
              ),
            ),
          ),
          child: PhotoCard(
            photo: photo,
            heroTag: heroTag,
            isSelected: false,
            isSelectionMode: false,
            onTap: onTap,
            showDropIndicator: candidateData.isNotEmpty,
          ),
        );
      },
    );
  }
}
