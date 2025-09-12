import 'package:floor/floor.dart';
import 'package:i2i/database/result.dart';

@dao
abstract class ResultDao {
  @Query('SELECT * FROM results')
  Future<List<Result>> findAllResults();

  @Query('SELECT * FROM results WHERE userId = :userId')
  Future<List<Result>> findAllResultsForUser(String userId);

  @Query('SELECT * FROM results WHERE isCorrect = 0 AND userId = :userId')
  Future<List<Result>> findWrongResultsForUser(String userId);

  @Query('DELETE FROM results WHERE userId = :userId')
  Future<void> deleteAllResultsForUser(String userId);

  @Query('DELETE FROM results')
  Future<void> deleteAllResults();
  @insert
  Future<void> insertResult(Result result);
}
