import 'package:floor/floor.dart';
import 'package:i2i/database/result.dart';

@dao
abstract class ResultDao {
  @Query('SELECT * FROM results')
  Future<List<Result>> findAllResults();

  @Query('SELECT * FROM results WHERE id = :id')
  Stream<Result?> findResultById(int id);

  @insert
  Future<void> insertResult(Result Result);
}