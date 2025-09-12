import 'dart:math';

import 'package:flutter/material.dart';
import 'package:i2i/utils/objects/questions.dart';
import 'package:i2i/utils/question_helper.dart';
import 'package:i2i/utils/quiz_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_results.dart';

Future<List<Question>> decideQuestions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int level = prefs.getInt("level") ?? 1;
  int total = prefs.getInt("baselineQuestionNumber") ?? 5;

  imageFiles.shuffle(Random());

  final selectedImages = imageFiles.take(total).toList();

  return selectedImages.map((imageFile) {
    final emotionKey = imageFile[0];
    final emotion = emotionMap[emotionKey] ?? 'Unknown';
    final description =
        emotionDescriptions[emotion] ?? 'No description available';

    return Question(
      questionString: "Identify the emotion? / भावना पहचानें?",
      imageId: imageFile,
      correctAnswer: emotion,
      options: decideOptions(emotion, level),
      answerDescription: description,
    );
  }).toList();
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = decideQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn / सीखें'),
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 5, 3),
            child: Padding(
              padding: EdgeInsets.only(right: 5.0, top: 0.0, bottom: 2.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.white,
                ),
                onPressed: () async {
                  final questions = await _questions;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ResultPage(questions: questions, test: true),
                    ),
                  );
                },
                child: Text(
                  "End",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // final questions = snapshot.data!;
            return QuizPages(questions: snapshot.data!);
          } else {
            return const Center(child: Text('No questions available.'));
          }
        },
      ),
    );
  }
}
