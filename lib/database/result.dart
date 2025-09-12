import 'package:floor/floor.dart';


/// This is a table declaration
@Entity(tableName: "results")
class Result {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String userId;
  final String userName;
  final String answered;
  final String correctAnswer;
  final int level;
  final int isCorrect;
  final int timeTaken;

  Result(
    this.userId,
    this.userName,
    this.answered,
    this.correctAnswer,
    this.level,
    this.isCorrect,
    this.timeTaken, {
    this.id,
  });
}

