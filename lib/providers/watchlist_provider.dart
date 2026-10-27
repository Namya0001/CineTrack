import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/storage_service.dart';
import '../services/movie_api_service.dart';

enum WatchlistFilter { all, toWatch, watched }

enum WatchlistSort { title, releaseDate, rating }

class WatchlistProvider extends ChangeNotifier {
  List<Movie> _watchlist = [];
  WatchlistFilter _filter = WatchlistFilter.all;
  WatchlistSort _sort = WatchlistSort.title;
  bool _isDarkMode = true;
  bool _isLoading = false;

  List<Movie> get watchlist => _filteredAndSorted();
  List<Movie> get allMovies => _watchlist;
  WatchlistFilter get filter => _filter;
  WatchlistSort get sort => _sort;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  int get totalCount => _watchlist.length;
  int get watchedCount => _watchlist.where((m) => m.isWatched).length;
  int get toWatchCount => _watchlist.where((m) => !m.isWatched).length;

  double get averageUserRating {
    final rated = _watchlist.where((m) => m.userRating != null).toList();
    if (rated.isEmpty) return 0.0;
    return rated.map((m) => m.userRating!).reduce((a, b) => a + b) / rated.length;
  }

  bool isInWatchlist(int movieId) => _watchlist.any((m) => m.id == movieId);
  bool isWatched(int movieId) => _watchlist.any((m) => m.id == movieId && m.isWatched);
  double? getUserRating(int movieId) {
    try {
      return _watchlist.firstWhere((m) => m.id == movieId).userRating;
    } catch (_) {
      return null;
    }
  }

  List<Movie> _filteredAndSorted() {
    List<Movie> result;
    switch (_filter) {
      case WatchlistFilter.toWatch:
        result = _watchlist.where((m) => !m.isWatched).toList();
        break;
      case WatchlistFilter.watched:
        result = _watchlist.where((m) => m.isWatched).toList();
        break;
      case WatchlistFilter.all:
        result = List.from(_watchlist);
    }

    switch (_sort) {
      case WatchlistSort.title:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case WatchlistSort.releaseDate:
        result.sort((a, b) {
          final aDate = a.releaseDate ?? '';
          final bDate = b.releaseDate ?? '';
          return bDate.compareTo(aDate);
        });
        break;
      case WatchlistSort.rating:
        result.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        break;
    }
    return result;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _watchlist = await StorageService.loadWatchlist();
    _isDarkMode = StorageService.isDarkMode();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToWatchlist(Movie movie) async {
    if (isInWatchlist(movie.id)) return false;
    final m = movie.copyWith(isInWatchlist: true);
    _watchlist.add(m);
    notifyListeners();
    await StorageService.saveWatchlist(_watchlist);
    return true;
  }

  Future<void> removeFromWatchlist(int movieId) async {
    _watchlist.removeWhere((m) => m.id == movieId);
    notifyListeners();
    await StorageService.saveWatchlist(_watchlist);
  }

  Future<void> toggleWatched(int movieId) async {
    final index = _watchlist.indexWhere((m) => m.id == movieId);
    if (index == -1) return;
    final movie = _watchlist[index];
    _watchlist[index] = movie.copyWith(isWatched: !movie.isWatched);
    notifyListeners();
    await StorageService.saveWatchlist(_watchlist);
  }

  Future<void> setUserRating(int movieId, double rating) async {
    final index = _watchlist.indexWhere((m) => m.id == movieId);
    if (index == -1) return;
    _watchlist[index] = _watchlist[index].copyWith(userRating: rating);
    notifyListeners();
    await StorageService.saveWatchlist(_watchlist);
  }

  Future<void> fetchAndUpdateDetails(int movieId) async {
    try {
      final details = await MovieApiService.getMovieDetails(movieId);
      final index = _watchlist.indexWhere((m) => m.id == movieId);
      if (index != -1) {
        final existing = _watchlist[index];
        _watchlist[index] = existing.copyWith(
          genres: details.genres,
          runtime: details.runtime,
          productionCompanies: details.productionCompanies,
          overview: details.overview,
        );
        notifyListeners();
        await StorageService.saveWatchlist(_watchlist);
      }
    } catch (_) {
      // Silently fail — the cached version will be shown
    }
  }

  void setFilter(WatchlistFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(WatchlistSort sort) {
    _sort = sort;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _watchlist.clear();
    notifyListeners();
    await StorageService.clearWatchlist();
  }
}
