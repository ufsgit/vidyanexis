import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vidyanexis/constants/location_tracking_constants.dart';
import 'package:vidyanexis/model/location/location_point.dart';

/// Database helper singleton providing persistent SQLite operations for offline-first location storage.
class LocationDatabaseHelper {
  static final LocationDatabaseHelper _instance = LocationDatabaseHelper._internal();
  factory LocationDatabaseHelper() => _instance;
  LocationDatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, LocationTrackingConstants.databaseName);

    LocationTrackingConstants.log('Initializing SQLite database at $path');

    return await openDatabase(
      path,
      version: LocationTrackingConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    LocationTrackingConstants.log('Creating SQLite table: ${LocationTrackingConstants.tableNameLocations}');
    await db.execute('''
      CREATE TABLE ${LocationTrackingConstants.tableNameLocations} (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        tracking_session_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        altitude REAL,
        speed REAL,
        heading REAL,
        timestamp TEXT NOT NULL,
        battery_level INTEGER,
        is_synced INTEGER DEFAULT 0,
        retry_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Indexes for fast querying of unsynced points and session points
    await db.execute('''
      CREATE INDEX idx_locations_synced 
      ON ${LocationTrackingConstants.tableNameLocations} (is_synced, created_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_locations_session 
      ON ${LocationTrackingConstants.tableNameLocations} (tracking_session_id)
    ''');
  }

  /// Inserts a new captured location into the local database (offline-first).
  Future<int> insertLocation(LocationPoint location) async {
    try {
      final db = await database;
      final rowCount = await db.insert(
        LocationTrackingConstants.tableNameLocations,
        location.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LocationTrackingConstants.log('Saved locally: ${location.id} (lat: ${location.latitude}, lng: ${location.longitude})');
      return rowCount;
    } catch (e) {
      LocationTrackingConstants.log('Error inserting location ${location.id}: $e');
      return -1;
    }
  }

  /// Retrieves up to [limit] unsynced location records ordered by creation time.
  Future<List<LocationPoint>> getPendingLocations({int limit = LocationTrackingConstants.batchUploadSize}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        LocationTrackingConstants.tableNameLocations,
        where: 'is_synced = 0 AND retry_count < ?',
        whereArgs: [LocationTrackingConstants.maxRetryCount],
        orderBy: 'created_at ASC',
        limit: limit,
      );

      return maps.map((map) => LocationPoint.fromMap(map)).toList();
    } catch (e) {
      LocationTrackingConstants.log('Error fetching pending locations: $e');
      return [];
    }
  }

  /// Returns total count of unsynced location records.
  Future<int> getPendingLocationCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${LocationTrackingConstants.tableNameLocations} WHERE is_synced = 0',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      return count;
    } catch (e) {
      LocationTrackingConstants.log('Error getting pending location count: $e');
      return 0;
    }
  }

  /// Marks a list of accepted location IDs as synchronized.
  Future<int> markLocationsAsSynced(List<String> ids) async {
    if (ids.isEmpty) return 0;
    try {
      final db = await database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final updatedRows = await db.rawUpdate(
        'UPDATE ${LocationTrackingConstants.tableNameLocations} SET is_synced = 1 WHERE id IN ($placeholders)',
        ids,
      );
      LocationTrackingConstants.log('Marked $updatedRows records as synced');
      return updatedRows;
    } catch (e) {
      LocationTrackingConstants.log('Error marking locations as synced: $e');
      return 0;
    }
  }

  /// Increments the retry count for records whose upload failed.
  Future<void> incrementRetryCount(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final db = await database;
      final placeholders = List.filled(ids.length, '?').join(',');
      await db.rawUpdate(
        'UPDATE ${LocationTrackingConstants.tableNameLocations} SET retry_count = retry_count + 1 WHERE id IN ($placeholders)',
        ids,
      );
      LocationTrackingConstants.log('Incremented retry count for ${ids.length} locations');
    } catch (e) {
      LocationTrackingConstants.log('Error incrementing retry count: $e');
    }
  }

  /// Retrieves the most recent location point saved in the database.
  Future<LocationPoint?> getLatestLocation() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        LocationTrackingConstants.tableNameLocations,
        orderBy: 'created_at DESC',
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return LocationPoint.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      LocationTrackingConstants.log('Error getting latest location: $e');
      return null;
    }
  }

  /// Deletes old synced location points to preserve device storage.
  Future<int> deleteSyncedLocations({Duration? olderThan}) async {
    try {
      final db = await database;
      final cutoff = DateTime.now().toUtc().subtract(olderThan ?? LocationTrackingConstants.syncedDataRetention);
      final deleted = await db.delete(
        LocationTrackingConstants.tableNameLocations,
        where: 'is_synced = 1 AND created_at < ?',
        whereArgs: [cutoff.toIso8601String()],
      );
      if (deleted > 0) {
        LocationTrackingConstants.log('Purged $deleted old synced location records');
      }
      return deleted;
    } catch (e) {
      LocationTrackingConstants.log('Error purging old synced locations: $e');
      return 0;
    }
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
