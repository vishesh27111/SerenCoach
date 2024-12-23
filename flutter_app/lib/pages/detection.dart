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

    // Anxiety Color and Text
    Color anxietyColor;
    String anxietyLevelText;
    if (anxiety == 'low') {
      anxietyColor = Colors.green;
      anxietyLevelText = 'Low';
    } else if (anxiety == 'medium') {
      anxietyColor = Colors.orange;
      anxietyLevelText = 'Medium';
    } else {
      anxietyColor = Colors.red;
      anxietyLevelText = 'High';
    }

    // Depression Color and Text
    Color depressionColor;
    String depressionLevelText;
    if (depression == 'low') {
      depressionColor = Colors.green;
      depressionLevelText = 'Low';
    } else if (depression == 'medium') {
      depressionColor = Colors.orange;
      depressionLevelText = 'Medium';
    } else {
      depressionColor = Colors.red;
      depressionLevelText = 'High';
    }

    return Scaffold(
      body: Padding(
        // padding: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.only(
          top: 90, // Padding from the top
          left: 30, // Padding from the left
          right: 30, // Padding from the right
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // SerenCoach Title as Header
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center, // Ensure horizontal centering
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/therapist_avatar.png',
                      width: 50, // Set the width of the image
                      height: 50, // Set the height of the image
                      fit: BoxFit.cover, // Ensure the image fills the circular area without distortion
                    ),
                  ), // Avatar
                  const SizedBox(width: 10), // Space between the image and text
                  Text(
                    "SerenCoach",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueAccent,
                    ),
                  ), // SerenCoach
                ],
              ),
            ),

            SizedBox(height: 20),

            // Prediction Display in One Card (Full Width)
            Container(
              width: double.infinity, // Ensure the card takes full width
              child: Card(
                color: Colors.white,  // Set background color to white
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Anxiety Level Label and Result
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Anxiety Level:  ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,  // Label color is black
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            anxietyLevelText,
                            style: TextStyle(
                              fontSize: 26, // Increased font size
                              fontWeight: FontWeight.w600,
                              color: anxietyColor, // Result color based on anxiety level
                              fontStyle: FontStyle.italic, // Different font style for results
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Depression Level:  ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,  // Label color is black
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            depressionLevelText,
                            style: TextStyle(
                              fontSize: 26, // Increased font size
                              fontWeight: FontWeight.w600,
                              color: depressionColor, // Result color based on depression level
                              fontStyle: FontStyle.italic, // Different font style for results
                            ),
                          ),
                        ],
                      )
                      // Depression Level Label and Result

                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 60),

            // Helpful Therapies Section
            // Helpful Therapies Section
            Container(
              width: double.infinity, // Ensures the container spans full width
              decoration: BoxDecoration(
                color: Colors.blue.shade50, // Background color for the section
                borderRadius: BorderRadius.circular(16), // Rounded corners for the section
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), // Subtle shadow
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Text(
                      'Check out these helpful therapies:',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: 1),
                    // List of Therapy Cards
                    ListView.builder(
                      shrinkWrap: true, // Ensures the ListView doesn't expand infinitely
                      physics: NeverScrollableScrollPhysics(), // Prevents inner scrolling
                      itemCount: actions.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => actions[index]['widget']),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100, // Background color of each card
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Icon or Placeholder (Optional)
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blueAccent.withOpacity(0.3),
                                    child: Icon(
                                      Icons.favorite, // Replace with a suitable icon
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(width: 16),

                                  // Therapy Title
                                  Expanded(
                                    child: Text(
                                      actions[index]['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios, // Navigation arrow
                                    color: Colors.blueAccent,
                                    size: 16,
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

            // Go to Home Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight, // Align button to the right
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/home');
                    await NotificationService.scheduleImmediateAndHourlyNotifications(widget.suggestedActivities);
                  },
                  child: Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Change font color to white
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );

  }
}