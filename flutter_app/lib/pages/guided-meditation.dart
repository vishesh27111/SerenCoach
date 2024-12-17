import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import '../globals.dart' as globals;

class MeditationPage extends StatefulWidget {
  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> meditations = [];
  String? activeGoalId;
  double activeGoalProgress = 0.0;
  double lastReportedProgress = 0.0;

  @override
  void initState() {
    super.initState();
    fetchMeditationGoal();
    fetchMeditations();
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

  Future<void> fetchMeditations() async {
    final url = Uri.parse('${globals.api_base_url}/meditations');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        meditations = data.map((item) {
          return {
            'title': item['title'],
            'creator': item['creator']['name'],
            'duration': item['duration'],
            'path': 'assets/audios/${item['file_name']}', // Updated path
          };
        }).toList();
      });
    } else {
      print("Failed to fetch meditations: ${response.body}");
    }
  }

  void trackProgress() {
    if (activeGoalId == null) return;

    _audioPlayer.positionStream.listen((currentPosition) {
      final totalDuration = _audioPlayer.duration;
      if (totalDuration != null) {
        final percentage = (currentPosition.inMilliseconds /
            totalDuration.inMilliseconds *
            100)
            .clamp(0.0, 100.0);

        if ((percentage - lastReportedProgress) >= 10) {
          final increment = percentage - lastReportedProgress;
          lastReportedProgress = percentage;
          print("Listening progress: ${percentage.toStringAsFixed(0)}%");
          updateGoalProgress(activeGoalId!, increment);
        }
      }
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

  void showPlaybackDialog(String title, String creator, String duration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titlePadding: EdgeInsets.all(16),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _audioPlayer.stop();
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Creator: $creator', style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              StreamBuilder<Duration?>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final totalDuration = _audioPlayer.duration ?? Duration.zero;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: totalDuration.inMilliseconds == 0
                            ? 0
                            : position.inMilliseconds / totalDuration.inMilliseconds,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${position.toString().split('.')[0]} / ${totalDuration.toString().split('.')[0]}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMeditationTile(Map<String, dynamic> meditation) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.audiotrack, color: Colors.white),
        ),
        title: Text(
          meditation['title']!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${meditation['creator']} : ${meditation['duration']}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),

        trailing: IconButton(
          icon: Icon(Icons.play_arrow, color: Colors.blue, size: 30),
          onPressed: () async {
            try {
              await _audioPlayer.setAsset(meditation['path']!);
              _audioPlayer.play();
              trackProgress();
              showPlaybackDialog(
                  meditation['title']!, meditation['creator'], meditation['duration']);
            } catch (e) {
              print("Error playing audio: $e");
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guided Meditation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: meditations.isEmpty
                ? Center(
              child: Text('No meditations available'),
            )
                : ListView.builder(
              itemCount: meditations.length,
              itemBuilder: (context, index) {
                return buildMeditationTile(meditations[index]);
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
