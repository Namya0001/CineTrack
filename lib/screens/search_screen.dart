import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_api_service.dart';
import '../widgets/movie_grid.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/empty_state.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Movie> _results = [];
  bool _isLoading = false;
  String? _error;
  String _lastQuery = '';

  // Debounce
  DateTime? _lastType;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _lastType = DateTime.now();
    final typed = DateTime.now();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _lastType == typed) {
        _search(query);
      }
    });
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed == _lastQuery) return;
    _lastQuery = trimmed;

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await MovieApiService.searchMovies(trimmed);
      if (mounted && _lastQuery == trimmed) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _lastQuery == trimmed) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    _controller.clear();
    _lastQuery = '';
    setState(() {
      _results = [];
      _error = null;
      _isLoading = false;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        backgroundColor: AppTheme.darkBackground,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: false,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search for movies...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearSearch,
                  tooltip: 'Clear search',
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (q) => _search(q),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Searching...');
    }

    if (_error != null) {
      return ErrorState(
        message: _error!,
        onRetry: () => _search(_lastQuery),
      );
    }

    if (_lastQuery.isEmpty) {
      return const EmptyState(
        icon: Icons.local_movies_rounded,
        title: 'Find Your Next Movie',
        subtitle: 'Search by title to discover\nmovies from our database',
      );
    }

    if (_results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Results Found',
        subtitle: 'We couldn\'t find any movies\nmatching "$_lastQuery"',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '${_results.length} results for "$_lastQuery"',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: MovieGrid(movies: _results),
        ),
      ],
    );
  }
}

