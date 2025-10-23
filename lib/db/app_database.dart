import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/bank.dart';
import '../models/machine.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('service_engineer_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, fileName);
    return await openDatabase(
      dbPath,
      version: 2,
      onConfigure: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _v2AddBranchDetails(db);
    }
  }

  Future _createDB(Database db, int version) async {
    await _v1CreateTables(db);
    if (version >= 2) {
      await _v2AddBranchDetails(db);
    }
  }

  Future _v1CreateTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const intType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE IF NOT EXISTS banks (
        id $idType,
        bankName $textType,
        branchName $textType
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS machines (
        id $idType,
        bankId INTEGER NOT NULL,
        machineType $textType,
        serialNumber $textType,
        lastVisitDate $intType,
        nextVisitDate $intType,
        installationDate $intType,
        isCsrCollected $intType,
        FOREIGN KEY (bankId) REFERENCES banks(id) ON DELETE CASCADE
      );
    ''');
  }

  Future _v2AddBranchDetails(Database db) async {
    const nullableText = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    
    // Backup old machines data
    final machines = await db.query('machines');
    
    // Drop and recreate machines table
    await db.execute('DROP TABLE IF EXISTS machines');
    await db.execute('''
      CREATE TABLE machines (
        id $idType,
        bankId INTEGER NOT NULL,
        machineType $textType,
        serialNumber $textType,
        lastVisitDate $intType,
        nextVisitDate $intType,
        installationDate $intType,
        isCsrCollected INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (bankId) REFERENCES banks(id) ON DELETE CASCADE
      );
    ''');
    
    // Restore machines data
    for (final machine in machines) {
      await db.insert('machines', machine);
    }
    
    // Add new columns to banks table
    await db.execute('ALTER TABLE banks ADD COLUMN branchCode $nullableText;');
    await db.execute('ALTER TABLE banks ADD COLUMN ifscCode $nullableText;');
    await db.execute('ALTER TABLE banks ADD COLUMN contactName $nullableText;');
    await db.execute('ALTER TABLE banks ADD COLUMN contactPhone $nullableText;');
    await db.execute('ALTER TABLE banks ADD COLUMN address $nullableText;');
  }

  // Bank CRUD
  Future<BankEntry> createBank(BankEntry bank) async {
    try {
      final db = await instance.database;
      final id = await db.insert('banks', bank.toMap());
      return bank.copyWith(id: id);
    } catch (e) {
      rethrow;
    }
  }

  Future<BankEntry?> getBank(int id) async {
    final db = await instance.database;
    final maps = await db.query('banks', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return BankEntry.fromMap(maps.first);
    return null;
  }

  Future<List<BankEntry>> getAllBanks() async {
    final db = await instance.database;
    final result = await db.query('banks', orderBy: 'bankName ASC');
    return result.map((m) => BankEntry.fromMap(m)).toList();
  }

  Future<int> updateBank(BankEntry bank) async {
    final db = await instance.database;
    return db.update('banks', bank.toMap(), where: 'id = ?', whereArgs: [bank.id]);
  }

  Future<int> deleteBank(int id) async {
    final db = await instance.database;
    return db.delete('banks', where: 'id = ?', whereArgs: [id]);
  }

  // Machine CRUD
  Future<Machine> createMachine(Machine machine) async {
    final db = await instance.database;
    final id = await db.insert('machines', machine.toMap());
    return machine.copyWith(id: id);
  }

  Future<Machine?> getMachine(int id) async {
    final db = await instance.database;
    final maps = await db.query('machines', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Machine.fromMap(maps.first);
    return null;
  }

  Future<List<Machine>> getMachinesByBank(int bankId) async {
    final db = await instance.database;
    final result = await db.query('machines', where: 'bankId = ?', whereArgs: [bankId], orderBy: 'nextVisitDate ASC');
    return result.map((m) => Machine.fromMap(m)).toList();
  }

  Future<List<Machine>> getAllMachines() async {
    final db = await instance.database;
    final result = await db.query('machines', orderBy: 'nextVisitDate ASC');
    return result.map((m) => Machine.fromMap(m)).toList();
  }

  Future<int> updateMachine(Machine machine) async {
    final db = await instance.database;
    return db.update('machines', machine.toMap(), where: 'id = ?', whereArgs: [machine.id]);
  }

  Future<int> deleteMachine(int id) async {
    final db = await instance.database;
    return db.delete('machines', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  /// Seed the database with a list of common banks and small finance banks
  /// if the banks table is empty. This is useful for initial demo data.
  Future<void> seedSampleBanks() async {
    final existing = await getAllBanks();
    if (existing.isNotEmpty) return;

    final samples = <BankEntry>[
      BankEntry(bankName: 'State Bank of India', branchName: 'Multiple'),
      BankEntry(bankName: 'Bank of India', branchName: 'Multiple'),
      BankEntry(bankName: 'Punjab National Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Union Bank of India', branchName: 'Multiple'),
      BankEntry(bankName: 'Central Bank of India', branchName: 'Multiple'),
      BankEntry(bankName: 'Canara Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Axis Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'HDFC Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'ICICI Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Bandhan Bank', branchName: 'Multiple'),
      // Small finance banks
      BankEntry(bankName: 'AU Small Finance Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Ujjivan Small Finance Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Equitas Small Finance Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Jana Small Finance Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Suryoday Small Finance Bank', branchName: 'Multiple'),
      BankEntry(bankName: 'Fincare Small Finance Bank', branchName: 'Multiple'),
    ];

    for (final b in samples) {
      try {
        await createBank(b);
      } catch (_) {
        // ignore individual failures while seeding
      }
    }
  }
}
