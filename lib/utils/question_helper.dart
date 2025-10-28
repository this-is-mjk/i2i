import 'dart:math';

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
  'A': 'Anger / ग़ुस्सा',
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
  'A11',
  'A13',
  'A15',
  'A16',
  'A2',
  'D10',
  'D11',
  'D14',
  'D4',
  'D7',
  'F1',
  'F14',
  'F15',
  'F2',
  'F6',
  'H1',
  'H11',
  'H14',
  'H18',
  'H7',
  'N1',
  'N12',
  'N19',
  'N7',
  'N9',
  'P1',
  'P10',
  'P12',
  'P14',
  'P6',
  'S16',
  'S18',
  'S5',
  'S6',
  'S9',
];

List<String> InterventionImageFiles = [
  'A11',
  'A13',
  'A15',
  'A16',
  'A2',
  'D10',
  'D11',
  'D14',
  'D4',
  'D7',
  'F1',
  // 'F14',
  'F15',
  'F2',
  'F6',
  'H1',
  'H11',
  'H4',
  'H18',
  'H7',
  'N1',
  'N12',
  'N19',
  'N7',
  'N9',
  'P1',
  'P10',
  'P12',
  'P14',
  'P6',
  'S16',
  'S18',
  'S5',
  'S6',
  'S9',
];

List<String> decideOptions(String correctOption, int level) {
  List<String> options = [correctOption];
  List<String> wrongOptions = List.from(emotionOptions)..remove(correctOption);

  if (level == 1) {
    options.add(wrongOptions[Random().nextInt(wrongOptions.length)]);
  } else if (level == 2) {
    options.addAll(wrongOptions.take(3));
  } else if (level == 3) {
    options.addAll(wrongOptions);
  }
  // options.shuffle();
  options.sort();
  return options;
}
