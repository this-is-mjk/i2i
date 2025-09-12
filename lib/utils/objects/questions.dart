class Question {
  final String questionString;
  final String imageId;
  final String correctAnswer;
  final String answerDescription;
  final List<String> options;
  String? answered;
  int timeTakenInSeconds = 0;

  Question({
    required this.questionString,
    required this.imageId,
    required this.correctAnswer,
    required this.options,
    required this.answerDescription,
    this.answered,
  });

  bool isAnswerCorrect() {
    return answered == correctAnswer;
  }
}
