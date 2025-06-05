import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

enum SortType { name, status, species }

class CharacterProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();

  List<Character> _characters = [];
  List<Character> _favoriteCharacters = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  SortType _sortType = SortType.name;

  List<Character> get characters => _characters;
  List<Character> get favoriteCharacters => _favoriteCharacters;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  SortType get sortType => _sortType;

  CharacterProvider() {
    _initializeData();
  }

  void _initializeData() async {
    try {
      await loadFavorites();
      await loadCharacters();
    } catch (e) {
      _error = 'Failed to initialize app: $e';
      notifyListeners();
    }
  }

  Future<void> loadCharacters({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _characters.clear();
      _hasMore = true;
      _error = null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getCharacters(page: _currentPage);

      // Mark favorites
      final favoriteIds = await _databaseService.getFavoriteIds();
      for (var character in response.results) {
        character.isFavorite = favoriteIds.contains(character.id);
      }

      if (refresh) {
        _characters = response.results;
      } else {
        _characters.addAll(response.results);
      }

      // Cache characters (with error handling)
      try {
        await _databaseService.cacheCharacters(response.results);
      } catch (cacheError) {
        print('Failed to cache characters: $cacheError');
        // Continue without caching if database fails
      }

      _hasMore = response.info.next != null;
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = e.toString();

      // Try to load from cache if network fails
      if (_characters.isEmpty) {
        await _loadFromCache();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedCharacters = await _databaseService.getCachedCharacters();

      if (cachedCharacters.isNotEmpty) {
        final favoriteIds = await _databaseService.getFavoriteIds();

        for (var character in cachedCharacters) {
          character.isFavorite = favoriteIds.contains(character.id);
        }

        _characters = cachedCharacters;
        _hasMore = false; // No pagination for cached data
        _error = 'Showing cached data - check your internet connection';
      } else {
        _error = 'No cached data available';
      }
    } catch (e) {
      _error = 'Failed to load cached data: $e';
      print('Cache loading error: $e');
    }
  }

  Future<void> toggleFavorite(Character character) async {
    try {
      if (character.isFavorite) {
        await _databaseService.removeFromFavorites(character.id);
        character.isFavorite = false;
        _favoriteCharacters.removeWhere((c) => c.id == character.id);
      } else {
        await _databaseService.addToFavorites(character.id);
        character.isFavorite = true;
        _favoriteCharacters.add(character.copyWith(isFavorite: true));
      }

      // Update character in main list
      final index = _characters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _characters[index] = character;
      }

      _sortFavorites();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update favorite: $e';
      print('Favorite toggle error: $e');
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    try {
      final favoriteIds = await _databaseService.getFavoriteIds();
      final cachedCharacters = await _databaseService.getCachedCharacters();

      _favoriteCharacters = cachedCharacters
          .where((character) => favoriteIds.contains(character.id))
          .map((character) => character.copyWith(isFavorite: true))
          .toList();

      _sortFavorites();
    } catch (e) {
      _error = 'Failed to load favorites: $e';
      print('Load favorites error: $e');
    }
    notifyListeners();
  }

  void setSortType(SortType sortType) {
    _sortType = sortType;
    _sortFavorites();
    notifyListeners();
  }

  void _sortFavorites() {
    switch (_sortType) {
      case SortType.name:
        _favoriteCharacters.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.status:
        _favoriteCharacters.sort((a, b) => a.status.compareTo(b.status));
        break;
      case SortType.species:
        _favoriteCharacters.sort((a, b) => a.species.compareTo(b.species));
        break;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}