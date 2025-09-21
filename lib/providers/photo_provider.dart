import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo.dart';
import '../services/camera_service.dart';
import '../services/database_service.dart';

class PhotoProvider extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final DatabaseService _databaseService = DatabaseService();
  final List<Photo> _photos = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotoIds = <String>{};
  bool _isInitialized = false;

  List<Photo> get photos => List.unmodifiable(_photos);
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedPhotoIds => Set.unmodifiable(_selectedPhotoIds);
  int get photoCount => _photos.length;
  int get selectedCount => _selectedPhotoIds.length;
  bool get isInitialized => _isInitialized;

  PhotoProvider() {
    _initializePhotos();
  }

  Future<void> _initializePhotos() async {
    try {
      _setLoading(true);
      final photos = await _databaseService.getAllPhotos();
      _photos.clear();
      _photos.addAll(photos);
      _isInitialized = true;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      debugPrint('Error initializing photos: $e');
    }
  }

  Future<bool> takePhoto() async {
    try {
      _setLoading(true);

      final imageFile = await _cameraService.takePhoto();
      if (imageFile == null) {
        _setLoading(false);
        return false;
      }


      final photo = Photo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: imageFile.path,
        fileName: imageFile.path.split('/').last,
        dateCreated: DateTime.now(),
        order: _photos.length,
      );

      _photos.insert(0, photo);
      
      _updatePhotoOrder();
      
      await _databaseService.insertPhoto(photo);
      await _databaseService.updatePhotosOrder(_photos);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint('Error taking photo: $e');
      return false;
    }
  }

  Future<int> pickFromGallery() async {
    try {
      _setLoading(true);

      final imageFiles = await _cameraService.pickFromGallery();
      if (imageFiles.isEmpty) {
        _setLoading(false);
        return 0;
      }

      int addedCount = 0;
      final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      for (File imageFile in imageFiles) {
        final photo = Photo(
          id: '${baseTimestamp}_${addedCount}',
          filePath: imageFile.path,
          fileName: imageFile.path.split('/').last,
          dateCreated: DateTime.now(),
          order: addedCount,
        );

        _photos.insert(addedCount, photo);
        addedCount++;
      }
      
      _updatePhotoOrder();
      
      await _databaseService.insertPhotos(_photos.take(addedCount).toList());
      await _databaseService.updatePhotosOrder(_photos);

      _setLoading(false);
      notifyListeners();
      return addedCount;
    } catch (e) {
      _setLoading(false);
      debugPrint('Error picking photos from gallery: $e');
      return 0;
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    try {
      final photoIndex = _photos.indexWhere((photo) => photo.id == photoId);
      if (photoIndex == -1) return false;

      final photo = _photos[photoIndex];
      
      final file = File(photo.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      _photos.removeAt(photoIndex);
      
      _updatePhotoOrder();
      
      await _databaseService.deletePhoto(photoId);
      await _databaseService.updatePhotosOrder(_photos);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }

  Future<int> deletePhotos(List<String> photoIds) async {
    int deletedCount = 0;
    
    final photosToDelete = <int>[];
    for (String photoId in photoIds) {
      final index = _photos.indexWhere((photo) => photo.id == photoId);
      if (index != -1) {
        photosToDelete.add(index);
      }
    }
    
    photosToDelete.sort((a, b) => b.compareTo(a));
    
    for (int index in photosToDelete) {
      try {
        final photo = _photos[index];
        
        final file = File(photo.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        
        _photos.removeAt(index);
        deletedCount++;
      } catch (e) {
        debugPrint('Error deleting photo at index $index: $e');
      }
    }
    
    if (deletedCount > 0) {
      _updatePhotoOrder();
      
      await _databaseService.deletePhotos(photoIds);
      await _databaseService.updatePhotosOrder(_photos);
      
      notifyListeners();
    }
    
    return deletedCount;
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    
    final Photo photo = _photos.removeAt(oldIndex);
    _photos.insert(newIndex, photo);
    
    _updatePhotoOrder();
    
    _databaseService.updatePhotosOrder(_photos);
    
    notifyListeners();
  }

  Photo? getPhotoById(String id) {
    try {
      return _photos.firstWhere((photo) => photo.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> photoExists(String filePath) async {
    return await _cameraService.fileExists(filePath);
  }

  void _updatePhotoOrder() {
    for (int i = 0; i < _photos.length; i++) {
      _photos[i] = _photos[i].copyWith(order: i);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedPhotoIds.clear();
    }
    notifyListeners();
  }

  void togglePhotoSelection(String photoId) {
    if (_selectedPhotoIds.contains(photoId)) {
      _selectedPhotoIds.remove(photoId);
    } else {
      _selectedPhotoIds.add(photoId);
    }
    notifyListeners();
  }

  void selectAllPhotos() {
    _selectedPhotoIds.clear();
    _selectedPhotoIds.addAll(_photos.map((photo) => photo.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedPhotoIds.clear();
    notifyListeners();
  }

  bool isPhotoSelected(String photoId) {
    return _selectedPhotoIds.contains(photoId);
  }

  void clearPhotos() {
    _photos.clear();
    _selectedPhotoIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }
  
  Future<void> refreshPhotos() async {
    await _initializePhotos();
  }
}
