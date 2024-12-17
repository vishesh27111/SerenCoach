import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../service/NotificationService.dart';
import 'package:my_flutter_app/pages/gratitude-journaling.dart';
import 'package:my_flutter_app/pages/guided-meditation.dart';
import 'package:my_flutter_app/pages/combat.dart';
import 'package:my_flutter_app/pages/emergency.dart';
import 'package:my_flutter_app/pages/ai-chat.dart';

class Detection extends StatefulWidget {
  final List<Map<String, String>> conversationHistory;
  final List<Map<String, String>> suggestedActivities;

  Detection({
    required this.conversationHistory,
    required this.suggestedActivities,
  });

  @override
  _DetectionState createState() => _DetectionState();
}

class _DetectionState extends State<Detection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _showActions = false; // To control when to show the actions

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(seconds: 7), vsync: this);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 9), () {
      setState(() {
        _showActions = true;
      });
    });

    _initializeAsyncTasks();
  }

  Future<void> _initializeAsyncTasks() async {
    await _saveConversation();
  }

  Future<void> _saveConversation() async {
    final url = Uri.parse('${globals.api_base_url}/save_chat');
    final headers = {'Content-Type': 'application/json'};
    final body = {'conversation': widget.conversationHistory};

    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 201) {
        print('Conversation saved successfully');
      } else {
        print('Failed to save conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving conversation: $e');
    }
  }

  int getLevel(String anxiety, String depression) {
    if (anxiety == "low" && depression == "low") {
      return 0;
    } else if (anxiety == "high" || depression == "high") {
      return 2;
    } else {
      return 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var anxiety = globals.anxiety ?? "low";
    var depression = globals.depression ?? "low";
    globals.level = getLevel(anxiety, depression); // Set the level in globals

    List<Map<String, dynamic>> actions;
    if (globals.level == 0) {
      actions = [
        {'title': 'Guided Meditation', 'widget': MeditationPage()},
        {'title': 'Gratitude Journalling', 'widget': GratitudeJournalPage()},
        {'title': 'Self-help resources from experts', 'widget': ArticleListPage()},
      ];
    } else if (globals.level == 1) {
      actions = [
        {'title': 'Guided Meditation', 'widget': MeditationPage()},
        {'title': 'Chat with AI Therapist', 'widget': ChatWithTherapistPage()},
      ];
    } else {
      actions = [
        {'title': 'Chat with AI Therapist', 'widget': ChatWithTherapistPage()},
        {'title': 'Seek Urgent Help', 'widget': EmergencyPage()},
      ];
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).padding.top + 20),

              Text(
                'SerenCoach',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 36,
                ),
              ),
              SizedBox(height: 20),

              CircleAvatar(
                radius: 125,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/therapist_avatar.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),

              if (!_showActions) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Here\'s what I\'ve observed from our conversation:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your anxiety level is $anxiety',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Your depression level is $depression',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Check out these helpful therapies',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      var action = actions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                            title: Text(
                              action['title'] ?? '',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
                            ),
                            trailing: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => action['widget'], // Use the widget defined in actions
                                ),
                              );
                            }
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      await NotificationService.scheduleImmediateAndHourlyNotifications(widget.suggestedActivities);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Go to Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
