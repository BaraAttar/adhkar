import 'dart:convert';
import 'package:adhkar/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // 🔴 غيّر هذا الرقم فقط عند تعديل ملفات الـ JSON مستقبلاً
  static const bool _devMode = true;
  static const int _currentDataVersion = 3;

  static Future<Database>? _initFuture;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _initFuture ??= _initDB();
    _database = await _initFuture;
    _initFuture = null;
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'adhkar.db');

    final db = await openDatabase(
      path,
      version: 2, // ارفع الإصدار من 1 إلى 2 لدعم الترتيب الجديد
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE adhkar ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0',
          );
          safeLog('✅ تم إضافة عمود sort_order للمستخدمين القدامى');
        }
      },
      onOpen: (db) async {
        await _ensureMetaTableExists(db);
      },
    );

    // 1. فحص ومزامنة البيانات مع ملفات الـ JSON
    await _checkAndSyncData(db);

    // 2. 🟢 فحص وتصفير الورد اليومي تلقائياً عند تغيير التاريخ (اليوم الجديد)
    await _checkAndResetDailyProgress(db);

    return db;
  }

  static Future<void> _ensureMetaTableExists(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      INSERT OR IGNORE INTO app_meta (key, value) VALUES ('data_version', '0')
    ''');
  }

  // 🟢 دالة فحص وتصفير الورد اليومي عند اكتشاف يوم جديد
  static Future<void> _checkAndResetDailyProgress(Database db) async {
    try {
      final now = DateTime.now();
      // تنسيق التاريخ الحالي بصيغة ثابتة YYYY-MM-DD
      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // استخراج تاريخ آخر فتح للتطبيق من جدول الميتا
      final List<Map<String, dynamic>> result = await db.query(
        'app_meta',
        where: 'key = ?',
        whereArgs: ['last_opened_date'],
      );

      if (result.isEmpty) {
        // أول تشغيل للتطبيق، نقوم بحفظ تاريخ اليوم فقط
        await db.insert('app_meta', {
          'key': 'last_opened_date',
          'value': todayStr,
        });
        safeLog('🌅 تم تسجيل تاريخ اليوم لأول مرة: $todayStr');
      } else {
        final String lastOpenedDate = result.first['value'] as String;

        // إذا اختلف التاريخ المحفوظ عن تاريخ اليوم الحالي
        if (lastOpenedDate != todayStr) {
          // 1. تصفير عداد الإنجاز الحالي لجميع الأذكار في قاعدة البيانات
          await db.update('adhkar', {'current_count': 0});

          // 2. تحديث تاريخ الفتح الأخير في جدول الميتا لليوم الجديد
          await db.update(
            'app_meta',
            {'value': todayStr},
            where: 'key = ?',
            whereArgs: ['last_opened_date'],
          );

          safeLog(
            '🌅 يوم جديد مبهج ($todayStr)! تم إعادة تصفير كافة عدادات الورد اليومي بنجاح.',
          );
        }
      }
    } catch (e) {
      safeLog('❌ خطأ أثناء فحص وتصفير الورد اليومي: $e');
    }
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE adhkar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        subcategory TEXT NOT NULL DEFAULT '',
        text TEXT NOT NULL,
        count_limit INTEGER NOT NULL DEFAULT 1,
        current_count INTEGER NOT NULL DEFAULT 0,
        virtue TEXT NOT NULL DEFAULT '', -- 🟢 تم إصلاح فاصلة ناقصة هنا لمنع الكراش مستقبلاً
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.insert('app_meta', {'key': 'data_version', 'value': '0'});
  }

  static Future<void> _checkAndSyncData(Database db) async {
    try {
      if (_devMode) {
        // safeLog('🛠️ Dev Mode: مزامنة إجبارية...');
        safeLog('🛠️ Dev Mode: مزامنة إجبارية...');
        await _syncAdhkarFromJSON(db);
        return;
      }

      final List<Map<String, dynamic>> meta = await db.query(
        'app_meta',
        where: 'key = ?',
        whereArgs: ['data_version'],
      );

      int savedVersion = 0;
      if (meta.isNotEmpty) {
        savedVersion = int.tryParse(meta.first['value'] as String) ?? 0;
      }

      if (savedVersion != _currentDataVersion) {
        final bool success = await _syncAdhkarFromJSON(db);
        if (success) {
          await db.update(
            'app_meta',
            {'value': _currentDataVersion.toString()},
            where: 'key = ?',
            whereArgs: ['data_version'],
          );
          safeLog('✅ تم التحديث للإصدار $_currentDataVersion بنجاح.');
        } else {
          safeLog('⚠️ فشلت المزامنة، لن يتم تحديث رقم الإصدار.');
        }
      }
    } catch (e) {
      safeLog('❌ خطأ في _checkAndSyncData: $e');
    }
  }

  static String _normalizeText(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u200B-\u200D\uFEFF]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _buildUniqueKey(String cat, String sub, String normalizedText) {
    return '$cat\x00$sub\x00$normalizedText';
  }

  static Future<bool> _syncAdhkarFromJSON(Database db) async {
    final List<String> jsonFiles = [
      'assets/data/morning.json',
      'assets/data/evening.json',
      'assets/data/sleep.json',
      'assets/data/other.json',
    ];

    try {
      final List<Map<String, dynamic>> existingRows = await db.query('adhkar');

      final Map<String, List<Map<String, dynamic>>> existingMap = {};
      for (final row in existingRows) {
        final key = _buildUniqueKey(
          row['category'] as String,
          row['subcategory'] as String,
          _normalizeText(row['text'] as String),
        );
        existingMap.putIfAbsent(key, () => []);
        existingMap[key]!.add(row);
      }

      final Map<String, Map<String, dynamic>> jsonMap = {};
      int globalOrder = 0;

      for (final filePath in jsonFiles) {
        late final List<dynamic> jsonList;
        try {
          final raw = await rootBundle.loadString(filePath);
          jsonList = json.decode(raw) as List<dynamic>;
        } catch (e) {
          safeLog('❌ خطأ في قراءة $filePath: $e');
          continue;
        }

        for (final item in jsonList) {
          if (item is! Map<String, dynamic>) {
            globalOrder++;
            continue;
          }

          final rawText = item['text'];
          final rawCat = item['category'];
          if (rawText == null || rawCat == null) {
            globalOrder++;
            continue;
          }

          final String text = rawText.toString().trim();
          final String cat = rawCat.toString().trim();
          if (text.isEmpty || cat.isEmpty) {
            globalOrder++;
            continue;
          }

          final String sub = item['subcategory']?.toString().trim() ?? '';
          final String key = _buildUniqueKey(cat, sub, _normalizeText(text));

          if (!jsonMap.containsKey(key)) {
            final enriched = Map<String, dynamic>.from(item);
            enriched['_sort_order'] = globalOrder;
            jsonMap[key] = enriched;
          }
          globalOrder++;
        }
      }

      final batch = db.batch();
      bool hasChanges = false;

      for (final entry in jsonMap.entries) {
        final key = entry.key;
        final item = entry.value;

        final String cat = item['category'].toString().trim();
        final String sub = item['subcategory']?.toString().trim() ?? '';
        final String text = item['text'].toString().trim();
        final int limit = item['count_limit'] is int
            ? item['count_limit'] as int
            : 1;
        final String virt = item['virtue']?.toString().trim() ?? '';
        final int sortOrder = item['_sort_order'] as int;

        if (!existingMap.containsKey(key)) {
          batch.insert('adhkar', {
            'category': cat,
            'subcategory': sub,
            'text': text,
            'count_limit': limit,
            'current_count': 0,
            'virtue': virt,
            'sort_order': sortOrder,
          });
          hasChanges = true;
        } else {
          final rows = existingMap[key]!;
          final existingRow = rows.first;
          final int existingLimit = existingRow['count_limit'] as int;
          final String existingVirt = existingRow['virtue'] as String;
          final int existingSortOrder =
              (existingRow['sort_order'] as int?) ?? -1;

          if (existingLimit != limit ||
              existingVirt != virt ||
              existingSortOrder != sortOrder) {
            batch.update(
              'adhkar',
              {'count_limit': limit, 'virtue': virt, 'sort_order': sortOrder},
              where: 'id = ?',
              whereArgs: [existingRow['id'] as int],
            );
            hasChanges = true;
          }

          for (int i = 1; i < rows.length; i++) {
            batch.delete(
              'adhkar',
              where: 'id = ?',
              whereArgs: [rows[i]['id'] as int],
            );
            hasChanges = true;
          }
        }
      }

      for (final entry in existingMap.entries) {
        if (!jsonMap.containsKey(entry.key)) {
          for (final row in entry.value) {
            batch.delete(
              'adhkar',
              where: 'id = ?',
              whereArgs: [row['id'] as int],
            );
            hasChanges = true;
          }
        }
      }

      if (hasChanges) {
        await batch.commit(noResult: true);
        safeLog('✅ تمت مزامنة البيانات بنجاح.');
      } else {
        safeLog('ℹ️ لا توجد تغييرات.');
      }

      return true;
    } catch (e) {
      safeLog('❌ خطأ أثناء المزامنة: $e');
      return false;
    }
  }

  // --- دوال الاستعلام ---

  static Future<List<Map<String, dynamic>>> getAdhkar({
    required String category,
    String? subcategory,
  }) async {
    final db = await database;
    return db.query(
      'adhkar',
      where: 'category = ? AND subcategory = ?',
      whereArgs: [category, subcategory?.trim() ?? ''],
      orderBy: 'sort_order ASC',
    );
  }

  static Future<void> updateCount(int id, int count) async {
    final db = await database;
    await db.update(
      'adhkar',
      {'current_count': count},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> resetCategoryProgress(
    String category, {
    String? subcategory,
  }) async {
    final db = await database;
    await db.update(
      'adhkar',
      {'current_count': 0},
      where: 'category = ? AND subcategory = ?',
      whereArgs: [category, subcategory?.trim() ?? ''],
    );
  }

  static Future<bool> isCategoryCompleted(
    String category, {
    String? subcategory,
  }) async {
    final db = await database;
    final res = await db.query(
      'adhkar',
      where: 'category = ? AND subcategory = ?',
      whereArgs: [category, subcategory?.trim() ?? ''],
    );
    if (res.isEmpty) return false;
    for (final item in res) {
      if ((item['current_count'] as int) < (item['count_limit'] as int)) {
        return false;
      }
    }
    return true;
  }

  @visibleForTesting
  static Future<void> resetForTesting() async {
    await _database?.close();
    _database = null;
    _initFuture = null;
  }
}
