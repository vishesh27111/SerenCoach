import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../globals.dart' as globals;
import 'package:share_plus/share_plus.dart';

class GratitudeJournalPage extends StatefulWidget {
  @override
  _GratitudeJournalPageState createState() => _GratitudeJournalPageState();
}

class _GratitudeJournalPageState extends State<GratitudeJournalPage> {
  DateTime selectedDate = DateTime.now();
  int startOffset = 0;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Map<String, dynamic>? todayLog;
  final int visibleDays = 6;

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
        ),
        resizeToAvoidBottomInset: true, // This makes the Scaffold adjust when the keyboard is open
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Adds padding to prevent overflow
            ),
            child: Column(
              children: [
                _buildDateSelector(),
                if (isCurrentDate) _buildNewEntryForm(),
                if (todayLog != null)
                  _buildLogDisplay(todayLog!),
                if (!isCurrentDate && todayLog == null)
                  Center(child: Text("No logs made")),
              ],
            )
          ),
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
                    width: 42,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 6.5),
                    decoration: BoxDecoration(
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

  Widget _buildNewEntryForm() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Title"),
          ),
          SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(labelText: "Description"),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _saveEntry,
            child: Text("Save Entry"),
          ),
        ],
      ),
    );
  }

  Widget _buildLogDisplay(Map<String, dynamic> log) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log['title'] ?? 'No Title',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8),
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
    final apiUrl =
        '${globals.api_base_url}/logs/${selectedDate.toString().split(' ')[0]}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final entryData = jsonDecode(response.body);
        setState(() {
          todayLog = entryData;
        });
      } else {
        setState(() {
          todayLog = null;
        });
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<void> _saveEntry() async {
    final apiUrl = '${globals.api_base_url}/add_log';
    FocusScope.of(context).unfocus();

    final entryData = {
      'date': DateTime.now().toString().split(' ')[0],
      'title': titleController.text,
      'description': descriptionController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(entryData),
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Log saved");
        setState(() {
          todayLog = entryData;
          titleController.clear();
          descriptionController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add entry: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  void _shareEntry(Map<String, dynamic> log) {
    final String title = log['title'] ?? 'No Title';
    final String description = log['description'] ?? 'No Description';
    final String date = selectedDate.toString().split(' ')[0];

    final String shareContent = "Gratitude Journal Entry for $date\n\n"
        "Title: $title\n\n"
        "Description:\n$description";

    Share.share(shareContent);
  }

}
