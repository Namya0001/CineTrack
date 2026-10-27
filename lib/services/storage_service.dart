import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class StorageService {
  static const String _watchlistKey = 'cinetrack_watchlist';
  static const String _themeKey = 'cinetrack_dark_mode';
  static const String _apiKeyPref = 'cinetrack_api_key';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) throw StateError('StorageService not initialized. Call init() first.');
    return _prefs!;
  }

  // --- Watchlist ---

  static Future<List<Movie>> loadWatchlist() async {
    try {
      final jsonString = _instance.getString(_watchlistKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map((j) => Movie.fromStorageJson(j))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveWatchlist(List<Movie> movies) async {
    try {
      final jsonList = movies.map((m) => m.toJson()).toList();
      final jsonString = json.encode(jsonList);
      return await _instance.setString(_watchlistKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addToWatchlist(Movie movie) async {
    final watchlist = await loadWatchlist();
    if (watchlist.any((m) => m.id == movie.id)) return false; // duplicate
    watchlist.add(movie.copyWith(isInWatchlist: true));
    return saveWatchlist(watchlist);
  }

  static Future<bool> removeFromWatchlist(int movieId) async {
    final watchlist = await loadWatchlist();
    watchlist.removeWhere((m) => m.id == movieId);
    return saveWatchlist(watchlist);
  }

  static Future<bool> updateMovieInWatchlist(Movie movie) async {
    final watchlist = await loadWatchlist();
    final index = watchlist.indexWhere((m) => m.id == movie.id);
    if (index == -1) return false;
    watchlist[index] = movie;
    return saveWatchlist(watchlist);
  }

  static Future<bool> clearWatchlist() async {
    return await _instance.remove(_watchlistKey);
  }

  // --- Theme ---

  static bool isDarkMode() {
    return _instance.getBool(_themeKey) ?? true;
  }

  static Future<bool> setDarkMode(bool value) async {
    return await _instance.setBool(_themeKey, value);
  }

  // --- API Key ---

  static String? loadApiKey() {
    return _instance.getString(_apiKeyPref);
  }

  static Future<bool> saveApiKey(String key) async {
    return await _instance.setString(_apiKeyPref, key);
  }
}

