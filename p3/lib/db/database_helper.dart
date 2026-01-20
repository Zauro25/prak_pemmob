import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';


class DatabaseHelper {
  static const String _databaseName = 'notes.db';
  static const String _tableName = 'notes';
  static const int _databaseVersion = 1;

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  /// Get or initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database and create table if needed
  Future<Database> _initDatabase() async {
    // On web, getDatabasesPath is not available; use a simple name instead
    final path = kIsWeb
        ? _databaseName
        : join(await getDatabasesPath(), _databaseName);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
      ),
    );
  }

  /// Create the notes table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ==================== CREATE ====================
  /// Insert a new note into the database
  Future<int> addNote(Note note) async {
    final db = await database;
    return await db.insert(
      _tableName,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== READ ====================
  /// Get all notes from the database, ordered by created_at (newest first)
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get a note by its ID
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Note.fromMap(maps.first);
  }

  // ==================== UPDATE ====================
  /// Update an existing note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      _tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // ==================== DELETE ====================
  /// Delete a note by its ID
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all notes (use with caution!)
  Future<int> deleteAllNotes() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  /// Close the database connection
  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }
}
