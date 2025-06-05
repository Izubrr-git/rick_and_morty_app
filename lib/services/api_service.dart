import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  Future<CharacterResponse> getCharacters({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/character?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CharacterResponse.fromJson(data);
      } else {
        throw Exception('Failed to load characters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Character> getCharacterById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/character/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Character.fromJson(data);
      } else {
        throw Exception('Failed to load character: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}