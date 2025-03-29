import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // User authentication methods
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  static Future<User?> registerWithEmail(
    String email, 
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);
      }
      
      return credential.user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }
}