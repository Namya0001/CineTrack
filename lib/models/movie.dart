class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final double voteAverage;
  final int? voteCount;
  final List<int> genreIds;
  final List<Genre> genres;
  final int? runtime;
  final String? productionCompanies;
  bool isInWatchlist;
  bool isWatched;
  double? userRating;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.voteAverage = 0.0,
    this.voteCount,
    this.genreIds = const [],
    this.genres = const [],
    this.runtime,
    this.productionCompanies,
    this.isInWatchlist = false,
    this.isWatched = false,
    this.userRating,
  });

  String get posterUrl {
    if (posterPath != null && posterPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return '';
  }

  String get backdropUrl {
    if (backdropPath != null && backdropPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w780$backdropPath';
    }
    return '';
  }

  String get releaseYear {
    if (releaseDate != null && releaseDate!.length >= 4) {
      return releaseDate!.substring(0, 4);
    }
    return 'N/A';
  }

  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown Title',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      runtime: json['runtime'] as int?,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
          ?.map((e) => e['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .take(3)
          .join(', '),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'genres': genres.map((g) => g.toJson()).toList(),
      'runtime': runtime,
      'production_companies': productionCompanies,
      'is_watched': isWatched,
      'user_rating': userRating,
    };
  }

  factory Movie.fromStorageJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown Title',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      runtime: json['runtime'] as int?,
      productionCompanies: json['production_companies'] as String?,
      isInWatchlist: true,
      isWatched: json['is_watched'] as bool? ?? false,
      userRating: (json['user_rating'] as num?)?.toDouble(),
    );
  }

  Movie copyWith({
    bool? isInWatchlist,
    bool? isWatched,
    double? userRating,
    List<Genre>? genres,
    int? runtime,
    String? productionCompanies,
    String? overview,
  }) {
    return Movie(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview ?? this.overview,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      genreIds: genreIds,
      genres: genres ?? this.genres,
      runtime: runtime ?? this.runtime,
      productionCompanies: productionCompanies ?? this.productionCompanies,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isWatched: isWatched ?? this.isWatched,
      userRating: userRating ?? this.userRating,
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

