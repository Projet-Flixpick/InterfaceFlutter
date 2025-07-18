import 'package:flutter/material.dart';

const Color flixPickRed = Color(0xFFC14040);

class TitreSection extends StatelessWidget {
  final String title;

  const TitreSection({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 12, right: 12, bottom: 6), // <-- marge homogène
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0), // <-- padding généreux
      width: double.infinity,
      decoration: BoxDecoration(
        color: flixPickRed,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black26,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
