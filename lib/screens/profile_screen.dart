import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../services/storage_service.dart';
import '../services/movie_api_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    final savedKey = StorageService.loadApiKey();
    if (savedKey != null) {
      _apiKeyController.text = savedKey;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        final avgRating = provider.averageUserRating;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile & Stats')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'CineTrack User',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('Movie Enthusiast', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Stats grid
              _buildSection(
                'Statistics',
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Total',
                      value: '${provider.totalCount}',
                      icon: Icons.movie_rounded,
                      color: AppTheme.primaryRed,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Watched',
                      value: '${provider.watchedCount}',
                      icon: Icons.done_all_rounded,
                      color: Colors.green.shade500,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'To Watch',
                      value: '${provider.toWatchCount}',
                      icon: Icons.schedule_rounded,
                      color: Colors.orange.shade400,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (avgRating > 0)
                _buildSection(
                  'My Average Rating',
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        avgRating.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.starColor,
                        ),
                      ),
                      const Text(
                        ' / 5',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Appearance
              _buildSection(
                'Appearance',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: provider.isDarkMode ? Colors.indigo.shade300 : Colors.orange.shade400,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          provider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                    Switch(
                      value: provider.isDarkMode,
                      activeThumbColor: AppTheme.primaryRed,
                      onChanged: (_) => provider.toggleTheme(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // TMDB API Key
              _buildSection(
                'TMDB API Key',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required to load movies. Get your free key at themoviedb.org.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: !_showApiKey,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Paste your API key here',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showApiKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _showApiKey = !_showApiKey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final key = _apiKeyController.text.trim();
                        if (key.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid API key')),
                          );
                          return;
                        }
                        MovieApiService.setApiKey(key);
                        MovieApiService.clearCache();
                        await StorageService.saveApiKey(key);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('API key saved! Restart the app or go to Home to reload movies.')),
                          );
                        }
                      },
                      child: const Text('Save API Key'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Danger zone
              _buildSection(
                'Data',
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.primaryRed),
                      title: const Text('Clear Watchlist', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Remove all saved movies permanently',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                      onTap: () => _confirmClearAll(context, provider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About
              const Center(
                child: Text(
                  'CineTrack v1.0.0 • Powered by TMDB',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WatchlistProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Clear Watchlist', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete all movies from your watchlist. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Watchlist cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryRed),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
