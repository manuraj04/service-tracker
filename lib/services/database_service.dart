import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_engineer_tracker/models/bank.dart';

class DatabaseService {
  static final _db = FirebaseFirestore.instance;
  static final _banksCollection = _db.collection('banks');

  static Future<void> addBank(BankEntry bank, String selectedBranch) async {
    final docRef = _banksCollection.doc();
    final timestamp = FieldValue.serverTimestamp();
    
    await docRef.set({
      'bankName': bank.bankName,
      'branchName': selectedBranch,
      'createdAt': timestamp,
      'updatedAt': timestamp,
    });

    // Add to activity log
    await _addToActivityLog('Added new bank: ${bank.bankName} - $selectedBranch');
  }

  static Future<void> _addToActivityLog(String activity) async {
    await _db.collection('activity_logs').add({
      'activity': activity,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getBanksStream() {
    return _banksCollection
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  static Future<void> updateBank(String docId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _banksCollection.doc(docId).update(updates);
    
    // Add to activity log
    await _addToActivityLog('Updated bank details: ${updates['name'] ?? 'Unknown'}');
  }

  static Future<void> deleteBank(String docId, String bankName) async {
    await _banksCollection.doc(docId).delete();
    
    // Add to activity log
    await _addToActivityLog('Deleted bank: $bankName');
  }
}