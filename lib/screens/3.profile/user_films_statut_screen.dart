import 'package:flutter/material.dart';

class UserFilmsStatutScreen extends StatelessWidget {
  const UserFilmsStatutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liked Movies")),
      body: const Center(child: Text("List of movies you have liked")),
    );
  }
}
