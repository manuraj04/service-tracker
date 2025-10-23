import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/bank.dart';
import '../models/machine.dart';
import '../db/app_database.dart';

enum SyncEventType {
  started,
  completed,
  error,
  pendingChanges,
}

class SyncStatus {
  final bool isActive;
  final bool hasError;
  final int pendingChanges;
  final String message;

  const SyncStatus({
    this.isActive = false,
    this.hasError = false,
    this.pendingChanges = 0,
    this.message = 'Not syncing',
  });
}

class SyncManagerEvent {
  final SyncEventType type;
  final String? message;
  final int? pendingChanges;

  SyncManagerEvent({
    required this.type,
    this.message,
    this.pendingChanges,
  });
}

typedef SyncManagerEventCallback = void Function(SyncManagerEvent event);

class SyncManager {
  static final SyncManager instance = SyncManager._internal();
  final _connectivity = Connectivity();
  final _db = FirebaseFirestore.instance;
  StreamSubscription? _connectivitySub;
  bool _isOnline = false;
  final _pendingChanges = <Future Function()>[];
  final _listeners = <SyncManagerEventCallback>{};
  
  SyncManager._internal();

  void addListener(SyncManagerEventCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(SyncManagerEventCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(SyncManagerEvent event) {
    for (final listener in _listeners) {
      listener(event);
    }
  }

  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    
    // Listen for connectivity changes
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _processPendingChanges();
      }
    });

    // Set up real-time listeners if online
    if (_isOnline) {
      _setupRealtimeListeners();
    }
  }

  void _setupRealtimeListeners() {
    // Listen for bank changes
    _db.collection('banks').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        _handleBankChange(change);
      }
    }, onError: (e) {
      print('Error in bank sync: $e');
    });

    // Listen for machine changes
    _db.collection('machines').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        _handleMachineChange(change);
      }
    }, onError: (e) {
      print('Error in machine sync: $e');
    });
  }

  Future<void> _handleBankChange(DocumentChange<Map<String, dynamic>> change) async {
    final data = change.doc.data()!;
    final bank = BankEntry(
      id: data['localId'] as int,
      bankName: data['bankName'] as String,
      branchName: data['branchName'] as String,
    );

    switch (change.type) {
      case DocumentChangeType.added:
      case DocumentChangeType.modified:
        await AppDatabase.instance.updateBank(bank);
        break;
      case DocumentChangeType.removed:
        await AppDatabase.instance.deleteBank(bank.id!);
        break;
    }
  }

  Future<void> _handleMachineChange(DocumentChange<Map<String, dynamic>> change) async {
    final data = change.doc.data()!;
    final machine = Machine(
      id: data['localId'] as int,
      bankId: data['bankId'] as int,
      machineType: data['machineType'] as String,
      serialNumber: data['serialNumber'] as String,
      lastVisitDate: DateTime.fromMillisecondsSinceEpoch(data['lastVisitDate']),
      nextVisitDate: DateTime.fromMillisecondsSinceEpoch(data['nextVisitDate']),
      installationDate: DateTime.fromMillisecondsSinceEpoch(data['installationDate']),
      isCsrCollected: data['isCsrCollected'] as bool,
    );

    switch (change.type) {
      case DocumentChangeType.added:
      case DocumentChangeType.modified:
        await AppDatabase.instance.updateMachine(machine);
        break;
      case DocumentChangeType.removed:
        await AppDatabase.instance.deleteMachine(machine.id!);
        break;
    }
  }

  Future<void> syncBankToFirebase(BankEntry bank) async {
    Future<void> operation() async {
      final doc = _db.collection('banks').doc();
      await doc.set({
        'bankName': bank.bankName,
        'branchName': bank.branchName,
        'localId': bank.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (_isOnline) {
      await operation();
    } else {
      _pendingChanges.add(operation);
    }
  }

  Future<void> syncMachineToFirebase(Machine machine) async {
    Future<void> operation() async {
      final doc = _db.collection('machines').doc();
      await doc.set({
        'bankId': machine.bankId,
        'localId': machine.id,
        'machineType': machine.machineType,
        'serialNumber': machine.serialNumber,
        'lastVisitDate': machine.lastVisitDate.millisecondsSinceEpoch,
        'nextVisitDate': machine.nextVisitDate.millisecondsSinceEpoch,
        'installationDate': machine.installationDate.millisecondsSinceEpoch,
        'isCsrCollected': machine.isCsrCollected,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (_isOnline) {
      await operation();
    } else {
      _pendingChanges.add(operation);
    }
  }

  Future<void> _processPendingChanges() async {
    if (_pendingChanges.isEmpty) return;

    _notifyListeners(SyncManagerEvent(
      type: SyncEventType.started,
      pendingChanges: _pendingChanges.length,
    ));
    
    final changes = List.of(_pendingChanges);
    _pendingChanges.clear();
    
    for (final operation in changes) {
      try {
        await operation();
      } catch (e) {
        print('Error processing pending change: $e');
        _pendingChanges.add(operation); // Re-add failed operation
        _notifyListeners(SyncManagerEvent(
          type: SyncEventType.error,
          message: e.toString(),
          pendingChanges: _pendingChanges.length,
        ));
      }
    }

    _notifyListeners(SyncManagerEvent(
      type: SyncEventType.completed,
      pendingChanges: _pendingChanges.length,
    ));
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}