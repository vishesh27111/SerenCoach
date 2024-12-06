import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../globals.dart' as globals;

class TrackProgressPage extends StatefulWidget {
  const TrackProgressPage({Key? key}) : super(key: key);

  @override
  _TrackProgressPageState createState() => _TrackProgressPageState();
}

class _TrackProgressPageState extends State<TrackProgressPage> {
  List<dynamic> _inProgressGoals = [];
  List<dynamic> _completedGoals = [];
  bool _isLoading = true;
  bool _isAccordionExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    try {
      final response = await http.get(Uri.parse('${globals.api_base_url}/goals'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _inProgressGoals = data.where((goal) => goal['status'] == 'in-progress').toList();
          _completedGoals = data.where((goal) => goal['status'] == 'completed').toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load goals');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching goals: $error');
    }
  }

  Future<void> _updateGoalProgress(String goalId, double newProgress) async {
    String url = '${globals.api_base_url}/update_goal/$goalId';
    Map<String, dynamic> updates = {'progress': newProgress};

    if (newProgress == 100.0) {
      updates['status'] = 'completed'; // Mark as completed
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        _fetchGoals(); // Refresh goals after update
      } else {
        throw Exception('Failed to update goal');
      }
    } catch (error) {
      print('Error updating goal: $error');
    }
  }

  Future<void> _updateGoalDeadline(String goalId, DateTime newDeadline) async {
    String url = '${globals.api_base_url}/update_goal/$goalId';
    Map<String, dynamic> updates = {'deadline': newDeadline.toIso8601String()};

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        _fetchGoals(); // Refresh goals after deadline update
      } else {
        throw Exception('Failed to update deadline');
      }
    } catch (error) {
      print('Error updating deadline: $error');
    }
  }


  void _showProgressSlider(String goalId, double currentProgress) {
    double newProgress = currentProgress;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Progress'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Progress: ${newProgress.toStringAsFixed(0)}%'),
                  Slider(
                    value: newProgress,
                    min: 0.0,
                    max: 100.0,
                    divisions: 100,
                    label: '${newProgress.toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() {
                        newProgress = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateGoalProgress(goalId, newProgress);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeadlineDialog(String goalId) async {
    DateTime? newDeadline = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDeadline != null) {
      _updateGoalDeadline(goalId, newDeadline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // children: [
                  //   _buildSectionTitle('In-Progress Goals', Colors.orange),
                  //   const SizedBox(height: 8.0),
                  //   _buildGoalsList(_inProgressGoals, true),
                  //   const SizedBox(height: 24.0),
                  //   _buildAccordion('Completed Goals', Colors.green),
                  // ],
                  children: [
                    _buildGoalSection('In-Progress Goals', _inProgressGoals, Colors.orange),
                    const SizedBox(height: 16.0),
                    _buildGoalSection('Completed Goals', _completedGoals, Colors.green, showActions: false),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGoalSection(String title, List<dynamic> goals, Color color, {bool showActions = true}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8.0),
        goals.isEmpty
            ? const Text('No goals available.')
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            double currentProgress = goal['progress'].toDouble();
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['goal_title'],
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(goal['description']),
                    if (showActions) ... [
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress: ${currentProgress.toStringAsFixed(0)}%'),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary
                          ),
                          onPressed: () => _showDeadlineDialog(goal['_id']),
                          child: Text(
                            'Update Deadline',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Slider(
                      value: currentProgress,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      label: '${currentProgress.toStringAsFixed(0)}%',
                      onChanged: (value) {
                        setState(() {
                          currentProgress = value;
                        });
                      },
                      onChangeEnd: (value) {
                        _updateGoalProgress(goal['_id'], value);
                      },
                    ),
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }


}
