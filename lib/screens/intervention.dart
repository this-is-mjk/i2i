import 'dart:math';

import 'package:flutter/material.dart';
import 'package:i2i/database/result_database.dart';
import 'package:i2i/utils/intervention_page.dart';
import 'package:i2i/utils/objects/questions.dart';
import 'package:i2i/utils/question_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_results.dart';

Future<Map<String, double>> _buildErrorDistribution() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString("userId");

  if (userId == null || userId == "") {
    // No personalization possible
    return {};
  }

  final databaseDir = await getApplicationSupportDirectory();
  final resultDatabaseFileName = join(databaseDir.path, 'baseline_results.db');
  final database =
      await $FloorAppDatabase.databaseBuilder(resultDatabaseFileName).build();
  final resultDao = database.resultDao;

  final wrongResults = await resultDao.findWrongResultsForUser(userId);

  if (wrongResults.isEmpty) return {};

  // Count mistakes per emotion
  final Map<String, int> counts = {};
  for (var r in wrongResults) {
    final key = r.correctAnswer; // or r.correctAnswer[0] if char is your key
    counts[key] = (counts[key] ?? 0) + 1;
  }
  // Convert to probability distribution
  final total = counts.values.fold<int>(0, (a, b) => a + b);
  return counts.map((k, v) => MapEntry(k, v / total));
}

Future<List<Question>> decideQuestions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int level = prefs.getInt("level") ?? 1;
  int total = prefs.getInt("baselineQuestionNumber") ?? 5;

  final probs = await _buildErrorDistribution();

  // fallback if no history
  if (probs.isEmpty) {
    InterventionImageFiles.shuffle(Random());
    final selected = InterventionImageFiles.take(total).toList();
    return _buildQuestions(selected, level);
  }
  // Weighted selection
  final rand = Random();
  List<String> selectedImages = [];
  for (int i = 0; i < total; i++) {
    final chosenEmotion = _weightedRandom(probs, rand);
    final pool =
        InterventionImageFiles.where(
          (f) => emotionMap[f[0]] == chosenEmotion,
        ).toList();

    if (pool.isEmpty) {
      // fallback random if no images for that emotion
      pool.addAll(InterventionImageFiles);
    }
    pool.shuffle(rand);
    selectedImages.add(pool.first);
  }

  return _buildQuestions(selectedImages, level);
}

String _weightedRandom(Map<String, double> probs, Random rand) {
  double roll = rand.nextDouble();
  double cumulative = 0.0;
  for (var entry in probs.entries) {
    cumulative += entry.value;
    if (roll <= cumulative) return entry.key;
  }
  return probs.keys.first; // fallback
}

List<Question> _buildQuestions(List<String> imageFiles, int level) {
  return imageFiles.map((imageFile) {
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

class Intervention extends StatefulWidget {
  const Intervention({super.key});

  @override
  State<Intervention> createState() => _InterventionState();
}

class _InterventionState extends State<Intervention> {
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
        title: const Text('Intervention', style: TextStyle(fontSize: 20)),
        centerTitle: false,
        actions: [
          Container(
            child: Padding(
              padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
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
                              ResultPage(questions: questions, test: false),
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
            return InterventionPage(questions: snapshot.data!);
          } else {
            return const Center(child: Text('No questions available.'));
          }
        },
      ),
    );
  }
}
