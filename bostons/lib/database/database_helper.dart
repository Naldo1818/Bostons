import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/customer.dart';
import '../models/haircut.dart';
import '../models/completed_cut.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'bostons.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(
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

    await db.insert(
      'haircuts',
      {
        'name': 'Buzz Cut',
        'price': 80,
      },
    );

    await db.insert(
      'haircuts',
      {
        'name': 'Fade',
        'price': 100,
      },
    );

    await db.insert(
      'haircuts',
      {
        'name': 'Skin Fade',
        'price': 120,
      },
    );

    await db.insert(
      'haircuts',
      {
        'name': 'Classic Cut',
        'price': 90,
      },
    );

    await db.insert(
      'haircuts',
      {
        'name': 'Beard Trim',
        'price': 50,
      },
    );
  }

  Future<List<Haircut>> getHaircuts() async {
    final db = await database;

    final result = await db.query(
      'haircuts',
      orderBy: 'name ASC',
    );

    return result.map((map) => Haircut.fromMap(map)).toList();
  }

  Future<int> addHaircut(Haircut haircut) async {
    final db = await database;

    return await db.insert(
      'haircuts',
      haircut.toMap(),
    );
  }

  Future<int> updateHaircut(Haircut haircut) async {
    final db = await database;

    return await db.update(
      'haircuts',
      haircut.toMap(),
      where: 'id = ?',
      whereArgs: [haircut.id],
    );
  }

  Future<int> deleteHaircut(int id) async {
    final db = await database;

    return await db.delete(
      'haircuts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addCustomer(Customer customer) async {
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

  Future<void> completeCustomer(Customer customer) async {
    final db = await database;

    await db.transaction((transaction) async {
      await transaction.insert(
        'completed_cuts',
        CompletedCut(
          customerName: customer.name,
          haircutName: customer.haircutName,
          price: customer.price,
          completedAt: DateTime.now(),
        ).toMap(),
      );

      await transaction.update(
        'customers',
        {
          'status': 'completed',
        },
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    });
  }

  Future<void> removeCustomer(int id) async {
    final db = await database;

    await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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
}
