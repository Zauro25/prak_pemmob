import 'dart:math' as math;

class Question {
  final String question;
  final List<String> possibleAnswers;
  final int correctAnswer;
  Question(this.question, this.possibleAnswers, this.correctAnswer);
}

class QuestionBank {
  final List<Question> _questions = _createQuestions();

  bool get hasNextQuestion => _questions.isNotEmpty;
  int get remainingQuestions => _questions.length;

  Question? getRandomQuestion() {
    if (_questions.isEmpty) {
      return null;
    }

    var i = math.Random().nextInt(_questions.length);
    var question = _questions[i];

    _questions.removeAt(i);
    return question;
  }
}

List<Question> _createQuestions() {
  return [
    Question(
      'What is the primary programming language for Flutter development?',
      ['Dart', 'Java', 'Swift', 'Kotlin'],
      0,
    ),
    Question(
      'Which widget is used for responsive layouts in Flutter?',
      ['Flexible', 'Container', 'Column', 'ListView'],
      0,
    ),
    Question(
      'What command is used to create a new Flutter project?',
      ['flutter create', 'flutter new', 'flutter init', 'flutter start'],
      0,
    ),
    Question(
      'Which function is the entry point of a Flutter app?',
      ['main()', 'runApp()', 'initState()', 'build()'],
      0,
    ),
    Question(
      'What is used to manage state in Flutter?',
      ['setState', 'BuildContext', 'Widget', 'Element'],
      0,
    ),
    Question(
      'Which widget creates a scrollable list?',
      ['ListView', 'Column', 'Row', 'Stack'],
      0,
    ),
  ];
}