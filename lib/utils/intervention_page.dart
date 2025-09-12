import 'package:flutter/material.dart';
import 'package:i2i/utils/animate_question_image.dart';
import 'package:i2i/utils/common_button.dart';
import 'package:i2i/utils/objects/questions.dart';
import 'package:i2i/screens/quiz_results.dart';

class CelebrationDialog extends StatelessWidget {
  final bool isCorrect;
  const CelebrationDialog({super.key, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isCorrect ? "Correct!" : "Wrong"),
      content: Icon(
        isCorrect ? Icons.celebration : Icons.cancel,
        size: 64,
        color: isCorrect ? Colors.green : Colors.red,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    );
  }
}

class CorrectAnswerDialog extends StatelessWidget {
  final String correctAnswer;
  const CorrectAnswerDialog({super.key, required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Correct Answer"),
      content: Text(
        correctAnswer,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Got it"),
        ),
      ],
    );
  }
}

class InterventionPage extends StatefulWidget {
  final List<Question> questions;

  const InterventionPage({super.key, required this.questions});

  @override
  State<InterventionPage> createState() => _InterventionPageState();
}

class _InterventionPageState extends State<InterventionPage> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _answerQuestion(String selectedAnswer, int index) async {
    final question = widget.questions[index];
    final isCorrect = selectedAnswer == question.correctAnswer;

    setState(() {
      question.answered = selectedAnswer;
    });

    // Show correct/incorrect dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CelebrationDialog(isCorrect: isCorrect),
    );

    // If wrong → also show correct answer
    if (!isCorrect) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) =>
                CorrectAnswerDialog(correctAnswer: question.correctAnswer),
      );
    }

    // Short delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Move to next or results
    if (_currentPageIndex < widget.questions.length - 1) {
      _goToPage(_currentPageIndex + 1);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => ResultPage(questions: widget.questions, test: false),
        ),
      );
    }
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // disable swipe
      itemCount: widget.questions.length,
      itemBuilder: (context, index) {
        final question = widget.questions[index];
        final textTheme = Theme.of(context).textTheme;
        final isMobile = MediaQuery.of(context).size.width < 600;

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Question ${index + 1}/${widget.questions.length}",
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Question text
              Text(
                question.questionString,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Options
              Expanded(
                child:
                    isMobile
                        ? _buildMobileOptions(question, textTheme)
                        : _buildDesktopOptions(question, textTheme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileOptions(Question question, TextTheme textTheme) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        return Column(
          children: [
            Expanded(
              flex: 4,
              child: PatternAnimatedImage(
                id: question.imageId, // your Question should have an ID field
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CommonButton(
                text: option,
                isOutlined: true,
                onPressed: () => _answerQuestion(option, _currentPageIndex),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopOptions(Question question, TextTheme textTheme) {
    final bool isFour = question.options.length == 4 || question.options.length == 2;
    return Center(
      child: SizedBox(
        width: 800,
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: PatternAnimatedImage(
                id: question.imageId, // your Question should have an ID field
              ),
            ),
            const SizedBox(height: 5.0),
            Expanded(
              flex: 1,
              child:
                  question.options.isEmpty
                      ? Center(
                        child: Text(
                          question.correctAnswer,
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                      : Center(
                        child: SizedBox(
                          width: 850,
                          child: Center(
                            child: GridView.builder(
                              itemCount: question.options.length,

                              // shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isFour ? 2 : 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 8.0,
                                  ),
                              itemBuilder: (context, index) {
                                final option = question.options[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: CommonButton(
                                        onPressed:
                                            () => _answerQuestion(
                                              option,
                                              _currentPageIndex,
                                            ),
                                        text: option,
                                        isOutlined: true,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
