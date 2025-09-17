import 'package:flutter/material.dart';

class RatingBadge extends StatelessWidget {
  final double? rating;
  final double size;
  final bool showBackground;

  const RatingBadge({
    super.key,
    this.rating,
    this.size = 32,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = rating?.toStringAsFixed(1) ?? '—';
    final color = _getRatingColor(rating);

    if (!showBackground) {
      return Text(
        displayText,
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(double? rating) {
    if (rating == null) return Colors.grey;
    
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }
}