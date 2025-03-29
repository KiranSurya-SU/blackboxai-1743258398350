import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<EventModel>> getEvents() {
    return _firestore.collection('events')
      .orderBy('date', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Future<void> createEvent(EventModel event) async {
    await _firestore.collection('events').add(event.toFirestore());
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    await _firestore.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> cancelRegistration(String eventId, String userId) async {
    await _firestore.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayRemove([userId])
    });
  }
}