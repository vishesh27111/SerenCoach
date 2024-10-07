import 'package:flutter/material.dart';

class Detection extends StatefulWidget {
  final String anxiety;
  final String depression;
  final List<Map<String, String>> conversationHistory; // Not displayed
  final List<Map<String, String>> suggestedActivities; // Added for activities

  Detection({
    required this.anxiety,
    required this.depression,
    required this.conversationHistory,
    required this.suggestedActivities, // Added for activities
  });

  @override
  _DetectionState createState() => _DetectionState();
}

class _DetectionState extends State<Detection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showActivities = false; // For controlling when to show activities

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 7), vsync: this);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Delay increased to 10 seconds to give enough time to read predictions
    Future.delayed(const Duration(seconds: 9), () {
      setState(() {
        _showActivities = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Therapist',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 36,
                ),
              ),
              SizedBox(height: 20),

              // Keep the avatar fixed in its position to avoid it moving up
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
              SizedBox(height: 2),

              if (!_showActivities) ...[
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
                        'Your anxiety level is ${widget.anxiety}',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Your depression level is ${widget.depression}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(height: 10),
                Text(
                  'Some Suggested Activities for You:',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,  // This ensures the list takes only the required space
                    physics: NeverScrollableScrollPhysics(), // Disables scrolling if not necessary
                    itemCount: widget.suggestedActivities.length,
                    itemBuilder: (context, index) {
                      var activity = widget.suggestedActivities[index];
                      return ExpansionTile(
                        title: Text(
                          activity['activity'] ?? '',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              activity['description'] ?? '',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
              ]
            ],
          ),
        ),
      ),
    );
  }
}
