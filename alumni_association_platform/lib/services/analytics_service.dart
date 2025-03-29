import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logSearch({
    required String query,
    required String searchType,
    bool isSuggestion = false,
  }) async {
    await _analytics.logEvent(
      name: 'search',
      parameters: {
        'search_term': query,
        'search_type': searchType,
        'is_suggestion': isSuggestion,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  static Future<void> logSearchFilter({
    required String filterType,
    required String filterValue,
    required String searchType,
  }) async {
    await _analytics.logEvent(
      name: 'search_filter',
      parameters: {
        'filter_type': filterType,
        'filter_value': filterValue,
        'search_type': searchType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}