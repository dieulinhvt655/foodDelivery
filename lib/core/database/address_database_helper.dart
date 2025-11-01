import 'package:sqflite/sqflite.dart';

import '../models/address_model.dart';
import 'account_database_helper.dart';

class AddressDatabaseHelper {
  AddressDatabaseHelper._();

  static final AddressDatabaseHelper instance = AddressDatabaseHelper._();

  Future<Database> get _db async => AccountDatabaseHelper.instance.database;

  Future<List<AddressModel>> fetchAddresses(int userId) async {
    final db = await _db;
    final result = await db.query(
      'addresses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_default DESC, created_at DESC',
    );
    return result.map(AddressModel.fromMap).toList();
  }

  Future<int> insertAddress(AddressModel address, {bool setAsDefault = false}) async {
    final db = await _db;
    return db.transaction((txn) async {
      if (setAsDefault || address.isDefault) {
        await txn.update(
          'addresses',
          {'is_default': 0},
          where: 'user_id = ?',
          whereArgs: [address.userId],
        );
      }

      final isFirstAddress = (await txn.rawQuery(
        'SELECT COUNT(*) as count FROM addresses WHERE user_id = ?',
        [address.userId],
      ))
              .first['count'] ==
          0;

      final toInsert = address.copyWith(
        isDefault: setAsDefault || address.isDefault || isFirstAddress,
        createdAt: DateTime.now(),
      );

      final id = await txn.insert(
        'addresses',
        toInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return id;
    });
  }

  Future<void> setDefaultAddress({required int userId, required int addressId}) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      await txn.update(
        'addresses',
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [addressId],
      );
    });
  }

  Future<void> deleteAddress(int addressId) async {
    final db = await _db;
    await db.delete(
      'addresses',
      where: 'id = ?',
      whereArgs: [addressId],
    );
  }
}

