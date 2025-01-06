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

class _DetectionState extends State<Detection>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
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
      final response =
      await http.post(url, headers: headers, body: jsonEncode(body));
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

  // Helper function to calculate dynamic sizes
  double getDynamicSize(double baseSize) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return (screenWidth / 390) * baseSize; // 390 is the iPhone 13 Pro Max width
  }

  @override
  Widget build(BuildContext context) {
    var anxiety = globals.anxiety ?? "low";
    var depression = globals.depression ?? "low";
    globals.level = getLevel(anxiety, depression);

    List<Map<String, dynamic>> actions;
    if (globals.level == 0) {
      actions = [
        {'title': 'Guided Meditation', 'widget': MeditationPage()},
        {'title': 'Gratitude Journalling', 'widget': GratitudeJournalPage()},
        {
          'title': 'Self-help resources from experts',
          'widget': ArticleListPage()
        },
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

    // // Helper function to calculate dynamic sizes
    // double getDynamicSize(double baseSize) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // return (screenWidth / 390) * baseSize; // 390 is the iPhone 13 Pro Max width
    // }

    // Anxiety Color and Text
    Color anxietyColor = anxiety == 'low'
        ? Colors.green
        : (anxiety == 'medium' ? Colors.orange : Colors.red);
    String anxietyLevelText = '${anxiety[0].toUpperCase()}${anxiety.substring(1)
        .toLowerCase()}';

    // Depression Color and Text
    Color depressionColor = depression == 'low'
        ? Colors.green
        : (depression == 'medium' ? Colors.orange : Colors.red);
    String depressionLevelText = '${depression[0].toUpperCase()}${anxiety
        .substring(1).toLowerCase()}';

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: getDynamicSize(90),
          left: getDynamicSize(30),
          right: getDynamicSize(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Header
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/therapist_avatar.png',
                      width: getDynamicSize(50),
                      height: getDynamicSize(50),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: getDynamicSize(10)),
                  Text(
                    "SerenCoach",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: getDynamicSize(35),
                      fontWeight: FontWeight.w700,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getDynamicSize(20)),

            // Prediction Card
            Container(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(getDynamicSize(16)),
                ),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(getDynamicSize(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLevelRow(
                          'Anxiety Level:', anxietyLevelText, anxietyColor,
                          context),
                      SizedBox(height: getDynamicSize(16)),
                      _buildLevelRow('Depression Level:', depressionLevelText,
                          depressionColor, context),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: getDynamicSize(60)),

            // Therapies Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(getDynamicSize(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(getDynamicSize(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check out these helpful therapies:',
                      style: TextStyle(
                        fontSize: getDynamicSize(25),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: getDynamicSize(1)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: getDynamicSize(8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                getDynamicSize(12)),
                          ),
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (
                                    context) => actions[index]['widget']),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: getDynamicSize(12),
                                horizontal: getDynamicSize(16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(
                                    getDynamicSize(12)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: getDynamicSize(20),
                                    backgroundColor: Colors.blueAccent
                                        .withOpacity(0.3),
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(width: getDynamicSize(16)),
                                  Expanded(
                                    child: Text(
                                      actions[index]['title'],
                                      style: TextStyle(
                                        fontSize: getDynamicSize(18),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blueAccent,
                                    size: getDynamicSize(16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Home Button
            Padding(
              padding: EdgeInsets.all(getDynamicSize(16)),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/home');
                    await NotificationService.scheduleImmediateAndHourlyNotifications(widget.suggestedActivities);
                  },
                  child: Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: getDynamicSize(18),
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(
                      vertical: getDynamicSize(16),
                      horizontal: getDynamicSize(32),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(getDynamicSize(8)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(String label, String level, Color color,
      BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: getDynamicSize(24),
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(width: getDynamicSize(8)),
        Text(
          level,
          style: TextStyle(
            fontSize: getDynamicSize(26),
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

