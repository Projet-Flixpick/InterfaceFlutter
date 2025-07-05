import 'package:flutter/material.dart';
import '../screens/2.films/film_detail_screen.dart';
import '../models/film_model.dart';

class FilmsCard extends StatelessWidget {
  final Film film;

  const FilmsCard({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilmDetailScreen(film: film),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              film.posterPath,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/no_image.png',
                width: 100,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    film.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    film.releaseDate.length >= 4
                        ? film.releaseDate.substring(0, 4)
                        : 'Unknown',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
