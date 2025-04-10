import 'package:flutter/material.dart';

class UserFilmsStatutScreen extends StatelessWidget {
  const UserFilmsStatutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Films likés")),
      body: const Center(child: Text("Liste des films que vous avez likés")),
    );
  }
}
