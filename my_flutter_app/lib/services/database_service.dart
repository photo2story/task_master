import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task_master.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        year INTEGER NOT NULL,
        category TEXT NOT NULL,
        sub_category TEXT NOT NULL,
        detail TEXT NOT NULL,
        description TEXT,
        manager TEXT NOT NULL,
        supervisor TEXT NOT NULL,
        start_date TEXT NOT NULL,
        duration_days INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE project_phases (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        name TEXT NOT NULL,
        duration_days INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        manager TEXT NOT NULL,
        supervisor TEXT NOT NULL,
        sequence_num INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        phase_id TEXT NOT NULL,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        start_date TEXT,
        due_date TEXT,
        assignee TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (phase_id) REFERENCES project_phases (id) ON DELETE CASCADE
      )
    ''');
  }
} 