import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ussd_menu.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ussd_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ussd_menus(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        code TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT
      )
    ''');
  }

  /// Ajouter un nouveau code USSD
  Future<int> insertMenu(UssdMenu menu) async {
    final db = await database;
    return await db.insert(
      'ussd_menus',
      menu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupérer tous les codes USSD
  Future<List<UssdMenu>> getAllMenus() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ussd_menus');
    return List.generate(maps.length, (i) {
      return UssdMenu.fromMap(maps[i]);
    });
  }

  /// Mettre à jour un code USSD
  Future<int> updateMenu(UssdMenu menu) async {
    final db = await database;
    return await db.update(
      'ussd_menus',
      menu.toMap(),
      where: 'id = ?',
      whereArgs: [menu.id],
    );
  }

  /// Supprimer un code USSD
  Future<int> deleteMenu(int id) async {
    final db = await database;
    return await db.delete(
      'ussd_menus',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Rechercher des codes par titre
  Future<List<UssdMenu>> searchMenus(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ussd_menus',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return UssdMenu.fromMap(maps[i]);
    });
  }
}
