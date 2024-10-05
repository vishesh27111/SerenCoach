import 'package:flutter/material.dart';

class Detection extends StatefulWidget {
  final String anxiety;
  final String depression;

  Detection({required this.anxiety, required this.depression});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<Detection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _avatarAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _avatarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
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
              FadeTransition(
                opacity: _avatarAnimation,
                child: Column(
                  children: [
                    Text(
                      'Therapist',
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
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Your Results:',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 20),
              Text(
                'Anxiety: ${widget.anxiety}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                'Depression: ${widget.depression}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
