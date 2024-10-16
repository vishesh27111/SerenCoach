import 'package:flutter/material.dart';

class SetGoalsPage extends StatefulWidget {
  const SetGoalsPage({Key? key}) : super(key: key);

  @override
  _SetGoalsPageState createState() => _SetGoalsPageState();
}

class _SetGoalsPageState extends State<SetGoalsPage> {
  final _goalController = TextEditingController();
  String _goalType = 'Daily';

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _submitGoal() {
    final goal = _goalController.text;
    if (goal.isNotEmpty) {
      // Handle the goal submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal "$goal" has been set successfully!')),
      );
      Navigator.pop(context); // Go back to HomePage after setting the goal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select the type of goal
            const Text(
              'Goal Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            DropdownButton<String>(
              value: _goalType,
              items: ['Daily', 'Weekly', 'Custom']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _goalType = value!;
                });
              },
            ),
            const SizedBox(height: 24.0),

            // TextField to input goal description
            const Text(
              'Goal Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your goal here...',
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12.0),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: _submitGoal,
                child: const Text('Set Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
