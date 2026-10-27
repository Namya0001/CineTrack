import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import '../providers/watchlist_provider.dart';
import 'package:provider/provider.dart';
import '../screens/movie_details_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double aspectRatio;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 140,
    this.aspectRatio = 0.67,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PosterImage(movie: movie, width: width, aspectRatio: aspectRatio),
            const SizedBox(height: 6),
            _MovieInfo(movie: movie, width: width),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => MovieDetailsScreen(movie: movie),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  final Movie movie;
  final double width;
  final double aspectRatio;

  const _PosterImage({required this.movie, required this.width, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final inWatchlist = provider.isInWatchlist(movie.id);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: movie.posterUrl.isNotEmpty
                ? Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _PlaceholderPoster(title: movie.title),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.cardColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      );
                    },
                  )
                : _PlaceholderPoster(title: movie.title),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: _WatchlistButton(movie: movie, inWatchlist: inWatchlist, provider: provider),
        ),
        if (provider.isWatched(movie.id))
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
      ],
    );
  }
}

class _WatchlistButton extends StatelessWidget {
  final Movie movie;
  final bool inWatchlist;
  final WatchlistProvider provider;

  const _WatchlistButton({required this.movie, required this.inWatchlist, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (inWatchlist) {
          await provider.removeFromWatchlist(movie.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${movie.title} removed from watchlist'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => provider.addToWatchlist(movie),
                ),
              ),
            );
          }
        } else {
          final added = await provider.addToWatchlist(movie);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(added ? '${movie.title} added to watchlist' : 'Already in watchlist'),
              ),
            );
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: inWatchlist ? AppTheme.primaryRed : Colors.black.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          inWatchlist ? Icons.bookmark : Icons.bookmark_add_outlined,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _MovieInfo extends StatelessWidget {
  final Movie movie;
  final double width;

  const _MovieInfo({required this.movie, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF0F0F0),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 13),
              const SizedBox(width: 3),
              Text(
                movie.ratingFormatted,
                style: const TextStyle(color: AppTheme.starColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  movie.releaseYear,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPoster extends StatelessWidget {
  final String title;

  const _PlaceholderPoster({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_outlined, color: AppTheme.textSecondary, size: 40),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
