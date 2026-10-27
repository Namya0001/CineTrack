import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../screens/movie_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text('My Watchlist'),
                const SizedBox(width: 8),
                if (provider.totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.totalCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            actions: [
              if (provider.totalCount > 0)
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  onPressed: () => _showSortMenu(context, provider),
                  tooltip: 'Sort',
                ),
            ],
          ),
          body: provider.totalCount == 0
              ? const EmptyState(
                  icon: Icons.movie_creation_outlined,
                  title: 'Your Watchlist is Empty',
                  subtitle: 'Browse movies on the Home screen\nand tap the bookmark icon to save them here',
                )
              : Column(
                  children: [
                    _FilterBar(provider: provider),
                    Expanded(
                      child: _WatchlistContent(provider: provider),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showSortMenu(BuildContext context, WatchlistProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Sort By',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            _SortTile(
              label: 'Title (A–Z)',
              icon: Icons.sort_by_alpha_rounded,
              selected: provider.sort == WatchlistSort.title,
              onTap: () {
                provider.setSort(WatchlistSort.title);
                Navigator.pop(context);
              },
            ),
            _SortTile(
              label: 'Release Date (Newest)',
              icon: Icons.calendar_today_rounded,
              selected: provider.sort == WatchlistSort.releaseDate,
              onTap: () {
                provider.setSort(WatchlistSort.releaseDate);
                Navigator.pop(context);
              },
            ),
            _SortTile(
              label: 'TMDB Rating',
              icon: Icons.star_rounded,
              selected: provider.sort == WatchlistSort.rating,
              onTap: () {
                provider.setSort(WatchlistSort.rating);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final WatchlistProvider provider;

  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All (${provider.totalCount})',
            selected: provider.filter == WatchlistFilter.all,
            onSelected: () => provider.setFilter(WatchlistFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'To Watch (${provider.toWatchCount})',
            selected: provider.filter == WatchlistFilter.toWatch,
            onSelected: () => provider.setFilter(WatchlistFilter.toWatch),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Watched (${provider.watchedCount})',
            selected: provider.filter == WatchlistFilter.watched,
            onSelected: () => provider.setFilter(WatchlistFilter.watched),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryRed : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryRed : const Color(0xFF2E2E3E),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _WatchlistContent extends StatelessWidget {
  final WatchlistProvider provider;

  const _WatchlistContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    final movies = provider.watchlist;

    if (movies.isEmpty) {
      return EmptyState(
        icon: Icons.filter_alt_outlined,
        title: 'No Movies Here',
        subtitle: provider.filter == WatchlistFilter.toWatch
            ? 'You have no movies to watch yet'
            : 'You have not watched any movies yet',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.52,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _WatchlistMovieCard(movie: movie, provider: provider);
      },
    );
  }
}

class _WatchlistMovieCard extends StatelessWidget {
  final Movie movie;
  final WatchlistProvider provider;

  const _WatchlistMovieCard({required this.movie, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => MovieDetailsScreen(movie: movie),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      onLongPress: () => _showOptions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox.expand(
                    child: movie.posterUrl.isNotEmpty
                        ? Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                // Watched overlay
                if (movie.isWatched)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 3),
                          Text('Watched', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                // Remove button
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _confirmRemove(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF0F0F0)),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 12),
              const SizedBox(width: 3),
              Text(movie.ratingFormatted, style: const TextStyle(color: AppTheme.starColor, fontSize: 11)),
              if (movie.userRating != null) ...[
                const SizedBox(width: 6),
                const Icon(Icons.person_rounded, color: AppTheme.textSecondary, size: 12),
                const SizedBox(width: 2),
                Text(
                  movie.userRating!.toStringAsFixed(1),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.cardColor,
      child: const Center(child: Icon(Icons.movie_outlined, color: AppTheme.textSecondary, size: 32)),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Remove Movie', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${movie.title}" from your watchlist?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.removeFromWatchlist(movie.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              movie.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(color: Color(0xFF2E2E3E)),
          ListTile(
            leading: Icon(
              movie.isWatched ? Icons.remove_done_rounded : Icons.done_all_rounded,
              color: movie.isWatched ? Colors.orange : Colors.green,
            ),
            title: Text(
              movie.isWatched ? 'Mark as Unwatched' : 'Mark as Watched',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              provider.toggleWatched(movie.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.primaryRed),
            title: const Text('Remove from Watchlist', style: TextStyle(color: AppTheme.primaryRed)),
            onTap: () {
              Navigator.pop(context);
              provider.removeFromWatchlist(movie.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.primaryRed : AppTheme.textSecondary),
      title: Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary)),
      trailing: selected ? const Icon(Icons.check_rounded, color: AppTheme.primaryRed) : null,
      onTap: onTap,
    );
  }
}

