import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Specify the database name
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'hedieaty.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone_number TEXT NOT NULL,
        profile_picture TEXT,
        notificationsEnabled INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT NOT NULL,
        category TEXT NOT NULL,
        userId INTEGER NOT NULL,
        status TEXT NOT NULL,
        published TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES Users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        eventId INTEGER NOT NULL,
        imageUrl TEXT,
        ownerId TEXT NOT NULL,
        FOREIGN KEY (eventId) REFERENCES Events (id) ON DELETE CASCADE
        FOREIGN KEY (ownerId) REFERENCES Users (id)
      )
    ''');
  }

  // CRUD Operations for Users
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('Users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('Users');
  }

  Future<int> updateUser(String id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update('Users', user, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('Users', where: 'id = ?', whereArgs: [id]);
  }

    Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    final result = await db.query('Users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // CRUD Operations for Events
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('Events', event, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await database;
    return await db.query('Events');
  }

  Future<void> updateEvent(Event event) async {
    final db = await database;
    final eventMap = event.toMap();
    final eventId = event.eventId;
   await db.update('Events', eventMap, where: 'id = ?', whereArgs: [eventId]);
  }

  Future<void> deleteEvent(String id) async {
    final db = await database;
    await db.delete('Events', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operations for Gifts
  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('Gifts', gift, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getGifts() async {
    final db = await database;
    return await db.query('Gifts');
  }

  Future<int> updateGift(gift) async {
    final db = await database;
    final giftMap = gift.toMap();
    final giftId = gift.giftId;
    return await db.update('Gifts', giftMap, where: 'id = ?', whereArgs: [giftId]);
  }

  Future<int> deleteGift(String id) async {
    final db = await database;
    return await db.delete('Gifts', where: 'id = ?', whereArgs: [id]);
  }

  // Get Events for a Specific User
  Future<List<Event>> getEventsByUserId(String userId) async {
    final db = await database;
    final result = await db.query('Events', where: 'userId = ?', whereArgs: [userId]);

    // Convert the query result to a list of Event objects
    final events = result.map((e) => Event.fromMap(e)).toList();
    return events;
  }

  Future<List<Gift>> getGiftsByEventId(String eventId) async {
    final db = await database;
    final result = await db.query('Gifts', where: 'eventId = ?', whereArgs: [eventId]);
    final gifts = result.map((e) =>Gift.fromMap(e)).toList();
    return gifts;
  }

Future<Event?> getEvent(String id) async {
  try {
    final db = await database;
    // Query the local database to fetch the event by ID
    final List<Map<String, dynamic>> maps = await db.query(
      'Events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      // If the event is found, create and return an Event object
      return Event.fromMap(maps.first);
    }
  } catch (e) {
    print('Error fetching event: $e');
  }
  return null;
}

Future<Map<String, dynamic>?> getGiftById(String giftId) async {
  try {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Gifts', 
      where: 'id = ?',
      whereArgs: [giftId],
    );

    if (maps.isNotEmpty) {
      final gift = maps.first;
      return {
        'id': gift['id'], 
        'name': gift['name'],
        'description': gift['description'],
        'category': gift['category'],
        'status': gift['status'],
        'price': gift['price'],
        'eventId' : gift['eventId'],
        'imageUrl' : gift['image_url'],
        'ownerId' :gift['ownerId'],
      };
    }
  } catch (e) {
    print('Error fetching gift: $e');
  }
  return null; // Return null if the gift isn't found
}

  Future<void> updateEventStatus(String eventId, String status) async {
    final db = await database;
    await db.update(
      'Events', 
      {'status': status}, 
      where: 'id = ?', 
      whereArgs: [eventId], 
    );
  }

  Future<void> updateGiftStatus(String giftId,String status) async{
    final db = await database;
    await db.update('Gifts', {'status': status}, 
      where: 'id = ?', 
      whereArgs: [giftId],);
  }

  
}
