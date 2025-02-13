import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pour vous")),
      body: const Center(
        child: Text(
          "Films recommandés 🎯",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
