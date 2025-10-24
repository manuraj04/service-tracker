import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../models/bank.dart';
import '../models/machine.dart';
import '../services/firebase_service.dart';
import '../services/sync_manager.dart';

final firebaseStatusProvider = StateProvider<bool>((ref) => false);

final syncStatusProvider = StateProvider<SyncStatus>((ref) => const SyncStatus());

final bankListProvider = StateNotifierProvider<BankListNotifier, AsyncValue<List<BankEntry>>>((ref) {
  return BankListNotifier(ref);
});

final machineListProvider = StateNotifierProvider.family<MachineListNotifier, AsyncValue<List<Machine>>, int>((ref, bankId) {
  return MachineListNotifier(bankId: bankId);
});

final allMachinesProvider = StateNotifierProvider<AllMachinesNotifier, AsyncValue<List<Machine>>>((ref) {
  return AllMachinesNotifier();
});

class BankListNotifier extends StateNotifier<AsyncValue<List<BankEntry>>> {
  BankListNotifier(Ref ref) : super(const AsyncValue.loading()) {
    _loadBanks();
    _setupFirebaseSync();
  }

  final _db = AppDatabase.instance;
  final _firebase = FirebaseService.instance;
  StreamSubscription<List<BankEntry>>? _firebaseSub;

  void _setupFirebaseSync() {
    if (_firebase.isInitialized) {
      // Initialize SyncManager without modifying other providers
      SyncManager.instance.initialize().then((_) {
        print('SyncManager initialized successfully');
      }).catchError((e) {
        print('Error initializing SyncManager: $e');
      });
    }
  }

  @override
  void dispose() {
    _firebaseSub?.cancel();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await _db.getAllBanks();
      state = AsyncValue.data(banks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBank(BankEntry bank) async {
    try {
      final newBank = await _db.createBank(bank);
      if (_firebase.isInitialized) {
        await _firebase.syncBank(newBank);
      }
      await _loadBanks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBank(BankEntry bank) async {
    try {
      await _db.updateBank(bank);
      if (_firebase.isInitialized) {
        await _firebase.syncBank(bank);
      }
      await _loadBanks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBank(int id) async {
    try {
      await _db.deleteBank(id);
      await _loadBanks();
    } catch (e) {
      rethrow;
    }
  }
}

class MachineListNotifier extends StateNotifier<AsyncValue<List<Machine>>> {
  MachineListNotifier({required this.bankId}) : super(const AsyncValue.loading()) {
    _loadMachines();
    _setupFirebaseSync();
  }

  final int bankId;
  final _db = AppDatabase.instance;
  final _firebase = FirebaseService.instance;
  StreamSubscription<List<Machine>>? _firebaseSub;

  void _setupFirebaseSync() {
    if (_firebase.isInitialized) {
      _firebaseSub = _firebase.watchMachines(bankId).listen((machines) async {
        // Update local DB with Firebase data
        for (final machine in machines) {
          await _db.updateMachine(machine);
        }
        await _loadMachines();
      });
    }
  }

  @override
  void dispose() {
    _firebaseSub?.cancel();
    super.dispose();
  }

  Future<void> _loadMachines() async {
    try {
      final machines = await _db.getMachinesByBank(bankId);
      state = AsyncValue.data(machines);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMachine(Machine machine) async {
    try {
      final newMachine = await _db.createMachine(machine);
      if (_firebase.isInitialized) {
        await _firebase.syncMachine(newMachine);
      }
      await _loadMachines();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMachine(Machine machine) async {
    try {
      await _db.updateMachine(machine);
      if (_firebase.isInitialized) {
        await _firebase.syncMachine(machine);
      }
      await _loadMachines();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMachine(int id) async {
    try {
      await _db.deleteMachine(id);
      if (_firebase.isInitialized) {
        await _firebase.deleteMachine(bankId, id);
      }
      await _loadMachines();
    } catch (e) {
      rethrow;
    }
  }
}

class AllMachinesNotifier extends StateNotifier<AsyncValue<List<Machine>>> {
  AllMachinesNotifier() : super(const AsyncValue.loading()) {
    _loadAll();
  }

  final _db = AppDatabase.instance;

  Future<void> _loadAll() async {
    try {
      final machines = await _db.getAllMachines();
      state = AsyncValue.data(machines);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => _loadAll();
}
