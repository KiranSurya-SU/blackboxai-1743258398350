++
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsModel {
  final String eventName;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  AnalyticsModel({
    required this.eventName,
    required this.parameters,
    required this.timestamp,
  });

  factory AnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnalyticsModel(
      eventName: data['eventName'] ?? '',
      parameters: Map<String, dynamic>.from(data['parameters'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  bool matchesSearchType(String type) {
    return parameters['search_type']?.toString().toLowerCase() == type.toLowerCase();
  }

  bool isSearchEvent() => eventName == 'search';
  bool isFilterEvent() => eventName == 'search_filter';
  bool isBetweenDates(DateTime? start, DateTime? end) {
    if (start != null && timestamp.isBefore(start)) return false;
    if (end != null && timestamp.isAfter(end)) return false;
    return true;
  }
}