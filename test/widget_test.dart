import 'package:flutter_test/flutter_test.dart';
import 'package:cinetrack/models/movie.dart';

// Minimal StorageService stub for testing
class _MockStorageService {
  static final List<Movie> _data = [];

  static List<Movie> loadWatchlist() => List.from(_data);

  static bool addToWatchlist(Movie movie) {
    if (_data.any((m) => m.id == movie.id)) return false;
    _data.add(movie.copyWith(isInWatchlist: true));
    return true;
  }

  static bool removeFromWatchlist(int id) {
    final before = _data.length;
    _data.removeWhere((m) => m.id == id);
    return _data.length < before;
  }

  static void clear() => _data.clear();
}

Movie _makeMovie({int id = 1, String title = 'Test Movie'}) {
  return Movie(
    id: id,
    title: title,
    voteAverage: 7.5,
    releaseDate: '2024-01-01',
  );
}

void main() {
  group('Movie model', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 42,
        'title': 'Inception',
        'poster_path': '/abc.jpg',
        'backdrop_path': '/def.jpg',
        'overview': 'A mind-bending film.',
        'release_date': '2010-07-16',
        'vote_average': 8.8,
        'vote_count': 30000,
        'genre_ids': [28, 878],
        'genres': [],
      };
      final movie = Movie.fromJson(json);
      expect(movie.id, 42);
      expect(movie.title, 'Inception');
      expect(movie.voteAverage, 8.8);
      expect(movie.releaseYear, '2010');
      expect(movie.ratingFormatted, '8.8');
      expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/abc.jpg');
      expect(movie.backdropUrl, 'https://image.tmdb.org/t/p/w780/def.jpg');
    });

    test('handles missing fields gracefully', () {
      final movie = Movie.fromJson({'id': 99});
      expect(movie.title, 'Unknown Title');
      expect(movie.voteAverage, 0.0);
      expect(movie.releaseYear, 'N/A');
      expect(movie.posterUrl, '');
    });

    test('copyWith preserves unchanged fields', () {
      final original = _makeMovie();
      final copy = original.copyWith(isWatched: true, userRating: 4.5);
      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.isWatched, true);
      expect(copy.userRating, 4.5);
    });

    test('toJson round-trips through fromStorageJson', () {
      final movie = _makeMovie()
          .copyWith(isWatched: true, userRating: 3.5, isInWatchlist: true);
      final json = movie.toJson();
      final restored = Movie.fromStorageJson(json);
      expect(restored.id, movie.id);
      expect(restored.title, movie.title);
      expect(restored.isWatched, true);
      expect(restored.userRating, 3.5);
      expect(restored.isInWatchlist, true);
    });
  });

  group('Watchlist operations (mock storage)', () {
    setUp(() => _MockStorageService.clear());

    test('add movie succeeds', () {
      final result = _MockStorageService.addToWatchlist(_makeMovie());
      expect(result, true);
      expect(_MockStorageService.loadWatchlist().length, 1);
    });

    test('duplicate add is rejected', () {
      _MockStorageService.addToWatchlist(_makeMovie());
      final result = _MockStorageService.addToWatchlist(_makeMovie());
      expect(result, false);
      expect(_MockStorageService.loadWatchlist().length, 1);
    });

    test('remove movie succeeds', () {
      _MockStorageService.addToWatchlist(_makeMovie(id: 5));
      final result = _MockStorageService.removeFromWatchlist(5);
      expect(result, true);
      expect(_MockStorageService.loadWatchlist().isEmpty, true);
    });

    test('remove non-existent movie returns false', () {
      final result = _MockStorageService.removeFromWatchlist(999);
      expect(result, false);
    });

    test('multiple movies stored independently', () {
      _MockStorageService.addToWatchlist(_makeMovie(id: 1, title: 'A'));
      _MockStorageService.addToWatchlist(_makeMovie(id: 2, title: 'B'));
      _MockStorageService.addToWatchlist(_makeMovie(id: 3, title: 'C'));
      expect(_MockStorageService.loadWatchlist().length, 3);
      _MockStorageService.removeFromWatchlist(2);
      final remaining = _MockStorageService.loadWatchlist();
      expect(remaining.length, 2);
      expect(remaining.any((m) => m.id == 2), false);
    });

    test('isInWatchlist reflected correctly', () {
      _MockStorageService.addToWatchlist(_makeMovie(id: 10));
      final list = _MockStorageService.loadWatchlist();
      final movie = list.firstWhere((m) => m.id == 10);
      expect(movie.isInWatchlist, true);
    });
  });

  group('Genre model', () {
    test('fromJson parses correctly', () {
      final genre = Genre.fromJson({'id': 28, 'name': 'Action'});
      expect(genre.id, 28);
      expect(genre.name, 'Action');
    });

    test('toJson produces correct map', () {
      final genre = Genre(id: 18, name: 'Drama');
      final json = genre.toJson();
      expect(json['id'], 18);
      expect(json['name'], 'Drama');
    });
  });
}
