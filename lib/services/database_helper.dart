import 'package:sqflite/sqflite.dart';
import 'db_factory.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import '../models/storage_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    // Uses conditional importing from db_factory.dart to select native or web FFI
    databaseFactory = platformDatabaseFactory;

    String path;
    if (kIsWeb) {
      path = 'backup_organiser.db'; // Web DBs don't use absolute paths
    } else {
      path = join(await getDatabasesPath(), 'backup_organiser.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parentId INTEGER
      )
    ''');
  }

  Future<int> insertItem(StorageItem item) async {
    Database db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<StorageItem>> getItemsByParentId(int? parentId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: parentId == null ? 'parentId IS NULL' : 'parentId = ?',
      whereArgs: parentId == null ? [] : [parentId],
    );
    return List.generate(maps.length, (i) {
      return StorageItem.fromMap(maps[i]);
    });
  }
  
  Future<List<StorageItem>> getRootStorages() async {
    return getItemsByParentId(null);
  }

  Future<StorageItem?> getItemById(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return StorageItem.fromMap(maps.first);
    return null;
  }

  Future<List<StorageItem>> searchItems(String query) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) => StorageItem.fromMap(maps[i]));
  }

  Future<int> updateItem(StorageItem item) async {
    Database db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    // Todo: delete all children recursively. For now just delete this item.
    // To ensure proper referential integrity, we would need to delete all folders/items within it too.
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItemAndChildren(int id) async {
     Database db = await database;
     // simple recursive deletion for an extremely deep tree would require recursive CTE in sqlite 
     // or doing it in code. Since the tree is small (storage -> folder -> item), we can do it in code.
     await _deleteRecursively(db, id);
  }

  Future<void> _deleteRecursively(Database db, int id) async {
    // 1. Get children
    List<Map<String, dynamic>> children = await db.query('items', where: 'parentId = ?', whereArgs: [id]);
    
    // 2. Delete children recursively
    for(var child in children) {
      await _deleteRecursively(db, child['id']);
    }

    // 3. Delete self
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
