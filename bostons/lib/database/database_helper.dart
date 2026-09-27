import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/call_out.dart';
import '../models/completed_cut.dart';
import '../models/customer.dart';
import '../models/haircut.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      'bostons.db',
    );

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE haircuts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        haircut_id INTEGER NOT NULL,
        haircut_name TEXT NOT NULL,
        price REAL NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE completed_cuts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        haircut_name TEXT NOT NULL,
        price REAL NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE call_outs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        address TEXT NOT NULL,
        call_out_time TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await _seedHaircuts(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE call_outs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_name TEXT NOT NULL,
          address TEXT NOT NULL,
          call_out_time TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _seedHaircuts(Database db) async {
    final haircuts = [
      {
        'name': 'Buzz Cut',
        'price': 80.0,
      },
      {
        'name': 'Fade',
        'price': 100.0,
      },
      {
        'name': 'Skin Fade',
        'price': 120.0,
      },
      {
        'name': 'Classic Cut',
        'price': 90.0,
      },
      {
        'name': 'Beard Trim',
        'price': 50.0,
      },
    ];

    for (final haircut in haircuts) {
      await db.insert(
        'haircuts',
        haircut,
      );
    }
  }

  // ------------------------------------------------------------
  // HAIRCUTS
  // ------------------------------------------------------------

  Future<List<Haircut>> getHaircuts() async {
    final db = await database;

    final result = await db.query(
      'haircuts',
      orderBy: 'name ASC',
    );

    return result.map((map) => Haircut.fromMap(map)).toList();
  }

  Future<int> addHaircut(
    Haircut haircut,
  ) async {
    final db = await database;

    return await db.insert(
      'haircuts',
      haircut.toMap(),
    );
  }

  Future<int> updateHaircut(
    Haircut haircut,
  ) async {
    final db = await database;

    return await db.update(
      'haircuts',
      haircut.toMap(),
      where: 'id = ?',
      whereArgs: [haircut.id],
    );
  }

  Future<int> deleteHaircut(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'haircuts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ------------------------------------------------------------
  // CUSTOMERS / QUEUE
  // ------------------------------------------------------------

  Future<int> addCustomer(
    Customer customer,
  ) async {
    final db = await database;

    return await db.insert(
      'customers',
      customer.toMap(),
    );
  }

  Future<List<Customer>> getWaitingCustomers() async {
    final db = await database;

    final result = await db.query(
      'customers',
      where: 'status = ?',
      whereArgs: ['waiting'],
      orderBy: 'created_at ASC',
    );

    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> removeCustomer(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> completeCustomer(
    Customer customer,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert(
        'completed_cuts',
        {
          'customer_name': customer.name,
          'haircut_name': customer.haircutName,
          'price': customer.price,
          'completed_at': DateTime.now().toIso8601String(),
        },
      );

      await txn.update(
        'customers',
        {
          'status': 'completed',
        },
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    });
  }

  // ------------------------------------------------------------
  // COMPLETED CUTS
  // ------------------------------------------------------------

  Future<List<CompletedCut>> getCompletedCuts() async {
    final db = await database;

    final result = await db.query(
      'completed_cuts',
      orderBy: 'completed_at DESC',
    );

    return result.map((map) => CompletedCut.fromMap(map)).toList();
  }

  Future<List<CompletedCut>> getTodayCompletedCuts() async {
    final db = await database;

    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    final result = await db.query(
      'completed_cuts',
      where: 'completed_at >= ? AND completed_at < ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'completed_at DESC',
    );

    return result.map((map) => CompletedCut.fromMap(map)).toList();
  }

  // ------------------------------------------------------------
  // CALL OUTS
  // ------------------------------------------------------------

  Future<int> addCallOut(
    CallOut callOut,
  ) async {
    final db = await database;

    return await db.insert(
      'call_outs',
      callOut.toMap(),
    );
  }

  Future<List<CallOut>> getCallOuts() async {
    final db = await database;

    final result = await db.query(
      'call_outs',
      orderBy: 'call_out_time ASC',
    );

    return result.map((map) => CallOut.fromMap(map)).toList();
  }

  Future<List<CallOut>> getUpcomingCallOuts() async {
    final db = await database;

    final result = await db.query(
      'call_outs',
      where: 'status = ?',
      whereArgs: ['upcoming'],
      orderBy: 'call_out_time ASC',
    );

    return result.map((map) => CallOut.fromMap(map)).toList();
  }

  Future<int> updateCallOutStatus(
    int id,
    String status,
  ) async {
    final db = await database;

    return await db.update(
      'call_outs',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCallOut(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'call_outs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
