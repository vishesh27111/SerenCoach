import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting the selected date
import '../globals.dart' as globals; // Assuming globals.api_base_url is defined here

class SetGoalsPage extends StatefulWidget {
  const SetGoalsPage({Key? key}) : super(key: key);

  @override
  _SetGoalsPageState createState() => _SetGoalsPageState();
}

class _SetGoalsPageState extends State<SetGoalsPage> {
  final _goalTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  DateTime? _selectedDeadline; // To store the selected date

  String _goalType = "Meditation"; // Default goal type
  List<dynamic> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  @override
  void dispose() {
    _goalTitleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _fetchGoals() async {
    final url = Uri.parse('${globals.api_base_url}/goals');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _goals = json.decode(response.body)
              .where((goal) => goal['status'] == 'in-progress')
              .toList();
          _isLoading = false;
        });
      } else {
        _showSnackBar('Failed to load goals');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitGoal() async {
    FocusScope.of(context).unfocus();

    final goalTitle = _goalTitleController.text.isEmpty ? 'Meditation' : _goalTitleController.text;
    final description = _descriptionController.text;
    final deadline = _deadlineController.text;

    // Validation for goal type
    if (deadline.isEmpty) {
      _showSnackBar('Please select a deadline.');
      return;
    }

    if (_goalType == "Custom" && (goalTitle.isEmpty || description.isEmpty)) {
      _showSnackBar('Please fill out all fields for a custom goal.');
      return;
    }

    // Adjust the deadline to 11:59 PM of the selected date
    final adjustedDeadline = _selectedDeadline != null
        ? DateTime(
      _selectedDeadline!.year,
      _selectedDeadline!.month,
      _selectedDeadline!.day,
      23,
      59,
      59,
    )
        : null;

    final now = DateTime.now().toLocal(); // Get local time
    final timeZoneOffset = now.timeZoneOffset;
    final offsetSign = timeZoneOffset.isNegative ? '-' : '+';
    final offsetHours = timeZoneOffset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = (timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    final createdAt = "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now)}$offsetSign$offsetHours:$offsetMinutes";

    final url = Uri.parse('${globals.api_base_url}/set_goal');
    final goalData = {
      "goal_type": _goalType, // Add the selected goal type
      "goal_title": goalTitle,
      "description": description,
      "deadline": adjustedDeadline?.toIso8601String(),
      "progress": 0, // Initially setting progress to 0
      "status": "in-progress", // Default status
      "created_at": createdAt,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(goalData),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Goal set successfully!');
        _fetchGoals();
        _clearForm();
      } else {
        _showSnackBar('Failed to set goal');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _clearForm() {
    _goalTitleController.clear();
    _descriptionController.clear();
    _deadlineController.clear();
    _selectedDeadline = null;
    _goalType = "Meditation"; // Reset goal type to default
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set Goals'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal Type',
                style: textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Meditation'),
                      value: 'Meditation',
                      groupValue: _goalType,
                      onChanged: (value) {
                        setState(() {
                          _goalType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Custom'),
                      value: 'Custom',
                      groupValue: _goalType,
                      onChanged: (value) {
                        setState(() {
                          _goalType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              if (_goalType == 'Custom') ...[
                _buildTextField(
                  'Goal',
                  _goalTitleController,
                  'Enter your goal ...',
                  textTheme,
                  theme,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  'Goal Description',
                  _descriptionController,
                  'Describe your goal...',
                  textTheme,
                  theme,
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
              ],
              _buildDeadlineField(context, textTheme, theme),
              const SizedBox(height: 12.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _submitGoal,
                  child: const Text(
                    'Set Goal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Your Active Goals',
                style: textTheme.headlineLarge!.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _goals.isEmpty
                  ? const Text('No goals set yet.')
                  : ListView.builder(
                shrinkWrap: true, // Required to avoid overflow
                physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: ListTile(
                      title: Text(
                        goal['goal_title'],
                        style: textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        '${goal['description']} - Due: ${goal['deadline'].substring(0, 10)}',
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Status: ${goal['status']}'),
                          const SizedBox(height: 4.0),
                          Text('Progress: ${(goal['progress']).toStringAsFixed(0)}%'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineField(BuildContext context, TextTheme textTheme, ThemeData theme) {
    return GestureDetector(
      onTap: () => _selectDeadline(context),
      child: AbsorbPointer(
        child: _buildTextField(
          'Deadline',
          _deadlineController,
          'Select a deadline...',
          textTheme,
          theme,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hintText, TextTheme textTheme, ThemeData theme, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyLarge!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: hintText,
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }
}
