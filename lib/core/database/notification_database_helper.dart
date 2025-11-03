import 'package:sqflite/sqflite.dart';
import '../models/notification_model.dart';
import 'account_database_helper.dart';

class NotificationDatabaseHelper {
  NotificationDatabaseHelper._();

  static final NotificationDatabaseHelper instance = NotificationDatabaseHelper._();
  static const _notificationsTable = 'notifications';

  Future<Database> get _db async => AccountDatabaseHelper.instance.database;

  // Make method accessible for database initialization
  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_notificationsTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        icon_code_point INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> saveNotification(NotificationModel notification) async {
    final db = await _db;
    await db.insert(
      _notificationsTable,
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationModel>> getNotificationsByUserId(String userId) async {
    final db = await _db;
    final result = await db.query(
      _notificationsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map(NotificationModel.fromMap).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    final db = await _db;
    await db.update(
      _notificationsTable,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> initTables() async {
    final db = await _db;
    await _createNotificationsTable(db);
  }

  // Public method for creating tables (used by AccountDatabaseHelper)
  Future<void> createTablesOnInit(Database db) async {
    await _createNotificationsTable(db);
  }
}

