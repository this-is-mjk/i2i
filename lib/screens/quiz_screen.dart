import 'dart:math';

import 'package:flutter/material.dart';
import 'package:i2i/components/objects/questions.dart';
import 'package:i2i/components/quiz_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_results.dart';

const List<String> emotionOptions = [
  'Anger / ग़ुस्सा',
  'Sad / दुखी',
  'Happy / ख़ुशी',
  'Fear / डर',
  'Surprise / आश्चर्य',
  'Disgust / घृणा',
  'Neutral / सामान्य',
];

const emotionMap = {
  'A': 'Anger /  ग़ुस्सा',
  'H': 'Happy / ख़ुशी',
  'S': 'Sad / दुखी',
  'F': 'Fear / डर',
  'P': 'Surprise / आश्चर्य',
  'D': 'Disgust / घृणा',
  'N': 'Neutral / सामान्य',
};

const emotionDescriptions = {
  'Anger':
      'The person is showing signs of anger like clenched jaw and furrowed brows.',
  'Happy': 'Smiling and bright eyes are strong indicators of happiness.',
  'Sad': 'Tears and a downward gaze often signal sadness.',
  'Fear': 'Wide eyes and tense body language often signal fear.',
  'Surprise': 'Raised eyebrows and open mouth often suggest surprise.',
  'Disgust': 'A wrinkled nose and raised upper lip are signs of disgust.',
  'Neutral':
      'A relaxed expression with neutral features indicates a Neutral state.',
};

List<String> imageFiles = [
  'A11.jpg',
  'A13.jpg',
  'A15.jpg',
  'A16.jpg',
  'A2.jpg',
  'D10.jpg',
  'D11.jpg',
  'D14.jpg',
  'D4.jpg',
  'D7.jpg',
  'F1.jpg',
  'F14.jpg',
  'F15.jpg',
  'F2.jpg',
  'F6.jpg',
  'H1.jpg',
  'H11.jpg',
  'H14.jpg',
  'H18.jpg',
  'H7.jpg',
  'N1.jpg',
  'N12.jpg',
  'N19.jpg',
  'N7.jpg',
  'N9.jpg',
  'P1.jpg',
  'P10.jpg',
  'P12.jpg',
  'P14.jpg',
  'P6.jpg',
  'S16.jpg',
  'S18.jpg',
  'S5.jpg',
  'S6.jpg',
  'S9.jpg',
];

List<String> decideOptions(String correctOption, int level) {
  List<String> options = [correctOption];
  List<String> wrongOptions = List.from(emotionOptions)..remove(correctOption);

  if (level == 1) {
    options.add(wrongOptions[Random().nextInt(wrongOptions.length)]);
  } else if (level == 2) {
    wrongOptions.shuffle();
    options.addAll(wrongOptions.take(3));
  } else if (level == 3) {
    options.addAll(wrongOptions);
  }
  options.shuffle();
  return options;
}

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
      imageId: "assets/BaselineImages/$imageFile",
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
              padding: EdgeInsets.only(right: 15.0, top: 0.0, bottom: 2.0),
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
                      builder: (context) => ResultPage(questions: questions),
                    ),
                  );
                },
                child: Text(
                  "End Test",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
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
            final questions = snapshot.data!;
            return QuizPages(questions: snapshot.data!);
          } else {
            return const Center(child: Text('No questions available.'));
          }
        },
      ),
    );
  }
}
