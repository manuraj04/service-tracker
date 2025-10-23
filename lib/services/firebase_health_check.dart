import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseHealthCheck {
  static final FirebaseHealthCheck instance = FirebaseHealthCheck._internal();
  FirebaseHealthCheck._internal();

  Future<Map<String, dynamic>> checkFirebaseStatus() async {
    final status = <String, dynamic>{
      'isInitialized': false,
      'firestoreConnection': false,
      'collections': <String, bool>{},
      'errors': <String>[],
    };

    try {
      // Check Firebase initialization
      status['isInitialized'] = Firebase.apps.isNotEmpty;
      
      if (!status['isInitialized']) {
        status['errors'].add('Firebase is not initialized');
        return status;
      }

      // Check Firestore connection
      final db = FirebaseFirestore.instance;
      try {
        await db.runTransaction((transaction) async {
          return true;
        });
        status['firestoreConnection'] = true;
      } catch (e) {
        status['errors'].add('Firestore connection failed: $e');
        return status;
      }

      // Check collections existence and permissions
      final collections = ['banks', 'machines', 'activity_logs'];
      for (final collection in collections) {
        try {
          // Try to get one document to verify read access
          final query = await db.collection(collection).limit(1).get();
          status['collections'][collection] = true;
        } catch (e) {
          status['collections'][collection] = false;
          status['errors'].add('Cannot access $collection: $e');
        }
      }

      // Try writing a test document
      try {
        final testDoc = await db.collection('activity_logs').add({
          'activity': 'Firebase health check',
          'timestamp': FieldValue.serverTimestamp(),
        });
        await testDoc.delete(); // Clean up test document
      } catch (e) {
        status['errors'].add('Write test failed: $e');
      }

    } catch (e) {
      status['errors'].add('Unexpected error: $e');
    }

    return status;
  }
}