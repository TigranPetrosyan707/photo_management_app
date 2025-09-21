import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> takePhoto() async {
    try {
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return null;

      final savedFile = await _savePhotoToAppDirectory(image);
      return savedFile;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }

    if (status == PermissionStatus.denied) {
      final result = await Permission.camera.request();
      return result == PermissionStatus.granted;
    }

    if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<File> _savePhotoToAppDirectory(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');
      
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(image.path);
      final fileName = 'photo_$timestamp$extension';
      final filePath = '${photosDir.path}/$fileName';

      final imageFile = File(image.path);
      final savedFile = await imageFile.copy(filePath);

      return savedFile;
    } catch (e) {
      throw Exception('Failed to save photo: $e');
    }
  }

  Future<String> getPhotosDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/photos';
  }

  Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }
}
