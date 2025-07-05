import 'package:flutter/material.dart';

class PopcornLoader extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final EdgeInsets padding;

  const PopcornLoader({
    super.key,
    this.size = 30,
    this.color = const Color(0xffefb4), // Jaune popcorn
    this.strokeWidth = 3,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
