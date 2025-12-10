import 'package:iamhere/common/database/local_database_exception.dart';
import 'package:iamhere/contact/repository/contact_entity.dart';
import 'package:iamhere/geofence/repository/geofence_entity.dart';
import 'package:iamhere/record/repository/geofence_record_entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  // ========== Constants & Singleton ==========
  static const double defaultRadius = 300.0;
  static const String defaultMessage = '';
  static const String defaultContactIds = '[]';
  static const int defaultIsActive = 0;
  static const String defaultSendMachine = 'mobile';

  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  static const String databaseName = "im_here.db";
  static const String contactTableName = 'contacts';
  static const String geofenceTableName = 'geofence';
  static const String recordTableName = 'records';

  LocalDatabaseService._init();

  // ========== Database Initialization ==========

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  String _createContactsTableQuery() {
    return 'CREATE TABLE $contactTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, number TEXT)';
  }

  String _createGeofenceTableQuery() {
    return 'CREATE TABLE $geofenceTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lat REAL, lng REAL, radius REAL, message TEXT, contact_ids TEXT, is_active INTEGER DEFAULT 0)';
  }

  String _createRecordsTableQuery() {
    return 'CREATE TABLE $recordTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, geofence_id INTEGER, geofence_name TEXT, message TEXT, recipients TEXT, created_at TEXT, send_machine TEXT)';
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);

    String contactTableQuery = _createContactsTableQuery();
    String geofenceTableQuery = _createGeofenceTableQuery();
    String recordsTableQuery = _createRecordsTableQuery();

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(contactTableQuery);
        await db.execute(geofenceTableQuery);
        await db.execute(recordsTableQuery);
      },
    );
  }

  // ========== Common Helper Methods ==========

  /// Generic insert operation with error handling
  Future<T> _executeInsert<T>({
    required String entityName,
    required String table,
    required Map<String, dynamic> values,
    required T Function(int id) createEntity,
    String? entityDetails,
  }) async {
    try {
      var db = await instance.database;
      final id = await db.insert(
        table,
        values,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return createEntity(id);
    } catch (e) {
      throw LocalDatabaseException(
        'Failed to save $entityName',
        details: entityDetails,
        originalError: e,
      );
    }
  }

  /// Generic update operation with validation and error handling
  Future<int> _executeUpdate({
    required String entityName,
    required int? entityId,
    required String table,
    required Map<String, dynamic> values,
    String? entityDetails,
  }) async {
    if (entityId == null) {
      throw LocalDatabaseException(
        'Cannot update $entityName without ID',
        details: entityDetails,
      );
    }

    try {
      var db = await instance.database;
      final count = await db.update(
        table,
        values,
        where: 'id = ?',
        whereArgs: [entityId],
      );

      if (count == 0) {
        throw LocalDatabaseException(
          '$entityName not found',
          details: 'ID: $entityId',
        );
      }

      return count;
    } catch (e) {
      if (e is LocalDatabaseException) rethrow;
      throw LocalDatabaseException(
        'Failed to update $entityName',
        details: entityDetails ?? 'ID: $entityId',
        originalError: e,
      );
    }
  }

  /// Generic query operation with mapping and error handling
  Future<List<T>> _executeQuery<T>({
    required String entityName,
    required String table,
    required T Function(Map<String, dynamic>) fromMap,
    String? orderBy,
  }) async {
    try {
      var db = await instance.database;
      final result = await db.query(table, orderBy: orderBy);
      return result.map((json) => fromMap(json)).toList();
    } catch (e) {
      throw LocalDatabaseException(
        'Failed to fetch ${entityName}s',
        originalError: e,
      );
    }
  }

  /// Generic delete operation with error handling
  Future<void> _executeDelete({
    required String entityName,
    required String table,
    int? id,
    String? additionalDetails,
  }) async {
    try {
      var db = await instance.database;
      if (id != null) {
        await db.delete(table, where: 'id = ?', whereArgs: [id]);
      } else {
        await db.delete(table);
      }
    } catch (e) {
      final details = id != null ? 'ID: $id' : additionalDetails;
      throw LocalDatabaseException(
        'Failed to delete $entityName',
        details: details,
        originalError: e,
      );
    }
  }

  // ========== Contact Operations ==========

  Future<ContactEntity> saveContact(ContactEntity entity) async {
    return await _executeInsert(
      entityName: 'contact',
      table: contactTableName,
      values: entity.toMap(),
      createEntity: (id) => entity.copyWith(id: id),
      entityDetails: 'Contact: ${entity.name}',
    );
  }

  Future<int> updateContact(ContactEntity entity) async {
    return await _executeUpdate(
      entityName: 'Contact',
      entityId: entity.id,
      table: contactTableName,
      values: entity.toMap(),
      entityDetails: 'Contact: ${entity.name}',
    );
  }

  Future<List<ContactEntity>> findAllContacts() async {
    return await _executeQuery(
      entityName: 'contact',
      table: contactTableName,
      fromMap: ContactEntity.fromMap,
      orderBy: 'name ASC',
    );
  }

  Future<void> deleteContact(int id) async {
    return await _executeDelete(
      entityName: 'contact',
      table: contactTableName,
      id: id,
    );
  }

  // ========== Geofence Operations ==========

  Future<GeofenceEntity> saveGeofence(GeofenceEntity entity) async {
    return await _executeInsert(
      entityName: 'geofence',
      table: geofenceTableName,
      values: entity.toMap(),
      createEntity: (id) => entity.copyWith(id: id),
      entityDetails: 'Geofence: ${entity.name}',
    );
  }

  Future<int> updateGeofence(GeofenceEntity entity) async {
    return await _executeUpdate(
      entityName: 'Geofence',
      entityId: entity.id,
      table: geofenceTableName,
      values: entity.toMap(),
      entityDetails: 'Geofence: ${entity.name}',
    );
  }

  Future<List<GeofenceEntity>> findAllGeofences() async {
    return await _executeQuery(
      entityName: 'geofence',
      table: geofenceTableName,
      fromMap: GeofenceEntity.fromMap,
      orderBy: 'name ASC',
    );
  }

  Future<void> deleteGeofence(int id) async {
    return await _executeDelete(
      entityName: 'geofence',
      table: geofenceTableName,
      id: id,
    );
  }

  Future<void> updateGeofenceActiveStatus(int id, bool isActive) async {
    try {
      var db = await instance.database;
      await db.update(
        geofenceTableName,
        {'is_active': isActive ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException(
        'Failed to update geofence active status',
        details: 'ID: $id, isActive: $isActive',
        originalError: e,
      );
    }
  }

  // ========== GeofenceRecord Operations ==========

  Future<GeofenceRecordEntity> saveGeofenceRecord(
    GeofenceRecordEntity entity,
  ) async {
    return await _executeInsert(
      entityName: 'geofence record',
      table: recordTableName,
      values: entity.toMap(),
      createEntity: (id) => entity.copyWith(id: id),
      entityDetails: 'Geofence: ${entity.geofenceName}',
    );
  }

  Future<int> updateGeofenceRecord(GeofenceRecordEntity entity) async {
    return await _executeUpdate(
      entityName: 'Geofence record',
      entityId: entity.id,
      table: recordTableName,
      values: entity.toMap(),
      entityDetails: 'Geofence: ${entity.geofenceName}',
    );
  }

  Future<List<GeofenceRecordEntity>> findAllGeofenceRecords() async {
    return await _executeQuery(
      entityName: 'geofence record',
      table: recordTableName,
      fromMap: GeofenceRecordEntity.fromMap,
      orderBy: 'created_at DESC',
    );
  }

  Future<void> deleteGeofenceRecord(int id) async {
    return await _executeDelete(
      entityName: 'geofence record',
      table: recordTableName,
      id: id,
    );
  }

  Future<void> deleteAllGeofenceRecords() async {
    return await _executeDelete(
      entityName: 'all geofence records',
      table: recordTableName,
      additionalDetails: 'Deleting all records',
    );
  }
}
