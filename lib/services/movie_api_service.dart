import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class MovieApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static String _apiKey = '';

  // Cache
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 10);

  static void setApiKey(String key) {
    _apiKey = key;
  }

  static String get apiKey => _apiKey;

  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  static Future<Map<String, dynamic>> _get(String endpoint,
      {Map<String, String>? params}) async {
    final cacheKey = '$endpoint${params?.toString() ?? ''}';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    if (_apiKey.isEmpty) {
      throw ApiException('API key is not configured. Please add your TMDB API key.');
    }

    final queryParams = {
      'api_key': _apiKey,
      ...?params,
    };

    final uri = Uri.parse('$_baseUrl$endpoint')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _cache[cacheKey] = data;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return data;
      } else if (response.statusCode == 401) {
        throw ApiException('Invalid API key. Please check your TMDB API key.', statusCode: 401);
      } else if (response.statusCode == 404) {
        throw ApiException('Content not found.', statusCode: 404);
      } else if (response.statusCode == 429) {
        throw ApiException('Too many requests. Please try again later.', statusCode: 429);
      } else {
        throw ApiException('Server error (${response.statusCode}). Please try again.', statusCode: response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException {
      throw ApiException('Network error. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  static List<Movie> _parseMovieList(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .whereType<Map<String, dynamic>>()
        .map((json) => Movie.fromJson(json))
        .toList();
  }

  static Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final data = await _get('/movie/popular', params: {'page': '$page'});
    return _parseMovieList(data);
  }

  static Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final data = await _get('/movie/top_rated', params: {'page': '$page'});
    return _parseMovieList(data);
  }

  static Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final data = await _get('/movie/upcoming', params: {'page': '$page'});
    return _parseMovieList(data);
  }

  static Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final data = await _get('/search/movie',
        params: {'query': query.trim(), 'page': '$page'});
    return _parseMovieList(data);
  }

  static Future<Movie> getMovieDetails(int movieId) async {
    final data = await _get('/movie/$movieId');
    return Movie.fromJson(data);
  }

  static Future<List<Genre>> getGenres() async {
    final data = await _get('/genre/movie/list');
    final genres = data['genres'] as List<dynamic>?;
    if (genres == null) return [];
    return genres
        .whereType<Map<String, dynamic>>()
        .map((json) => Genre.fromJson(json))
        .toList();
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

