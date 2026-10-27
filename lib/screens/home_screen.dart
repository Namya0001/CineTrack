import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/movie_api_service.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/empty_state.dart';
import '../theme/app_theme.dart';
import '../screens/movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _popular = [];
  List<Movie> _topRated = [];
  List<Movie> _upcoming = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        MovieApiService.getPopularMovies(),
        MovieApiService.getTopRatedMovies(),
        MovieApiService.getUpcomingMovies(),
      ]);
      if (mounted) {
        setState(() {
          _popular = results[0];
          _topRated = results[1];
          _upcoming = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const LoadingIndicator(message: 'Loading movies...')
            : _error != null
                ? ErrorState(message: _error!, onRetry: _loadMovies)
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: AppTheme.primaryRed,
      backgroundColor: AppTheme.cardColor,
      onRefresh: () async {
        MovieApiService.clearCache();
        await _loadMovies();
      },
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_popular.isNotEmpty) _buildFeaturedSection(),
          _buildSection('🔥 Popular Movies', _popular),
          _buildSection('⭐ Top Rated', _topRated),
          _buildSection('🎬 Coming Soon', _upcoming),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.darkBackground,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'CineTrack',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white),
          tooltip: 'Search movies',
          onPressed: () {
            // Navigate to search tab via parent
            final scaffold = Scaffold.of(context);
            scaffold.openEndDrawer();
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    if (_popular.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final featured = _popular.first;
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => MovieDetailsScreen(movie: featured),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Featured',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _FeaturedCard(movie: featured),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => MovieCard(movie: movies[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Movie movie;

  const _FeaturedCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final inWatchlist = provider.isInWatchlist(movie.id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Backdrop/Poster
          AspectRatio(
            aspectRatio: 16 / 9,
            child: movie.backdropUrl.isNotEmpty
                ? Image.network(
                    movie.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => movie.posterUrl.isNotEmpty
                        ? Image.network(movie.posterUrl, fit: BoxFit.cover)
                        : Container(color: AppTheme.cardColor),
                  )
                : movie.posterUrl.isNotEmpty
                    ? Image.network(movie.posterUrl, fit: BoxFit.cover)
                    : Container(color: AppTheme.cardColor),
          ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          // Movie info
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      movie.ratingFormatted,
                      style: const TextStyle(color: AppTheme.starColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      movie.releaseYear,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        if (inWatchlist) {
                          await provider.removeFromWatchlist(movie.id);
                        } else {
                          await provider.addToWatchlist(movie);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: inWatchlist ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: inWatchlist ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.38),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              inWatchlist ? Icons.bookmark : Icons.bookmark_add_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              inWatchlist ? 'Saved' : 'Watchlist',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
