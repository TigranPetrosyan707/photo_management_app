import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'providers/photo_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/fullscreen_photo_view.dart';
import 'models/photo.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PhotoManagementApp(),
    ),
  );
}

class PhotoManagementApp extends StatelessWidget {
  const PhotoManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Photo Management',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          home: const PhotoGalleryScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  void _showAddPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _takePhoto() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    
    try {
      final success = await photoProvider.takePhoto();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to capture photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      final addedCount = await photoProvider.pickFromGallery();
      if (addedCount > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$addedCount photo${addedCount > 1 ? 's' : ''} added from gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No photos selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
    return Scaffold(
      appBar: AppBar(
            title: Text(photoProvider.isSelectionMode 
                ? '${photoProvider.selectedCount} selected'
                : 'Photo Gallery'),
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
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : photoProvider.photos.isEmpty
                  ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No photos yet',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first photo',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : photoProvider.isSelectionMode
                      ? GridView.builder(
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
                        
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (photoProvider.isSelectionMode) {
                                    photoProvider.togglePhotoSelection(photo.id);
                                  } else {
                                    _openFullscreen(photo, heroTag);
                                  }
                                },
                                onLongPress: () {
                                  if (!photoProvider.isSelectionMode) {
                                    photoProvider.toggleSelectionMode();
                                    photoProvider.togglePhotoSelection(photo.id);
                                  }
                                },
                                child: Hero(
                                  tag: heroTag,
                                  child: Image.file(
                                    File(photo.filePath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              if (photoProvider.isSelectionMode)
                                IgnorePointer(
                                  child: Container(
                                    color: isSelected 
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.black.withOpacity(0.05),
                                  ),
                                ),
                              
                              if (photoProvider.isSelectionMode)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => photoProvider.togglePhotoSelection(photo.id),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.blue : Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Colors.blue : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: isSelected 
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    )
                      : GridView.builder(
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
                            
                            return DragTarget<int>(
                              onAccept: (draggedIndex) {
                                if (draggedIndex != index) {
                                  photoProvider.reorderPhotos(draggedIndex, index);
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
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _openFullscreen(photo, heroTag),
                                          child: Hero(
                                            tag: heroTag,
                                            child: Image.file(
                                              File(photo.filePath),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        if (candidateData.isNotEmpty)
                                          Container(
                                            color: Colors.blue.withOpacity(0.3),
                                            child: const Center(
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
            ),
          ],
        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
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

  void _openFullscreen(Photo photo, String heroTag) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullscreenPhotoView(
          photo: photo,
          heroTag: heroTag,
        ),
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

  void _showPhotoOptions(String photoId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Photo Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _showSingleDeleteDialog(photoId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSingleDeleteDialog(String photoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Photo'),
          content: const Text('Are you sure you want to delete this photo? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
                final success = await photoProvider.deletePhoto(photoId);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Photo deleted successfully' : 'Failed to delete photo',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedPhotos(List<String> photoIds) {
    final count = photoIds.length;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $count Photo${count > 1 ? 's' : ''}'),
          content: Text('Are you sure you want to delete $count photo${count > 1 ? 's' : ''}? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
                final deletedCount = await photoProvider.deletePhotos(photoIds);
                
                photoProvider.toggleSelectionMode();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        deletedCount > 0 
                            ? '$deletedCount photo${deletedCount > 1 ? 's' : ''} deleted successfully'
                            : 'Failed to delete photos',
                      ),
                      backgroundColor: deletedCount > 0 ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

}
