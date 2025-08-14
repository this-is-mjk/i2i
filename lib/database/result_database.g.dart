// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ResultDao? _resultDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `results` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` TEXT NOT NULL, `userName` TEXT NOT NULL, `answered` TEXT NOT NULL, `correctAnswer` TEXT NOT NULL, `level` INTEGER NOT NULL, `isCorrect` INTEGER NOT NULL, `timeTaken` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ResultDao get resultDao {
    return _resultDaoInstance ??= _$ResultDao(database, changeListener);
  }
}

class _$ResultDao extends ResultDao {
  _$ResultDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _resultInsertionAdapter = InsertionAdapter(
            database,
            'results',
            (Result item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'userName': item.userName,
                  'answered': item.answered,
                  'correctAnswer': item.correctAnswer,
                  'level': item.level,
                  'isCorrect': item.isCorrect,
                  'timeTaken': item.timeTaken
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Result> _resultInsertionAdapter;

  @override
  Future<List<Result>> findAllResults() async {
    return _queryAdapter.queryList('SELECT * FROM results',
        mapper: (Map<String, Object?> row) => Result(
            row['userId'] as String,
            row['userName'] as String,
            row['answered'] as String,
            row['correctAnswer'] as String,
            row['level'] as int,
            row['isCorrect'] as int,
            row['timeTaken'] as int,
            id: row['id'] as int?));
  }

  @override
  Stream<Result?> findResultById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM results WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Result(
            row['userId'] as String,
            row['userName'] as String,
            row['answered'] as String,
            row['correctAnswer'] as String,
            row['level'] as int,
            row['isCorrect'] as int,
            row['timeTaken'] as int,
            id: row['id'] as int?),
        arguments: [id],
        queryableName: 'results',
        isView: false);
  }

  @override
  Future<void> insertResult(Result Result) async {
    await _resultInsertionAdapter.insert(Result, OnConflictStrategy.abort);
  }
}
