import 'package:flutter/material.dart';

class UserAmisScreen extends StatelessWidget {
  const UserAmisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Friends")),
      body: const Center(child: Text("List of followed friends")),
    );
  }
}
