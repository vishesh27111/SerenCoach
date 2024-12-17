import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class TrackProgressPage extends StatefulWidget {
  const TrackProgressPage({Key? key}) : super(key: key);

  @override
  _TrackProgressPageState createState() => _TrackProgressPageState();
}

class _TrackProgressPageState extends State<TrackProgressPage> {
  List<dynamic> _customGoals = [];
  List<dynamic> _meditationGoals = [];
  List<dynamic> _completedGoals = [];
  bool _isLoading = true;

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
          _customGoals = data
              .where((goal) => goal['status'] == 'in-progress' && goal['goal_type'] == 'Custom')
              .toList();
          _meditationGoals = data
              .where((goal) => goal['status'] == 'in-progress' && goal['goal_type'] == 'Meditation')
              .toList();
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
            children: [
              _buildGoalSection('Custom Goals', _customGoals, Colors.orange),
              const SizedBox(height: 16.0),
              _buildMeditationGoalsSection('Meditation Goals', _meditationGoals),
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
            ? const Text('No goals set.')
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            double currentProgress = goal['progress'].toDouble();
            int stars = goal['stars'] ?? 0; // Safely handle missing stars field
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal['goal_title'],
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            stars,
                                (index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(goal['description']),
                    if (showActions) ...[
                      const SizedBox(height: 16.0),
                      Text('Progress: ${currentProgress.toStringAsFixed(0)}%'),
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

  Widget _buildMeditationGoalsSection(String title, List<dynamic> goals) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8.0),
        goals.isEmpty
            ? const Text('No active meditation goals.')
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            double currentProgress = goal['progress'].toDouble();
            int stars = goal['stars'] ?? 0; // Safely handle missing stars field
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal['goal_title'],
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            stars,
                                (index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(goal['description']),
                    const SizedBox(height: 16.0),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: currentProgress / 100,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text('Progress: ${currentProgress.toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
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
}
