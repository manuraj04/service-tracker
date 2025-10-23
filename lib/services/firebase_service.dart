import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bank.dart';
import '../models/machine.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitialized = false;

  FirebaseService._();

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await FirebaseFirestore.instance.collection('banks').limit(1).get();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  // Bank operations
  Future<void> syncBank(BankEntry bank) async {
    if (!_isInitialized) return;

    try {
      final doc = _firestore.collection('banks').doc(bank.id.toString());
      await doc.set({
        'bankName': bank.bankName,
        'branchName': bank.branchName,
        'branchCode': bank.branchCode,
        'ifscCode': bank.ifscCode,
        'contactName': bank.contactName,
        'contactPhone': bank.contactPhone,
        'address': bank.address,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error syncing bank to Firebase: $e');
      // Don't throw - allow offline operation
    }
  }

  Future<void> deleteBank(String bankId) async {
    if (!_isInitialized) return;

    try {
      await _firestore.collection('banks').doc(bankId).delete();
    } catch (e) {
      print('Error deleting bank from Firebase: $e');
      // Don't throw - allow offline operation
    }
  }

  Stream<List<BankEntry>> watchBanks() {
    if (!_isInitialized) {
      return Stream.value([]);
    }

    return _firestore.collection('banks')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return BankEntry(
                id: int.tryParse(doc.id),
                bankName: data['bankName'] as String,
                branchName: data['branchName'] as String,
                branchCode: data['branchCode'] as String,
                ifscCode: data['ifscCode'] as String,
                contactName: data['contactName'] as String?,
                contactPhone: data['contactPhone'] as String?,
                address: data['address'] as String?,
              );
            }).toList());
  }

  // Machine operations
  Future<void> syncMachine(Machine machine) async {
    if (!_isInitialized) return;

    try {
      final doc = _firestore.collection('banks')
          .doc(machine.bankId.toString())
          .collection('machines')
          .doc(machine.id.toString());
      
      await doc.set({
        'machineType': machine.machineType,
        'serialNumber': machine.serialNumber,
        'lastVisitDate': machine.lastVisitDate.millisecondsSinceEpoch,
        'nextVisitDate': machine.nextVisitDate.millisecondsSinceEpoch,
        'installationDate': machine.installationDate.millisecondsSinceEpoch,
        'isCsrCollected': machine.isCsrCollected,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error syncing machine to Firebase: $e');
    }
  }

  Future<void> deleteMachine(int bankId, int machineId) async {
    if (!_isInitialized) return;

    try {
      await _firestore.collection('banks')
          .doc(bankId.toString())
          .collection('machines')
          .doc(machineId.toString())
          .delete();
    } catch (e) {
      print('Error deleting machine from Firebase: $e');
    }
  }

  Stream<List<Machine>> watchMachines(int bankId) {
    if (!_isInitialized) {
      return Stream.value([]);
    }

    return _firestore.collection('banks')
        .doc(bankId.toString())
        .collection('machines')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Machine(
                id: int.tryParse(doc.id),
                bankId: bankId,
                machineType: data['machineType'] as String,
                serialNumber: data['serialNumber'] as String,
                lastVisitDate: DateTime.fromMillisecondsSinceEpoch(data['lastVisitDate'] as int),
                nextVisitDate: DateTime.fromMillisecondsSinceEpoch(data['nextVisitDate'] as int),
                installationDate: DateTime.fromMillisecondsSinceEpoch(data['installationDate'] as int),
                isCsrCollected: data['isCsrCollected'] as bool,
              );
            }).toList());
  }
}