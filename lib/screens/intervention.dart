import 'package:flutter/material.dart';
import 'package:i2i/components/objects/questions.dart';

import 'quiz_results.dart';
import 'package:i2i/components/common_button.dart';

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
  'A11-c.jpg',
  'A13-c.jpg',
  'A15-c.jpg',
  'A16-c.jpg',
  'A2-c.jpg',
  'D10-c.jpg',
  'D11-c.jpg',
  'D14-c.jpg',
  'D4-c.jpg',
  'D7-c.jpg',
  'F1-c.jpg',
  'F14-c.jpg',
  'F15-c.jpg',
  'F2-c.jpg',
  'F6-c.jpg',
  'H1-c.jpg',
  'H11-c.jpg',
  'H14-c.jpg',
  'H18-c.jpg',
  'H7-c.jpg',
  'N1-c.jpg',
  'N12-c.jpg',
  'N19-c.jpg',
  'N7-c.jpg',
  'N9-c.jpg',
  'P1-c.jpg',
  'P10-c.jpg',
  'P12-c.jpg',
  'P14-c.jpg',
  'P6-c.jpg',
  'S16-c.jpg',
  'S18-c.jpg',
  'S5-c.jpg',
  'S6-c.jpg',
  'S9-c.jpg',
  'A11-ec.jpg',
  'A13-ec.jpg',
  'A15-ec.jpg',
  'A16-ec.jpg',
  'A2-ec.jpg',
  'D10-ec.jpg',
  'D11-ec.jpg',
  'D14-ec.jpg',
  'D4-ec.jpg',
  'D7-ec.jpg',
  'F1-ec.jpg',
  'F14-ec.jpg',
  'F15-ec.jpg',
  'F2-ec.jpg',
  'F6-ec.jpg',
  'H1-ec.jpg',
  'H11-ec.jpg',
  'H14-ec.jpg',
  'H18-ec.jpg',
  'H7-ec.jpg',
  'N1-ec.jpg',
  'N12-ec.jpg',
  'N19-ec.jpg',
  'N7-ec.jpg',
  'N9-ec.jpg',
  'P1-ec.jpg',
  'P10-ec.jpg',
  'P12-ec.jpg',
  'P14-ec.jpg',
  'P6-ec.jpg',
  'S16-ec.jpg',
  'S18-ec.jpg',
  'S5-ec.jpg',
  'S6-ec.jpg',
  'S9-ec.jpg',
];
//made list if onlyoption

List<String> onlyOption(String correctOption) {
  List<String> options = [correctOption];
  return options;
}

Future<List<Question>> decideQuestions() async {
  final selectedImages = imageFiles.take(1).toList();
  return selectedImages.map((imageFile) {
    final emotionKey = imageFile[0];
    final emotion = emotionMap[emotionKey] ?? 'Unknown';
    return Question(
      questionString: "Look carefully",
      imageId: "assets/caricatures/$imageFile",
      answerDescription: ".",
      correctAnswer: emotion,
      options: onlyOption(emotion),
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
                      builder: (context) => ResultPage(questions: questions),
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
            final questions = snapshot.data!;
            return Intpage(questions: shapshot.data!);
          } else {
            return const Center(child: Text('No questions available.'));
          }
        },
      ),
    );
  }
}

class Intpage extends StatefulWidget {
  final Question question;
  final int index;
  final int currentPageIndex;
  final VoidCallback onNext;

  const Intpage({
    super.key,
    required this.question,
    required this.index,
    required this.currentPageIndex,
    required this.onNext,
  });

  @override
  State<Intpage> createState() => _IntpageState();
}

class _IntpageState extends State<Intpage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void _answerQuestion(String selectedAnswer) {
    setState(() {
      widget.question.answered = selectedAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
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
              image: AssetImage(widget.question.imageId),
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
    return Column(
      children: [
        Expanded(child:widget.question.options.isEmpty
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
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 5,
                                childAspectRatio: 8.0,
                              ),
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
                    ),
                  ),
        ),
      ]
    );
   }, )

}
