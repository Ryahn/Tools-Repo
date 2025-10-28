import 'package:dio/dio.dart';
import 'package:rule7_app/core/api/dio_client.dart';
import 'package:rule7_app/features/games/models/game.dart';

class GameRepository {
  final Dio _dio;

  GameRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  /// Fetch a paginated list of games
  Future<GamesPaginatedResponse> getGames({
    String? cursor,
    int limit = 20,
    String? search,
    String? status,
    String? sort = '-id',
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'sort': sort};

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get('/games', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return GamesPaginatedResponse.fromJson(response.data);
      }

      throw Exception('Failed to load games');
    } catch (e) {
      throw Exception('Failed to load games: $e');
    }
  }

  /// Fetch a single game by ID
  Future<Game> getGame(int id) async {
    try {
      final response = await _dio.get('/games/$id');

      if (response.statusCode == 200) {
        return Game.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to load game');
    } catch (e) {
      throw Exception('Failed to load game: $e');
    }
  }

  /// Create a new game
  Future<Game> createGame(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/games', data: data);

      if (response.statusCode == 201) {
        return Game.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to create game');
    } catch (e) {
      throw Exception('Failed to create game: $e');
    }
  }

  /// Update an existing game
  Future<Game> updateGame(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/games/$id', data: data);

      if (response.statusCode == 200) {
        return Game.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to update game');
    } catch (e) {
      throw Exception('Failed to update game: $e');
    }
  }

  /// Delete a game
  Future<void> deleteGame(int id) async {
    try {
      final response = await _dio.delete('/games/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete game');
      }
    } catch (e) {
      throw Exception('Failed to delete game: $e');
    }
  }
}
