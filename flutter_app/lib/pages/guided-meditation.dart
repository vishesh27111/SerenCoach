import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;


class GuidedMeditationsPage extends StatefulWidget {
  @override
  _GuidedMeditationsPageState createState() => _GuidedMeditationsPageState();
}

class _GuidedMeditationsPageState extends State<GuidedMeditationsPage> {
  late Future<List<Map<String, dynamic>>> _meditations;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  Future<List<Map<String, dynamic>>> fetchMeditations() async {
    final String apiUrl = '${globals.api_base_url}/meditations';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load meditations');
    }
  }

  @override
  void initState() {
    super.initState();
    _meditations = fetchMeditations();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget buildMeditationCard(Map<String, dynamic> meditation, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              meditation['title'],
              style: theme.textTheme.headlineLarge!.copyWith(
                fontSize: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Category
            Text(
              meditation['category'],
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Creator
            Text(
              '${meditation['creator']['name']} - ${meditation['creator']['credentials']}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Duration and Play Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Duration with Icon
                Row(
                  children: [
                    Icon(Icons.access_time, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      meditation['duration'],
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),

                // Play Button
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_currentlyPlaying == meditation['file_name']) {
                      await _audioPlayer.stop();
                      setState(() {
                        _currentlyPlaying = null;
                      });
                    } else {
                      await _audioPlayer.play(UrlSource(meditation['url']));
                      setState(() {
                        _currentlyPlaying = meditation['file_name'];
                      });
                    }
                  },
                  icon: Icon(
                    _currentlyPlaying == meditation['file_name']
                        ? Icons.stop
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    _currentlyPlaying == meditation['file_name']
                        ? 'Stop'
                        : 'Play',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Guided Meditations'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _meditations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load meditations',
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No meditations available',
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else {
            final meditations = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: meditations.length,
                itemBuilder: (context, index) {
                  return buildMeditationCard(meditations[index], theme);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
