import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../providers/photo_provider.dart';
import 'photo_card.dart';
import 'draggable_photo_card.dart';

class PhotoGrid extends StatelessWidget {
  final Function(Photo photo, String heroTag) onOpenFullscreen;
  
  const PhotoGrid({
    super.key,
    required this.onOpenFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        return photoProvider.isSelectionMode 
            ? _buildSelectionGrid(context, photoProvider)
            : _buildDraggableGrid(context, photoProvider);
      },
    );
  }
  
  Widget _buildSelectionGrid(BuildContext context, PhotoProvider photoProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photoProvider.photos.length,
      itemBuilder: (context, index) {
        final photo = photoProvider.photos[index];
        final heroTag = 'photo_${photo.id}';
        final isSelected = photoProvider.isPhotoSelected(photo.id);
        
        return PhotoCard(
          photo: photo,
          heroTag: heroTag,
          isSelected: isSelected,
          isSelectionMode: true,
          onTap: () => photoProvider.togglePhotoSelection(photo.id),
        );
      },
    );
  }
  
  Widget _buildDraggableGrid(BuildContext context, PhotoProvider photoProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photoProvider.photos.length,
      itemBuilder: (context, index) {
        final photo = photoProvider.photos[index];
        final heroTag = 'photo_${photo.id}';
        
        return DraggablePhotoCard(
          photo: photo,
          heroTag: heroTag,
          index: index,
          onTap: () => onOpenFullscreen(photo, heroTag),
          onReorder: (draggedIndex, targetIndex) {
            photoProvider.reorderPhotos(draggedIndex, targetIndex);
          },
        );
      },
    );
  }
}
