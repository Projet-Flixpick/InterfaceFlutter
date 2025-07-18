import 'package:flutter/material.dart';

class SearchIcon extends StatelessWidget {
  final String type;
  final bool? isSerie;

  const SearchIcon({
    Key? key,
    required this.type,
    this.isSerie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color myRed = Color(0xFFC14040);

    if (type == 'media') {
      if (isSerie == true) {
        return const Icon(Icons.live_tv, color: myRed);
      } else {
        return const Icon(Icons.movie, color: myRed);
      }
    } else if (type == 'person') {
      return const Icon(Icons.person, color: myRed);
    }
    return const Icon(Icons.help_outline, color: myRed);
  }
}
