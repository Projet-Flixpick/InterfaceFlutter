import 'package:flutter/material.dart';

class NoImageWidget extends StatelessWidget {
  const NoImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/no_image.png',
      fit: BoxFit.cover,
    );
  }
}
