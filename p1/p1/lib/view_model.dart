import 'package:flutter/cupertino.dart';
import 'model.dart';

class QuizViewModel extends ChangeNotifier {
  final QuestionBank _questionBank = QuestionBank();
  final VoidCallback onGameOver;
  late final int totalQuestions;
  Question? currentQuestion;
  int answeredQuestionCount = 0;
  int score = 0;
  bool didAnswerQuestion = false;
  bool get hasNextQuestion => _questionBank.hasNextQuestion;

  QuizViewModel({required this.onGameOver}) {
    totalQuestions = _questionBank.remainingQuestions;
    getNextQuestion();
  }

  void getNextQuestion() {
    if (_questionBank.hasNextQuestion) {
      currentQuestion = _questionBank.getRandomQuestion();
      answeredQuestionCount++;
    }

    didAnswerQuestion = false;

    notifyListeners();
  }

  void checkAnswer(int selectedIndex) {
    if (!didAnswerQuestion && currentQuestion?.correctAnswer == selectedIndex) {
      score++;
    }

    didAnswerQuestion = true;

    if (!_questionBank.hasNextQuestion) {
      Future.delayed(Duration(milliseconds: 1500), onGameOver);
    }

    notifyListeners();
  }
}