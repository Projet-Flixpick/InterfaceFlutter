import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  final TextStyle? textStyle;
  const AnimatedLogo({Key? key, this.textStyle}) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  int dotCount = 0;

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

    _startDotAnimation();
  }

  void _startDotAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return false;
      setState(() {
        dotCount = (dotCount + 1) % 4;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * dotCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          width: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 0,
                child: Image.asset(
                  'assets/images/Logo_PopCorn_Solo.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              AnimatedBuilder(
                animation: _positionAnimation,
                builder: (_, __) {
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
        Text(
          "Chargement$dots",
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC14040),
              ),
        ),
      ],
    );
  }
}
