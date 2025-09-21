import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo.dart';
import '../services/camera_service.dart';

class PhotoProvider extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final List<Photo> _photos = [];
  bool _isLoading = false;

  List<Photo> get photos => List.unmodifiable(_photos);
  bool get isLoading => _isLoading;
  int get photoCount => _photos.length;

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

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint('Error taking photo: $e');
      return false;
    }
  }


  void reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final Photo photo = _photos.removeAt(oldIndex);
    _photos.insert(newIndex, photo);
    
    _updatePhotoOrder();
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

  void clearPhotos() {
    _photos.clear();
    notifyListeners();
  }
}
