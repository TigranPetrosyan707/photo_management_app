import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/photo.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'photo_management.db';
  static const int _databaseVersion = 1;
  static const String _photosTable = 'photos';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_photosTable (
        id TEXT PRIMARY KEY,
        filePath TEXT NOT NULL,
        fileName TEXT NOT NULL,
        dateCreated INTEGER NOT NULL,
        orderIndex INTEGER NOT NULL
      )
    ''');
  }

  Future<bool> insertPhoto(Photo photo) async {
    try {
      final db = await database;
      await db.insert(
        _photosTable,
        {
          'id': photo.id,
          'filePath': photo.filePath,
          'fileName': photo.fileName,
          'dateCreated': photo.dateCreated.millisecondsSinceEpoch,
          'orderIndex': photo.order,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error inserting photo: $e');
      return false;
    }
  }

  Future<bool> insertPhotos(List<Photo> photos) async {
    try {
      final db = await database;
      final batch = db.batch();
      
      for (final photo in photos) {
        batch.insert(
          _photosTable,
          {
            'id': photo.id,
            'filePath': photo.filePath,
            'fileName': photo.fileName,
            'dateCreated': photo.dateCreated.millisecondsSinceEpoch,
            'orderIndex': photo.order,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error inserting photos: $e');
      return false;
    }
  }

  Future<List<Photo>> getAllPhotos() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _photosTable,
        orderBy: 'orderIndex ASC',
      );

      List<Photo> validPhotos = [];
      for (final map in maps) {
        final filePath = map['filePath'] as String;
        if (await File(filePath).exists()) {
          validPhotos.add(Photo(
            id: map['id'],
            filePath: filePath,
            fileName: map['fileName'],
            dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated']),
            order: map['orderIndex'],
          ));
        } else {
          await deletePhoto(map['id']);
        }
      }

      return validPhotos;
    } catch (e) {
      print('Error getting photos: $e');
      return [];
    }
  }

  Future<bool> updatePhotosOrder(List<Photo> photos) async {
    try {
      final db = await database;
      final batch = db.batch();
      
      for (int i = 0; i < photos.length; i++) {
        batch.update(
          _photosTable,
          {'orderIndex': i},
          where: 'id = ?',
          whereArgs: [photos[i].id],
        );
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error updating photos order: $e');
      return false;
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    try {
      final db = await database;
      await db.delete(
        _photosTable,
        where: 'id = ?',
        whereArgs: [photoId],
      );
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  Future<bool> deletePhotos(List<String> photoIds) async {
    try {
      final db = await database;
      final batch = db.batch();
      
      for (final photoId in photoIds) {
        batch.delete(
          _photosTable,
          where: 'id = ?',
          whereArgs: [photoId],
        );
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting photos: $e');
      return false;
    }
  }

  Future<Photo?> getPhotoById(String photoId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _photosTable,
        where: 'id = ?',
        whereArgs: [photoId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final map = maps.first;
        return Photo(
          id: map['id'],
          filePath: map['filePath'],
          fileName: map['fileName'],
          dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated']),
          order: map['orderIndex'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting photo by ID: $e');
      return null;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
