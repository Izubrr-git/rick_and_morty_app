import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/character.dart';

class DatabaseService {
  static Database? _database;
  static const String _charactersTable = 'characters';
  static const String _favoritesTable = 'favorites';

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize sqflite for desktop platforms
    _initializeDatabaseFactory();

    _database = await _initDatabase();
    return _database!;
  }

  void _initializeDatabaseFactory() {
    // Check if we're running on desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rick_morty.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Characters cache table
    await db.execute('''
      CREATE TABLE $_charactersTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        species TEXT NOT NULL,
        type TEXT NOT NULL,
        gender TEXT NOT NULL,
        origin TEXT NOT NULL,
        location TEXT NOT NULL,
        image TEXT NOT NULL,
        episode TEXT NOT NULL,
        url TEXT NOT NULL,
        created TEXT NOT NULL
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE $_favoritesTable (
        id INTEGER PRIMARY KEY
      )
    ''');
  }

  // Character caching methods
  Future<void> cacheCharacters(List<Character> characters) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (Character character in characters) {
        batch.insert(
          _charactersTable,
          {
            'id': character.id,
            'name': character.name,
            'status': character.status,
            'species': character.species,
            'type': character.type,
            'gender': character.gender,
            'origin': jsonEncode(character.origin.toJson()),
            'location': jsonEncode(character.location.toJson()),
            'image': character.image,
            'episode': jsonEncode(character.episode),
            'url': character.url,
            'created': character.created,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
    } catch (e) {
      print('Error caching characters: $e');
      rethrow;
    }
  }

  Future<List<Character>> getCachedCharacters() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_charactersTable);

      return List.generate(maps.length, (i) {
        return Character(
          id: maps[i]['id'],
          name: maps[i]['name'],
          status: maps[i]['status'],
          species: maps[i]['species'],
          type: maps[i]['type'],
          gender: maps[i]['gender'],
          origin: Origin.fromJson(jsonDecode(maps[i]['origin'])),
          location: Location.fromJson(jsonDecode(maps[i]['location'])),
          image: maps[i]['image'],
          episode: List<String>.from(jsonDecode(maps[i]['episode'])),
          url: maps[i]['url'],
          created: maps[i]['created'],
        );
      });
    } catch (e) {
      print('Error getting cached characters: $e');
      return [];
    }
  }

  // Favorites methods
  Future<void> addToFavorites(int characterId) async {
    try {
      final db = await database;
      await db.insert(
        _favoritesTable,
        {'id': characterId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  Future<void> removeFromFavorites(int characterId) async {
    try {
      final db = await database;
      await db.delete(
        _favoritesTable,
        where: 'id = ?',
        whereArgs: [characterId],
      );
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  Future<List<int>> getFavoriteIds() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_favoritesTable);
      return List.generate(maps.length, (i) => maps[i]['id']);
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }

  Future<bool> isFavorite(int characterId) async {
    try {
      final db = await database;
      final result = await db.query(
        _favoritesTable,
        where: 'id = ?',
        whereArgs: [characterId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking if favorite: $e');
      return false;
    }
  }
}