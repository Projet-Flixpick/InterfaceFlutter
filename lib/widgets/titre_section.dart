import 'package:flutter/material.dart';

class TitreSection extends StatelessWidget {
  final String title; // Titre de la section
  final Color sectionColor; // Couleur de fond de la section

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
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)], // Ombre
      ),
      child: Align(
        alignment: Alignment.centerLeft,  // Titre à gauche
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16.0, // Taille texte
            color: Colors.white, // Couleur texte
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
