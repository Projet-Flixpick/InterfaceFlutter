import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({Key? key}) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _positionAnimation = Tween<double>(begin: 0, end: 69).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          width: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🍿 Popcorn bucket
              Positioned(
                bottom: 0,
                child: Image.asset(
                  'assets/images/Logo_PopCorn_Solo.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),

              // ✋ Animated hand
              AnimatedBuilder(
                animation: _positionAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: _positionAnimation.value,
                    left: 79,
                    child: Image.asset(
                      'assets/images/Logo_Main_Solo.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Chargement...",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
