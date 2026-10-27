import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/movie.dart';
import '../providers/watchlist_provider.dart';
import '../services/movie_api_service.dart';
import '../theme/app_theme.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Movie? _detailedMovie;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final details = await MovieApiService.getMovieDetails(widget.movie.id);
      if (mounted) {
        setState(() {
          _detailedMovie = details;
          _isLoadingDetails = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  Movie get _movie => _detailedMovie ?? widget.movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(context),
                  const SizedBox(height: 12),
                  _buildMetaRow(),
                  const SizedBox(height: 16),
                  _buildGenreChips(),
                  const SizedBox(height: 20),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  _buildUserRatingSection(context),
                  const SizedBox(height: 24),
                  _buildSynopsis(),
                  const SizedBox(height: 24),
                  _buildProductionInfo(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final imageUrl = _movie.backdropUrl.isNotEmpty ? _movie.backdropUrl : _movie.posterUrl;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppTheme.cardColor),
                  )
                : Container(color: AppTheme.cardColor),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.darkBackground],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _movie.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Poster thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 70,
            height: 100,
            child: _movie.posterUrl.isNotEmpty
                ? Image.network(_movie.posterUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppTheme.cardColor))
                : Container(color: AppTheme.cardColor),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _MetaBadge(
          icon: Icons.star_rounded,
          label: _movie.ratingFormatted,
          color: AppTheme.starColor,
        ),
        if (_movie.releaseDate != null && _movie.releaseDate!.isNotEmpty)
          _MetaBadge(
            icon: Icons.calendar_today_rounded,
            label: _movie.releaseDate!,
            color: AppTheme.textSecondary,
          ),
        if (_detailedMovie?.runtime != null && _detailedMovie!.runtime! > 0)
          _MetaBadge(
            icon: Icons.schedule_rounded,
            label: '${_detailedMovie!.runtime} min',
            color: AppTheme.textSecondary,
          ),
        if (_movie.voteCount != null)
          _MetaBadge(
            icon: Icons.people_rounded,
            label: '${_movie.voteCount} votes',
            color: AppTheme.textSecondary,
          ),
      ],
    );
  }

  Widget _buildGenreChips() {
    final genres = _isLoadingDetails
        ? []
        : (_detailedMovie?.genres.isNotEmpty == true ? _detailedMovie!.genres : _movie.genres);

    if (genres.isEmpty) {
      return _isLoadingDetails
          ? const SizedBox(
              height: 32,
              child: LinearProgressIndicator(color: AppTheme.primaryRed, backgroundColor: AppTheme.cardColor),
            )
          : const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((g) => Chip(label: Text(g.name))).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final inWatchlist = provider.isInWatchlist(_movie.id);
    final isWatched = provider.isWatched(_movie.id);

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: inWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
            icon: inWatchlist ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
            color: inWatchlist ? Colors.grey.shade700 : AppTheme.primaryRed,
            onPressed: () async {
              if (inWatchlist) {
                await provider.removeFromWatchlist(_movie.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_movie.title} removed from watchlist')),
                  );
                }
              } else {
                final added = await provider.addToWatchlist(_movie);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(added ? 'Added to watchlist!' : 'Already in watchlist'),
                    ),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: isWatched ? 'Mark Unwatched' : 'Mark Watched',
            icon: isWatched ? Icons.remove_done_rounded : Icons.done_all_rounded,
            color: isWatched ? Colors.green.shade700 : Colors.teal.shade600,
            onPressed: () async {
              if (!inWatchlist) {
                await provider.addToWatchlist(_movie);
              }
              await provider.toggleWatched(_movie.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isWatched ? 'Marked as unwatched' : 'Marked as watched! ✓'),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserRatingSection(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final currentRating = provider.getUserRating(_movie.id) ?? 0.0;
    final inWatchlist = provider.isInWatchlist(_movie.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        if (!inWatchlist)
          const Text(
            'Add to watchlist to rate this movie',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          )
        else
          Row(
            children: [
              RatingBar.builder(
                initialRating: currentRating,
                minRating: 0.5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 32,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppTheme.starColor),
                unratedColor: AppTheme.cardColor,
                onRatingUpdate: (rating) async {
                  await provider.setUserRating(_movie.id, rating);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rating saved: $rating/5 ⭐')),
                    );
                  }
                },
              ),
              const SizedBox(width: 12),
              if (currentRating > 0)
                Text(
                  '${currentRating.toStringAsFixed(1)}/5',
                  style: const TextStyle(color: AppTheme.starColor, fontWeight: FontWeight.bold),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSynopsis() {
    final overview = _movie.overview;
    if (overview == null || overview.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synopsis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          overview,
          style: const TextStyle(
            color: Color(0xFFB0B0C0),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildProductionInfo() {
    final companies = _detailedMovie?.productionCompanies;
    if (companies == null || companies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFF2E2E3E)),
        const SizedBox(height: 12),
        const Text(
          'Production',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          companies,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
