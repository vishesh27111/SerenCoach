import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import '../globals.dart' as globals; // Import globals

class GratitudeJournalPage extends StatefulWidget {
  @override
  _GratitudeJournalPageState createState() => _GratitudeJournalPageState();
}

class _GratitudeJournalPageState extends State<GratitudeJournalPage> {
  DateTime selectedDate = DateTime.now();
  int startOffset = 0;
  List<Map<String, dynamic>> todayLogs = [];  // Now it's a list of logs
  final int visibleDays = 5;
  String? selectedTopic;

  @override
  void initState() {
    super.initState();
    _getEntryForDate();
  }

  List<DateTime> getVisibleDates() {
    List<DateTime> dates = [];
    for (int i = startOffset; i < startOffset + visibleDays; i++) {
      dates.add(DateTime.now().subtract(Duration(days: i)));
    }
    return dates.reversed.toList();
  }

  void loadPreviousDates() {
    setState(() {
      startOffset += visibleDays;
    });
  }

  void loadNextDates() {
    if (startOffset >= visibleDays) {
      setState(() {
        startOffset -= visibleDays;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentDate = selectedDate.day == DateTime.now().day &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.year == DateTime.now().year;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gratitude Journal"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isCurrentDate && selectedTopic == null)
                      _buildTopicSelection(),
                    if (isCurrentDate && selectedTopic != null)
                      DescriptionPage(
                        topic: selectedTopic!,
                        onSubmit: (description) {
                          _saveEntry(description);
                        },
                        onClose: () {
                          setState(() {
                            selectedTopic = null;
                          });
                        },
                      ),
                    // Title for the list of logs
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Gratitude Logs",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    // Display all logs for today
                    if (todayLogs.isNotEmpty)
                      ...todayLogs.map((log) => _buildLogDisplay(log)).toList(),
                    if (todayLogs.isEmpty)
                      Center(child: Text("No logs made for this date")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.all(4.0),
      height: 75,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: loadPreviousDates,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: visibleDays,
              itemBuilder: (context, index) {
                DateTime date = getVisibleDates()[index];
                bool isSelected = selectedDate.day == date.day &&
                    selectedDate.month == date.month &&
                    selectedDate.year == date.year;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                    _getEntryForDate();
                  },
                  child: Container(
                    width: 50,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 6.5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                        )
                      ]
                          : [],
                    ),
                    child: Text(
                      "${date.day}/${date.month}",
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: loadNextDates,
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSelection() {
    List<String> topics = ["Family", "Health", "Work", "Friends", "Nature", "Festival", "Food"];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "What are you grateful for today?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          SizedBox(height: 10),
          // List of topics with a stylish design
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 2.5,
            ),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTopic = topics[index];
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    topics[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogDisplay(Map<String, dynamic> log) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log['topic'] ?? 'No Topic',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              log['description'] ?? 'No Description',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareEntry(log),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getEntryForDate() async {
    final String formattedDate = selectedDate.toIso8601String().split("T")[0];  // This will give you YYYY-MM-DD format
    final apiUrl = Uri.parse('${globals.api_base_url}/logs/$formattedDate');

    try {
      final response = await http.get(apiUrl);
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final entryData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          todayLogs = entryData.map((log) => log as Map<String, dynamic>).toList();
        });
      } else if (response.statusCode == 404) {
        setState(() {
          todayLogs = [];  // No logs found for the date
        });
      } else {
        print("Failed with status: ${response.statusCode}, body: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
      Fluttertoast.showToast(msg: "Error fetching entries: $e");
    }
  }

  Future<void> _saveEntry(String description) async {
    final apiUrl = Uri.parse('${globals.api_base_url}/log');
    final String formattedDate = selectedDate.toIso8601String().split("T")[0];

    final entryData = {
      'date': formattedDate,
      'topic': selectedTopic,
      'description': description,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(entryData),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Log saved successfully");
        setState(() {
          todayLogs.add(entryData); // Add the new entry to the logs
          selectedTopic = null;
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to save entry");
        print("Failed to save entry: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving entry: $e");
      print("Error occurred: $e");
    }
  }

  void _shareEntry(Map<String, dynamic> log) {
    final String topic = log['topic'] ?? 'No Topic';
    final String description = log['description'] ?? 'No Description';
    // final String date = selectedDate.toString().split(' ')[0];

    final String shareContent = "Today's Gratitude Journal Entry"
        "Topic: $topic\n\n"
        "Description:\n$description";

    Share.share(shareContent);
  }
}

class DescriptionPage extends StatelessWidget {
  final String topic;
  final Function(String) onSubmit;
  final VoidCallback onClose;

  DescriptionPage({required this.topic, required this.onSubmit, required this.onClose});

  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: onClose,
          ),
          title: Text("Describe"),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            controller: descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Why are you grateful?",
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onSubmit(descriptionController.text);
          },
          child: Text("Submit",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
