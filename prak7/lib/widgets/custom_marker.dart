import 'package:flutter/material.dart';

/// Reusable marker widget with a themed food icon and name label.
/// Parameters use clear, descriptive naming for maintainability.
class CustomMarker extends StatelessWidget {
  final String placeName;
  final bool isTemporary; // Highlights temporary pin selection visually.

  const CustomMarker({
    super.key,
    required this.placeName,
    this.isTemporary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: isTemporary ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTemporary ? theme.colorScheme.primary : Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Icon(
              Icons.ramen_dining,
              color: isTemporary ? Colors.white : theme.colorScheme.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                placeName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
