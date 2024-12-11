import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import '../globals.dart' as globals;

class MeditationPage extends StatefulWidget {
  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, String>> audioFiles = [];
  String? activeGoalId;
  double activeGoalProgress = 0.0;
  double lastReportedProgress = 0.0;

  @override
  void initState() {
    super.initState();
    fetchMeditationGoal();
    loadAudioFiles();
  }

  Future<void> fetchMeditationGoal() async {
    final url = Uri.parse('${globals.api_base_url}/meditation_goals');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final goals = json.decode(response.body);
      if (goals.isNotEmpty) {
        setState(() {
          activeGoalId = goals[0]['_id']; // Use the first active meditation goal
          activeGoalProgress = goals[0]['progress']?.toDouble() ?? 0.0;
        });
      } else {
        setState(() {
          activeGoalId = null;
        });
      }
    } else {
      print("Failed to fetch goals: ${response.body}");
    }
  }

  Future<void> loadAudioFiles() async {
    final String jsonString =
    await rootBundle.loadString('assets/audios/audios.json');
    final List<dynamic> audioData = json.decode(jsonString);

    setState(() {
      audioFiles = audioData.map((audio) {
        return {
          'title': audio['title'] as String,
          'path': 'assets/audios/${audio['path'] as String}',
        };
      }).toList();
    });
  }

  Future<void> updateGoalProgress(String goalId, double increment) async {
    double newProgress = activeGoalProgress + increment;
    if (newProgress >= 100.0) {
      newProgress = 100.0;
    }

    final url = Uri.parse('${globals.api_base_url}/update_goal/$goalId');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'progress': newProgress,
        if (newProgress == 100.0) 'status': 'completed',
      }),
    );

    if (response.statusCode == 200) {
      print("Goal progress updated successfully!");
      setState(() {
        activeGoalProgress = newProgress;
      });
    } else {
      print("Failed to update goal progress: ${response.body}");
    }
  }

  void trackProgress() {
    if (activeGoalId == null) return; // Ignore progress tracking if no active goal

    _audioPlayer.positionStream.listen((currentPosition) {
      final totalDuration = _audioPlayer.duration;
      if (totalDuration != null) {
        final percentage = (currentPosition.inMilliseconds /
            totalDuration.inMilliseconds *
            100)
            .clamp(0.0, 100.0);

        // Report progress in 10% increments and update backend
        if ((percentage - lastReportedProgress) >= 10) {
          final increment = percentage - lastReportedProgress;
          lastReportedProgress = percentage;
          print("Listening progress: ${percentage.toStringAsFixed(0)}%");
          updateGoalProgress(activeGoalId!, increment);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guided Meditation',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: audioFiles.length,
              itemBuilder: (context, index) {
                final audio = audioFiles[index];
                return ListTile(
                  leading: Icon(Icons.audiotrack),
                  title: Text(
                    audio['title']!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: Icon(Icons.play_arrow),
                  onTap: () async {
                    await _audioPlayer.setAsset(audio['path']!);
                    _audioPlayer.play();
                    trackProgress();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        contentPadding: EdgeInsets.all(20.0),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(audio['title']!),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    _audioPlayer.stop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            StreamBuilder<Duration?>(
                              stream: _audioPlayer.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                final duration = _audioPlayer.duration ?? Duration.zero;
                                return Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value: position.inMilliseconds /
                                          duration.inMilliseconds,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '${position.toString().split('.')[0]}/${duration.toString().split('.')[0]}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
