import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON

import 'detection.dart'; // For navigating to the next page

class TherapistPage extends StatefulWidget {
  @override
  _TherapistPageState createState() => _TherapistPageState();
}

class _TherapistPageState extends State<TherapistPage> with SingleTickerProviderStateMixin {
  bool isRecording = false;
  late stt.SpeechToText _speech;
  String _recordedText = '';
  late AnimationController _controller;
  late Animation<double> _avatarAnimation;
  late Animation<double> _questionAnimation;

  final String apiUrl = 'https://4bc5-47-55-121-22.ngrok-free.app/therapist'; // Replace with your actual API URL

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _avatarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    if (isRecording) {
      // Stop recording
      _speech.stop();
      setState(() {
        isRecording = false;
      });
      _submitResponse();  // Automatically submit after stopping
    } else {
      // Start recording
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          isRecording = true;
        });
        _speech.listen(onResult: (result) {
          setState(() {
            _recordedText = result.recognizedWords;
          });
        });
      }
    }
  }

  void _submitResponse() async {
    if (_recordedText.isNotEmpty) {
      // Make API call
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"response": _recordedText}),
      );

      // Handle API response and navigate to the next page
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detection(
              anxiety: data['anxiety']!,
              depression: data['depression']!,
            ),
          ),
        );
      } else {
        print('Failed to get API response');
      }
    }
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
              FadeTransition(
                opacity: _questionAnimation,
                child: Text(
                  'Hey Ruby, how are you feeling today?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 24,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: _toggleRecording,
                child: Column(
                  children: [
                    // Mic icon color changes based on isRecording state
                    Icon(
                      Icons.mic,
                      size: 60,
                      color: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 10),
                    // Text updates based on isRecording state
                    Text(
                      isRecording ? 'Recording...' : 'Tap to speak',
                      style: TextStyle(
                        fontSize: 20,
                        color: isRecording ? Colors.red : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}