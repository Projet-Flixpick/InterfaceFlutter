import 'package:flutter/material.dart';

class TitreSection extends StatelessWidget {
  final String title;         // Section title
  final Color sectionColor;   // Background color of the section

  const TitreSection({
    Key? key,
    required this.title,
    required this.sectionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: sectionColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)], // Shadow
      ),
      child: Align(
        alignment: Alignment.centerLeft, // Align title to the left
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
