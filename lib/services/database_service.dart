import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Central SQLite service for Campus Cart.
/// Tables:
///   - products        : offline product cache
///   - notifications   : persisted notification history
///   - orders_cache    : cached order history per user
///   - chat_messages   : support chat messages per session
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'campus_cart.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Products cache ────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE products (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        category    TEXT,
        price       TEXT,
        discount    TEXT,
        rating      REAL,
        image       TEXT,
        description TEXT,
        stock       INTEGER,
        seller_id   TEXT,
        store_id    TEXT,
        extra_json  TEXT,
        cached_at   INTEGER NOT NULL
      )
    ''');

    // ── Notifications ─────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE notifications (
        id         TEXT PRIMARY KEY,
        user_id    TEXT NOT NULL,
        title      TEXT NOT NULL,
        message    TEXT NOT NULL,
        type       TEXT,
        icon       TEXT,
        color      TEXT,
        is_read    INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // ── Orders cache ──────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE orders_cache (
        id               TEXT PRIMARY KEY,
        user_id          TEXT NOT NULL,
        status           TEXT,
        date             TEXT,
        total            TEXT,
        items            INTEGER,
        shipping_address TEXT,
        payment_method   TEXT,
        subtotal         REAL,
        delivery_fee     REAL,
        products_json    TEXT,
        cached_at        INTEGER NOT NULL
      )
    ''');

    // ── Chat messages ─────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE chat_messages (
        id          TEXT PRIMARY KEY,
        session_id  TEXT NOT NULL,
        user_id     TEXT NOT NULL,
        text        TEXT NOT NULL,
        is_support  INTEGER NOT NULL DEFAULT 0,
        agent_name  TEXT,
        time        TEXT,
        created_at  INTEGER NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_notifications_user ON notifications(user_id)');
    await db.execute('CREATE INDEX idx_orders_user ON orders_cache(user_id)');
    await db.execute('CREATE INDEX idx_chat_session ON chat_messages(session_id)');
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Cache a list of products. Upserts by id.
  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final p in products) {
      // Pull out known columns; everything else goes into extra_json
      final known = {'id', 'name', 'category', 'price', 'discount', 'rating',
          'image', 'description', 'stock', 'sellerId', 'storeId'};
      final extra = Map<String, dynamic>.from(p)
        ..removeWhere((k, _) => known.contains(k));
      batch.insert(
        'products',
        {
          'id':          p['id']?.toString() ?? p['name']?.toString() ?? '',
          'name':        p['name']?.toString() ?? '',
          'category':    p['category']?.toString() ?? '',
          'price':       p['price']?.toString() ?? '',
          'discount':    p['discount']?.toString() ?? '',
          'rating':      (p['rating'] as num?)?.toDouble() ?? 0.0,
          'image':       p['image']?.toString() ?? '',
          'description': p['description']?.toString() ?? '',
          'stock':       (p['stock'] as num?)?.toInt() ?? 0,
          'seller_id':   p['sellerId']?.toString() ?? '',
          'store_id':    p['storeId']?.toString() ?? '',
          'extra_json':  jsonEncode(extra),
          'cached_at':   now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Returns all cached products, optionally filtered by category.
  Future<List<Map<String, dynamic>>> getCachedProducts({String? category}) async {
    final db = await database;
    final rows = category != null && category != 'All'
        ? await db.query('products',
            where: 'category = ?', whereArgs: [category],
            orderBy: 'name ASC')
        : await db.query('products', orderBy: 'name ASC');
    return rows.map(_productFromRow).toList();
  }

  /// Returns true if the cache is fresh (within [maxAgeMinutes]).
  Future<bool> isProductCacheFresh({int maxAgeMinutes = 30}) async {
    final db = await database;
    final result = await db.rawQuery('SELECT MAX(cached_at) as ts FROM products');
    final ts = result.first['ts'] as int?;
    if (ts == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    return age < maxAgeMinutes * 60 * 1000;
  }

  Future<void> clearProductCache() async {
    final db = await database;
    await db.delete('products');
  }

  Map<String, dynamic> _productFromRow(Map<String, dynamic> row) {
    final extra = row['extra_json'] != null
        ? Map<String, dynamic>.from(jsonDecode(row['extra_json'] as String))
        : <String, dynamic>{};
    return {
      'id':          row['id'],
      'name':        row['name'],
      'category':    row['category'],
      'price':       row['price'],
      'discount':    row['discount'],
      'rating':      row['rating'],
      'image':       row['image'],
      'description': row['description'],
      'stock':       row['stock'],
      'sellerId':    row['seller_id'],
      'storeId':     row['store_id'],
      ...extra,
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> insertNotification(Map<String, dynamic> n, String userId) async {
    final db = await database;
    await db.insert(
      'notifications',
      {
        'id':         n['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id':    userId,
        'title':      n['title']?.toString() ?? '',
        'message':    n['message']?.toString() ?? '',
        'type':       n['type']?.toString() ?? '',
        'icon':       n['icon']?.toString() ?? '',
        'color':      n['color']?.toString() ?? '',
        'is_read':    (n['isRead'] == true) ? 1 : 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final db = await database;
    final rows = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => {
      'id':      r['id'],
      'title':   r['title'],
      'message': r['message'],
      'type':    r['type'],
      'icon':    r['icon'],
      'color':   r['color'],
      'isRead':  r['is_read'] == 1,
      'time':    _relativeTime(r['created_at'] as int),
    }).toList();
  }

  Future<void> markNotificationRead(String id) async {
    final db = await database;
    await db.update('notifications', {'is_read': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final db = await database;
    await db.update('notifications', {'is_read': 1},
        where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearNotifications(String userId) async {
    final db = await database;
    await db.delete('notifications', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM notifications WHERE user_id = ? AND is_read = 0',
        [userId]);
    return (result.first['cnt'] as int?) ?? 0;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ORDERS CACHE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> cacheOrders(List<Map<String, dynamic>> orders, String userId) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final o in orders) {
      batch.insert(
        'orders_cache',
        {
          'id':               o['id']?.toString() ?? '',
          'user_id':          userId,
          'status':           o['status']?.toString() ?? '',
          'date':             o['date']?.toString() ?? '',
          'total':            o['total']?.toString() ?? '',
          'items':            (o['items'] as num?)?.toInt() ?? 0,
          'shipping_address': o['shippingAddress']?.toString() ?? '',
          'payment_method':   o['paymentMethod']?.toString() ?? '',
          'subtotal':         (o['subtotal'] as num?)?.toDouble() ?? 0.0,
          'delivery_fee':     (o['deliveryFee'] as num?)?.toDouble() ?? 0.0,
          'products_json':    jsonEncode(o['products'] ?? []),
          'cached_at':        now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedOrders(String userId) async {
    final db = await database;
    final rows = await db.query(
      'orders_cache',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'cached_at DESC',
    );
    return rows.map((r) => {
      'id':              r['id'],
      'status':          r['status'],
      'date':            r['date'],
      'total':           r['total'],
      'items':           r['items'],
      'shippingAddress': r['shipping_address'],
      'paymentMethod':   r['payment_method'],
      'subtotal':        r['subtotal'],
      'deliveryFee':     r['delivery_fee'],
      'products':        jsonDecode(r['products_json'] as String? ?? '[]'),
    }).toList();
  }

  Future<void> clearOrdersCache(String userId) async {
    final db = await database;
    await db.delete('orders_cache', where: 'user_id = ?', whereArgs: [userId]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHAT MESSAGES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> saveChatMessage({
    required String sessionId,
    required String userId,
    required String text,
    required bool isSupport,
    String? agentName,
    String? time,
  }) async {
    final db = await database;
    await db.insert(
      'chat_messages',
      {
        'id':         '${sessionId}_${DateTime.now().millisecondsSinceEpoch}',
        'session_id': sessionId,
        'user_id':    userId,
        'text':       text,
        'is_support': isSupport ? 1 : 0,
        'agent_name': agentName ?? '',
        'time':       time ?? '',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String sessionId) async {
    final db = await database;
    final rows = await db.query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return rows.map((r) => {
      'text':      r['text'],
      'isSupport': r['is_support'] == 1,
      'agentName': r['agent_name'],
      'time':      r['time'],
    }).toList();
  }

  Future<void> clearChatSession(String sessionId) async {
    final db = await database;
    await db.delete('chat_messages',
        where: 'session_id = ?', whereArgs: [sessionId]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  String _relativeTime(int epochMs) {
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(epochMs));
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
