import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bank.dart';
import '../models/machine.dart';

class FirestoreSyncService {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> checkConnection() async {
    try {
      await _db.runTransaction((transaction) async {
        // Just a lightweight query to check connection
        await _db.collection('banks').limit(1).get();
      });
      return true;
    } catch (e) {
      print('Firebase connection check failed: $e');
      return false;
    }
  }

  static Future<void> pushBank(BankEntry bank) async {
    await _db.collection('banks').add({
      'bankName': bank.bankName,
      'branchName': bank.branchName,
      'localId': bank.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> pushMachine(Machine machine) async {
    await _db.collection('machines').add({
      'bankId': machine.bankId,
      'machineType': machine.machineType,
      'serialNumber': machine.serialNumber,
      'isCsrCollected': machine.isCsrCollected,
      'installationDate': machine.installationDate,
      'lastVisitDate': machine.lastVisitDate,
      'nextVisitDate': machine.nextVisitDate,
    });
  }
}
