import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/event_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<JobModel>> searchJobs({
    required String query,
    String? company,
    DateTime? startDate,
  }) {
    Query queryRef = _firestore.collection('jobs')
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThan: query + 'z');

    if (company != null) {
      queryRef = queryRef.where('company', isEqualTo: company);
    }
    if (startDate != null) {
      queryRef = queryRef.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }

    return queryRef.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => JobModel.fromFirestore(doc.data(), doc.id))
      .toList());
  }

  Stream<List<EventModel>> searchEvents({
    required String query,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query queryRef = _firestore.collection('events')
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThan: query + 'z');

    if (location != null) {
      queryRef = queryRef.where('location', isEqualTo: location);
    }
    if (startDate != null) {
      queryRef = queryRef.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      queryRef = queryRef.where('date', isLessThanOrEqualTo: endDate);
    }

    return queryRef.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
      .toList());
  }

  Future<List<String>> getCompanies() async {
    final snapshot = await _firestore.collection('jobs').get();
    return snapshot.docs
      .map((doc) => doc.data()['company'] as String)
      .toSet()
      .toList();
  }

  Future<List<String>> getLocations() async {
    final snapshot = await _firestore.collection('events').get();
    return snapshot.docs
      .map((doc) => doc.data()['location'] as String)
      .toSet()
      .toList();
  }

  Future<List<String>> getJobTitleSuggestions(String query) async {
    final snapshot = await _firestore.collection('jobs')
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThan: query + 'z')
      .limit(5)
      .get();
    return snapshot.docs
      .map((doc) => doc.data()['title'] as String)
      .toSet()
      .toList();
  }

  Future<List<String>> getEventTitleSuggestions(String query) async {
    final snapshot = await _firestore.collection('events')
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThan: query + 'z')
      .limit(5)
      .get();
    return snapshot.docs
      .map((doc) => doc.data()['title'] as String)
      .toSet()
      .toList();
  }
}