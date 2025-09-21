import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/photo_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/fullscreen_photo_view.dart';
import '../models/photo.dart';
import '../widgets/empty_photos_widget.dart';
import '../widgets/photo_grid.dart';
import '../widgets/add_photo_bottom_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(photoProvider.isSelectionMode 
                ? '${photoProvider.selectedCount} selected'
                : 'PhotoGraphy'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            elevation: 0,
            leading: photoProvider.isSelectionMode 
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => photoProvider.toggleSelectionMode(),
                  )
                : null,
            actions: photoProvider.isSelectionMode
                ? [
                    if (photoProvider.selectedCount > 0)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteSelectedPhotos(photoProvider.selectedPhotoIds.toList()),
                        tooltip: 'Delete Selected',
                      ),
                  ]
                : [
                    if (photoProvider.photos.isNotEmpty)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'select_all') {
                            photoProvider.toggleSelectionMode();
                            photoProvider.selectAllPhotos();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'select_all',
                            child: Row(
                              children: [
                                Icon(Icons.checklist),
                                SizedBox(width: 12),
                                Text('Select Photos'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return IconButton(
                          icon: Icon(themeProvider.isDarkMode 
                              ? Icons.light_mode 
                              : Icons.dark_mode),
                          onPressed: themeProvider.toggleTheme,
                          tooltip: themeProvider.isDarkMode 
                              ? 'Switch to Light Mode' 
                              : 'Switch to Dark Mode',
                        );
                      },
                    ),
                  ],
          ),
          body: Stack(
            children: [
              !photoProvider.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : photoProvider.photos.isEmpty
                  ? const EmptyPhotosWidget()
                  : PhotoGrid(onOpenFullscreen: _openFullscreen),
                  
              if (photoProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: photoProvider.isLoading ? null : _showAddPhotoOptions,
            tooltip: 'Add Photo',
            child: const Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }

  void _showAddPhotoOptions() {
    AddPhotoBottomSheet.show(
      context,
      onTakePhoto: _takePhoto,
      onChooseFromGallery: _pickFromGallery,
    );
  }

  void _takePhoto() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    
    try {
      final success = await photoProvider.takePhoto();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Photo captured successfully' : 'Failed to capture photo'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pickFromGallery() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    
    try {
      final count = await photoProvider.pickFromGallery();
      if (mounted && count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count photo${count == 1 ? '' : 's'} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openFullscreen(Photo photo, String heroTag) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenPhotoView(photo: photo, heroTag: heroTag);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _deleteSelectedPhotos(List<String> photoIds) async {
    try {
      if (photoIds.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No photos selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      DeleteConfirmationDialog.showMultiple(
        context,
        count: photoIds.length,
        onConfirm: () async {
          final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
          final deletedCount = await photoProvider.deletePhotos(photoIds);
          
          photoProvider.toggleSelectionMode();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$deletedCount photo${deletedCount == 1 ? '' : 's'} deleted'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
