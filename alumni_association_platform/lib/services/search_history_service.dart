import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _searchHistoryKey = 'searchHistory';
  static const int _maxHistoryItems = 5;

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> addSearchQuery(String query, {bool isSuggestion = false}) async {
    if (query.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();
    
    // Remove duplicates and keep only the latest
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    history.insert(0, query);
    
    // Keep only the most recent items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    await prefs.setStringList(_searchHistoryKey, history);
    
    if (isSuggestion) {
      // Track suggestion clicks (will implement analytics later)
      print('Suggestion clicked: $query');
    }
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }
}