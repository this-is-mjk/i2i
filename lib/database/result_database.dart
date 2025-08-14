import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:i2i/database/result.dart';
import 'package:i2i/database/result_dao.dart';

part 'result_database.g.dart';

@Database(version: 1, entities: [Result])
abstract class AppDatabase extends FloorDatabase {
  ResultDao get resultDao;
}