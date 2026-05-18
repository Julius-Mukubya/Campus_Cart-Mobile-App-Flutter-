import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';

/// Search state model
class SearchState {
  final String query;
  final List<Map<String, dynamic>> results;
  final List<String> searchHistory;
  final bool isSearching;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.searchHistory = const [],
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Map<String, dynamic>>? results,
    List<String>? searchHistory,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      searchHistory: searchHistory ?? this.searchHistory,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

/// Search notifier for managing search state
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  /// Perform product search
  void search(
    String query,
    List<Map<String, dynamic>> allProducts,
  ) {
    if (query.isEmpty) {
      state = state.copyWith(
        query: '',
        results: const [],
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true, error: null);

    try {
      final lowerQuery = query.toLowerCase();
      final results = allProducts.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final description = product['description']?.toString().toLowerCase() ?? '';
        final category = product['category']?.toString().toLowerCase() ?? '';

        return name.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            category.contains(lowerQuery);
      }).toList();

      state = state.copyWith(
        query: query,
        results: results,
        isSearching: false,
      );

      // Add to search history
      _addToHistory(query);

      AppLogger.info('Search: "$query" found ${results.length} products');
    } catch (e) {
      AppLogger.error('Search error', error: e);
      state = state.copyWith(
        isSearching: false,
        error: 'Search failed: $e',
      );
    }
  }

  /// Clear search
  void clearSearch() {
    state = const SearchState();
    AppLogger.info('Search cleared');
  }

  /// Add query to search history
  void _addToHistory(String query) {
    final history = [...state.searchHistory];

    // Remove if already exists
    history.removeWhere((q) => q.toLowerCase() == query.toLowerCase());

    // Add to beginning
    history.insert(0, query);

    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeLast();
    }

    state = state.copyWith(searchHistory: history);
  }

  /// Get search history
  List<String> getHistory() {
    return state.searchHistory;
  }

  /// Clear history
  void clearHistory() {
    state = state.copyWith(searchHistory: const []);
    AppLogger.info('Search history cleared');
  }

  /// Remove item from history
  void removeFromHistory(String query) {
    final history = state.searchHistory
        .where((q) => q.toLowerCase() != query.toLowerCase())
        .toList();
    state = state.copyWith(searchHistory: history);
  }

  /// Get suggestions based on query
  List<String> getSuggestions(
    String query,
    List<Map<String, dynamic>> allProducts,
  ) {
    if (query.isEmpty) {
      return state.searchHistory;
    }

    final lowerQuery = query.toLowerCase();
    final suggestions = <String>{};

    // Product name matches
    for (var product in allProducts) {
      final name = product['name']?.toString() ?? '';
      if (name.toLowerCase().contains(lowerQuery)) {
        suggestions.add(name);
      }
    }

    // Category matches
    for (var product in allProducts) {
      final category = product['category']?.toString() ?? '';
      if (category.toLowerCase().contains(lowerQuery)) {
        suggestions.add(category);
      }
    }

    // History matches
    for (var history in state.searchHistory) {
      if (history.toLowerCase().contains(lowerQuery)) {
        suggestions.add(history);
      }
    }

    return suggestions.toList().take(8).toList();
  }
}

/// Search provider
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);
