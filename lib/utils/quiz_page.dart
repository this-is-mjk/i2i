import 'package:flutter/material.dart';
import 'package:i2i/utils/common_button.dart';
import 'package:i2i/utils/objects/questions.dart';

class QuizPage extends StatefulWidget {
  final Question question;
  final int index;
  final int currentPageIndex;
  final VoidCallback onNext;
  final bool isLast;

  const QuizPage({
    super.key,
    required this.question,
    required this.index,
    required this.currentPageIndex,
    required this.onNext,
    required this.isLast,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    if (widget.index == widget.currentPageIndex) {
      _startTiming();
    }
  }

  @override
  void didUpdateWidget(covariant QuizPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index == widget.currentPageIndex &&
        oldWidget.currentPageIndex != widget.currentPageIndex) {
      _startTiming();
    } else if (oldWidget.index == oldWidget.currentPageIndex &&
        widget.index != widget.currentPageIndex) {
      _stopTiming();
    }
  }

  void _startTiming() {
    _startTime = DateTime.now();
  }

  void _stopTiming() {
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    widget.question.timeTakenInSeconds += elapsed;
  }

  void _answerQuestion(String selectedAnswer) {
    setState(() {
      widget.question.answered = selectedAnswer;
    });
    _stopTiming();
    widget.onNext();
  }

  @override
  ///different layout for mobile and desktop screen
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ///same for both
          // Question Text
          Text(
            widget.question.questionString,
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),

          // const SizedBox(height: 1),

          // Main content based on screen size
          Expanded(
            child:
                isMobile
                    ? _buildMobileLayout(textTheme)
                    : _buildDesktopLayout(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(TextTheme textTheme) {
    return Column(
      children: [
        // Image
        Expanded(
          flex: 5,
          child: Container(
            child: Image(
              image: AssetImage(
                "assets/BaselineImages/${widget.question.imageId}.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Options or Answer
        Expanded(
          flex: 5,
          child:
              widget.question.options.isEmpty
                  ? Center(
                    child: Text(
                      widget.question.correctAnswer,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    itemCount: widget.question.options.length,
                    itemBuilder: (context, index) {
                      final option = widget.question.options[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: CommonButton(
                              onPressed: () => _answerQuestion(option),
                              text: option,
                              isOutlined: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(TextTheme textTheme) {
    final bool isFour =
        widget.question.options.length == 4 ||
        widget.question.options.length == 2;
    return Column(
      children: [
        // Left: Image
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Image(
              image: AssetImage(
                "assets/BaselineImages/${widget.question.imageId}.jpg",
              ),
              fit: BoxFit.fitHeight,
            ),
          ),
        ),

        const SizedBox(height: 5.0),

        // Right: Options
        Expanded(
          flex: 1,
          child:
              widget.question.options.isEmpty
                  ? Center(
                    child: Text(
                      widget.question.correctAnswer,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  )
                  : Center(
                    child: SizedBox(
                      width: 850,
                      child: Center(
                        child: GridView.builder(
                          itemCount: widget.question.options.length,

                          // shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isFour ? 2 : 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 5,
                                childAspectRatio: 8.0,
                              ),
                          itemBuilder: (context, index) {
                            final option = widget.question.options[index];

                            if (option == null) {
                              // Render an empty box to preserve grid structure
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: CommonButton(
                                    onPressed: () => _answerQuestion(option),
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
    );
  }
}
