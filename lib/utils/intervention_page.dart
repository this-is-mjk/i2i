import 'package:flutter/material.dart';
import 'package:i2i/utils/animate_question_image.dart';
import 'package:i2i/utils/common_button.dart';
import 'package:i2i/utils/objects/questions.dart';
import 'package:i2i/screens/quiz_results.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Mobile view UI correction
class InterventionPage extends StatefulWidget {
  final List<Question> questions;

  const InterventionPage({super.key, required this.questions});

  @override
  State<InterventionPage> createState() => _InterventionPageState();
}

class _InterventionPageState extends State<InterventionPage> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  late DateTime _startTime;
  String? _selectedAnswer;
  bool _answered = false;
  double _feedbackDelay = 2.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTime = DateTime.now();
    _loadFeedbackDelay();
  }

  Future<void> _loadFeedbackDelay() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _feedbackDelay = prefs.getDouble('feedbackDelayTime') ?? 2.0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _answerQuestion(
    String selectedAnswer,
    int index,
    bool isMobile,
  ) async {
    if (_answered) return;

    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    final question = widget.questions[index];
    question.timeTakenInSeconds = elapsed;

    setState(() {
      question.answered = selectedAnswer;
      _selectedAnswer = selectedAnswer;
      _answered = true;
    });

    await Future.delayed(Duration(milliseconds: (_feedbackDelay * 1000).round()));

    if (!mounted) return; // else if i hit end, it can cause error

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
      _answered = false;
      _selectedAnswer = null;
    });
    _startTime = DateTime.now();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Number, text
              // Text(
              //   "Question ${index + 1}/${widget.questions.length}",
              //   style: textTheme.titleLarge,
              // ),
              // const SizedBox(height: 16),

              // Question text
              Text(
                question.questionString,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.left,
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
              child: PatternAnimatedImage(id: question.imageId),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CommonButton(
                text: option,
                isOutlined: true,
                onPressed:
                    _answered
                        ? null
                        : () =>
                            _answerQuestion(option, _currentPageIndex, true),
                color: _getButtonColor(option, question.correctAnswer),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopOptions(Question question, TextTheme textTheme) {
    final bool isFour =
        question.options.length == 4 || question.options.length == 2;
    return Center(
      child: SizedBox(
        width: 800,
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: PatternAnimatedImage(id: question.imageId),
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
                                            _answered
                                                ? null
                                                : () => _answerQuestion(
                                                  option,
                                                  _currentPageIndex,
                                                  false,
                                                ),
                                        text: option,
                                        isOutlined: true,
                                        color: _getButtonColor(
                                          option,
                                          question.correctAnswer,
                                        ),
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

  Color? _getButtonColor(String option, String correctAnswer) {
    if (!_answered) return null;
    if (option == correctAnswer) return Colors.green.withValues(alpha: 0.7);
    if (option == _selectedAnswer && option != correctAnswer) {
      return Colors.red.withValues(alpha: 0.7);
    }
    return null;
  }
}
