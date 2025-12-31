import 'package:flutter/material.dart';
import 'question_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Define constants for durations
  static const _iconDuration = Duration(seconds: 2);
  static const _titleDuration = Duration(milliseconds: 1500);
  static const _buttonDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon with rotation
            AnimatedContainer(
              duration: _iconDuration,
              curve: Curves.elasticOut,
              transform: Matrix4.rotationZ(0.1),
              child: Text('🎯', style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 80)),
            ),
            const SizedBox(height: 20),
            // Animated title with fade and slide
            AnimatedOpacity(
              opacity: 1.0,
              duration: _titleDuration,
              child: Transform.translate(
                offset: Offset.zero,
                child: Text(
                  'Flutter Quiz',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Animated button with scale effect
            AnimatedContainer(
              duration: _buttonDuration,
              curve: Curves.easeInOut,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const QuestionScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 8,
                  shadowColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Start Quiz',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
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