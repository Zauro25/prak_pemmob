import 'package:flutter/material.dart';
import 'view_model.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with SingleTickerProviderStateMixin {
  late final QuizViewModel viewModel = QuizViewModel(
    onGameOver: _handleGameOver,
  );
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Define constants for durations
  static const _buttonDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _buttonDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 4,
            title: Text(
              'Quiz Time',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            actions: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: TextButton(
                  onPressed: viewModel.hasNextQuestion && viewModel.didAnswerQuestion
                      ? () {
                          _animationController.reset();
                          viewModel.getNextQuestion();
                          _animationController.forward();
                        }
                      : null,
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_forward_rounded, size: 18),
                      SizedBox(width: 4),
                      Text('Next'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                AnimatedQuestionCard(question: viewModel.currentQuestion?.question),
                const Spacer(),
                AnswerCards(
                  onTapped: (index) {
                    viewModel.checkAnswer(index);
                  },
                  answers: viewModel.currentQuestion?.possibleAnswers ?? [],
                  correctAnswer: viewModel.didAnswerQuestion
                      ? viewModel.currentQuestion?.correctAnswer
                      : null,
                ),
                AnimatedStatusBar(viewModel: viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleGameOver() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.elasticOut,
          ),
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.celebration_rounded, color: Colors.amber),
                SizedBox(width: 8),
                Text('Quiz Completed!'),
              ],
            ),
            content: Text('Your final score: ${viewModel.score}/${viewModel.totalQuestions}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedQuestionCard extends StatelessWidget {
  final String? question;

  const AnimatedQuestionCard({required this.question, super.key});

  // Use constant for duration
  static const _animationDuration = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOutBack,
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              question ?? 'Loading...',
              key: ValueKey(question),
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class AnswerCards extends StatelessWidget {
  final List<String> answers;
  final ValueChanged<int> onTapped;
  final int? correctAnswer;

  const AnswerCards({
    required this.answers,
    required this.onTapped,
    required this.correctAnswer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 5 / 2,
      padding: const EdgeInsets.all(16),
      children: List.generate(answers.length, (index) {
        return AnimatedAnswerCard(
          answer: answers[index],
          index: index,
          isCorrect: correctAnswer == index,
          onTapped: () => onTapped(index),
          isAnswered: correctAnswer != null,
        );
      }),
    );
  }
}

class AnimatedAnswerCard extends StatelessWidget {
  final String answer;
  final int index;
  final bool? isCorrect;
  final VoidCallback onTapped;
  final bool isAnswered;

  const AnimatedAnswerCard({
    required this.answer,
    required this.index,
    required this.isCorrect,
    required this.onTapped,
    required this.isAnswered,
    super.key,
  });

  // Use constant for duration
  static const _animationDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    Color getCardColor() {
      if (!isAnswered) {
        return Theme.of(context).colorScheme.primaryContainer;
      }
      return isCorrect == true 
          ? Colors.green.shade400
          : Theme.of(context).colorScheme.errorContainer;
    }

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        color: getCardColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: isAnswered ? null : onTapped,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    answer,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                  ),
                ),
                if (isAnswered && isCorrect == true)
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedStatusBar extends StatelessWidget {
  final QuizViewModel viewModel;

  const AnimatedStatusBar({required this.viewModel, super.key});

  // Use constant for duration
  static const _animationDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedCounter(
                count: viewModel.answeredQuestionCount,
                total: viewModel.totalQuestions,
                label: 'Question',
              ),
              Container(
                height: 30,
                width: 2,
                color: Theme.of(context).colorScheme.outline,
              ),
              AnimatedCounter(
                count: viewModel.score,
                label: 'Score',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCounter extends ImplicitlyAnimatedWidget {
  final int count;
  final int? total;
  final String label;

  const AnimatedCounter({
    required this.count,
    required this.label,
    this.total,
    super.key,
  }) : super(duration: const Duration(milliseconds: 500));

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends AnimatedWidgetBaseState<AnimatedCounter> {
  IntTween? _countTween;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.total != null 
              ? '${_countTween?.evaluate(animation) ?? widget.count}/${widget.total}'
              : '${_countTween?.evaluate(animation) ?? widget.count}',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _countTween = visitor(
      _countTween,
      widget.count,
      (dynamic value) => IntTween(begin: value as int),
    ) as IntTween;
  }
}