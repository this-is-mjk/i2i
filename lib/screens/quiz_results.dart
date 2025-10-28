import 'package:flutter/material.dart';
import 'package:i2i/utils/common_button.dart';
import 'package:i2i/utils/objects/questions.dart';
import 'package:i2i/database/result.dart';
import 'package:i2i/database/result_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class ResultPage extends StatefulWidget {
  final List<Question> questions;
  final bool test;

  const ResultPage({super.key, required this.questions, required this.test});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int correctAnswers = 0;
  int totalTime = 0;
  int maxTime = 0;
  double avgCorrectTime = 0.0;
  bool isSaving = true;

  @override
  void initState() {
    super.initState();
    _processResults();
  }

  Future<void> _processResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString("userName");
    String? userId = prefs.getString("userId");
    int? level = prefs.getInt("level");

    correctAnswers = widget.questions.where((q) => q.isAnswerCorrect()).length;

    if (widget.test) {
      totalTime = widget.questions.fold(
        0,
        (sum, q) => sum + q.timeTakenInSeconds,
      );
      maxTime = widget.questions
          .map((q) => q.timeTakenInSeconds)
          .reduce((a, b) => a > b ? a : b);

      final correctQuestions =
          widget.questions.where((q) => q.isAnswerCorrect()).toList();
      if (correctQuestions.isNotEmpty) {
        avgCorrectTime =
            correctQuestions.fold(0, (sum, q) => sum + q.timeTakenInSeconds) /
            correctQuestions.length;
      }
    }
    await _saveResultsToDatabase(
      widget.test ? "test" : "intervention",
      userId ?? "unknown",
      userName ?? "Guest",
      level ?? 1,
    );
    setState(() {
      isSaving = false;
    });
  }

  Future<void> _saveResultsToDatabase(
    String type,
    String userId,
    String userName,
    int level,
  ) async {
    final databaseDir = await getApplicationSupportDirectory();
    databaseDir.create(recursive: true);
    final resultDatabaseFileName = join(
      databaseDir.path,
      'baseline_results.db',
    );

    // ########################
    final database =
        await $FloorAppDatabase.databaseBuilder(resultDatabaseFileName).build();

    final resultDao = database.resultDao;

    // final results = await resultDao.findResultById(1);
    // ########################

    for (var q in widget.questions) {
      final result = Result(
        userId,
        type,
        userName,
        q.answered ?? "",
        q.correctAnswer,
        level,
        q.isAnswerCorrect() ? 1 : 0,
        q.timeTakenInSeconds,
      );

      await resultDao.insertResult(result);
    }
  }

  Container resultText(
    double topMargin,
    String title,
    double fontSize,
    FontWeight fontWeight,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white, // Bright white text
          shadows: [
            Shadow(
              color: Colors.white.withValues(alpha: .4),
              offset: Offset(0, 1),
              blurRadius: 4,
            ),
            Shadow(
              color: Colors.white.withValues(alpha: .2),
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (isSaving) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Result")),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/congratulations.png'),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 90),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey.shade400,
                      child: const CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  resultText(
                    10,
                    widget.test ? "Congratulations" : "Session Finished!",
                    28,
                    FontWeight.w300,
                    Colors.black.withValues(alpha: 0.8),
                  ),
                  resultText(
                    5,
                    "Your Score :",
                    18,
                    FontWeight.w300,
                    Colors.grey.shade600,
                  ),
                  Image.asset('assets/images/badge.png', width: 80),
                  resultText(
                    30,
                    '$correctAnswers / ${widget.questions.length}',
                    22,
                    FontWeight.w600,
                    Colors.grey.shade600,
                  ),
                  Container(
                    width: size.width * .7 < 300 ? size.width * .7 : 300,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent),
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: correctAnswers / widget.questions.length,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ),
                  ),
                  if (widget.test) ...[
                    resultText(
                      30,
                      'Total Time: ${totalTime / 1000}s',
                      22,
                      FontWeight.w600,
                      Colors.grey.shade600,
                    ),
                    resultText(
                      30,
                      "Avg Time (Correct) ${(avgCorrectTime / 1000).toStringAsFixed(2)}s",
                      18,
                      FontWeight.w600,
                      Colors.grey.shade600,
                    ),
                    resultText(
                      30,
                      'Max Time on a Question: ${maxTime / 1000}s',
                      18,
                      FontWeight.w600,
                      Colors.grey.shade600,
                    ),
                  ],
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),

                    child: CommonButton(
                      width: 300,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: "Continue",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
