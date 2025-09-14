// lib/screens/4.autre/acteur_detail_screen.dart

import 'package:flutter/material.dart';

import '../../models/person_model.dart';
import '../../services/APINode/api_routes_node.dart';
import '../../widgets/no_image.dart';
import '../../widgets/titre_section.dart';

class ActeurDetailScreen extends StatefulWidget {
  static const routeName = '/acteur-detail';
  final String personId;

  const ActeurDetailScreen({Key? key, required this.personId})
      : super(key: key);

  @override
  State<ActeurDetailScreen> createState() => _ActeurDetailScreenState();
}

class _ActeurDetailScreenState extends State<ActeurDetailScreen> {
  late Future<Person> _futurePerson;
  static const _baseImageUrl = 'https://image.tmdb.org/t/p/w500';
  bool _bioExpanded = false;

  @override
  void initState() {
    super.initState();
    _futurePerson = fetchPersonById(widget.personId);
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.redAccent,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actor'),
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<Person>(
        future: _futurePerson,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error : ${snap.error}'));
          }

          final person = snap.data!;
          final imageUrl = (person.profilePath?.isNotEmpty ?? false)
              ? '$_baseImageUrl${person.profilePath}'
              : null;

          // assemble chips under the name
          final List<Widget> infoChips = [];
          if (person.birthday != null && person.birthday!.isNotEmpty) {
            infoChips.add(_buildChip(person.birthday!));
          }
          if (person.placeOfBirth != null && person.placeOfBirth!.isNotEmpty) {
            infoChips.add(_buildChip(person.placeOfBirth!));
          }
          if (person.knownForDepartment != null && person.knownForDepartment!.isNotEmpty) {
            infoChips.add(_buildChip(person.knownForDepartment!));
          }
          if (person.gender != null) {
            final g = person.gender == 1 ? 'Female' : person.gender == 2 ? 'Male' : 'Other';
            infoChips.add(_buildChip(g));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner image
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const NoImageWidget(),
                  )
                else
                  const SizedBox(
                    height: 300,
                    child: NoImageWidget(),
                  ),

                const SizedBox(height: 8),

                // Name + optional death date (like title + release date)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          person.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (person.deathday != null && person.deathday!.isNotEmpty)
                        Text(
                          person.deathday!,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black54),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Info chips
                if (infoChips.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: infoChips,
                    ),
                  ),

                const SizedBox(height: 16),

                // Biography section with Read more
                if (person.biography != null && person.biography!.isNotEmpty) ...[
                  const TitreSection(title: 'Biography'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.biography!,
                          maxLines: _bioExpanded ? null : 4,
                          overflow: _bioExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => setState(() => _bioExpanded = !_bioExpanded),
                          child: Text(
                            _bioExpanded ? 'Read less' : 'Read more',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
