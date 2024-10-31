import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import '../globals.dart' as globals;

class TherapistPage extends StatefulWidget {
  @override
  _TherapistPageState createState() => _TherapistPageState();
}

class _TherapistPageState extends State<TherapistPage> with SingleTickerProviderStateMixin {
  bool isRecording = false;
  bool isLoading = false;
  late stt.SpeechToText _speech;
  String _recordedText = '';
  late AnimationController _controller;
  late Animation<double> _avatarAnimation;
  late Animation<double> _questionAnimation;

  final apiUrl = Uri.parse('${globals.api_base_url}/analyze');

  String _currentQuestion = "How are you feeling today?";
  List<Map<String, String>> _conversationHistory = [];

  late CameraController _cameraController;
  late Future<void> _initializeCameraFuture;
  String? _videoFilePath;

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

    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );

    _initializeCameraFuture = _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (isRecording) {
      _speech.stop();
      _stopVideoRecording();
    } else {
      _startVideoRecording();
      _speech.initialize().then((available) {
        if (available) {
          _speech.listen(onResult: (result) {
            setState(() => _recordedText = result.recognizedWords);
          });
        }
      });
    }
  }

  void _submitResponse() async {
    if (_recordedText.isNotEmpty && _videoFilePath != null) {
      setState(() => isLoading = true);

      _conversationHistory.add({"question": _currentQuestion, "answer": _recordedText});

      try {
        var request = http.MultipartRequest('POST', apiUrl);

        // Add the text fields to the multipart request
        request.fields['question'] = _currentQuestion;
        request.fields['answer'] = _recordedText;

        // Attach the video file
        request.files.add(
          await http.MultipartFile.fromPath(
            'video',
            _videoFilePath!,
          ),
        );

        var response = await request.send();
        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          var data = json.decode(responseBody);
          double anxietyConfidence = data['anxiety_confidence'] ?? 0;
          double depressionConfidence = data['depression_confidence'] ?? 0;

          String followUpQuestion = data['follow_up'] ?? '';
          if ((anxietyConfidence < 0.5 || depressionConfidence < 0.5)) {
            setState(() {
              _recordedText = ''; // Clear previous response
            });

            _animateQuestionChange(followUpQuestion);

          } else {
            List<Map<String, String>> suggestedActivities = [];

            if (data['suggested_activities'] != null) {
              suggestedActivities = (data['suggested_activities'] as List<dynamic>)
                  .map((activity) => {
                'activity': activity['activity'].toString(),
                'description': activity['description'].toString(),
              })
                  .toList();
            }
            Navigator.pushNamed(context, '/detection', arguments: {
              'anxiety': data['anxiety'],
              'depression': data['depression'],
              'conversationHistory': _conversationHistory,
              'suggestedActivities': suggestedActivities ?? [],
            });
          }
        } else {
          print('Failed to get API response. Status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error submitting response: $e');
      }
    }
  }

  void _startVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      try {
        await _initializeCameraFuture;
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/user_response_video.mp4';

        await _cameraController.startVideoRecording();

        setState(() {
          _videoFilePath = filePath;
          isRecording = true;
        });

        print('Video will be saved to: $filePath');
      } catch (e) {
        print('Error starting video recording: $e');
      }
    }
  }


  void _stopVideoRecording() async {
    if (_cameraController.value.isRecordingVideo) {
      try {
        XFile recordedVideo = await _cameraController.stopVideoRecording();
        setState(() {
          _videoFilePath = recordedVideo.path;
          isRecording = false;
        });

        print('Video recorded at: $_videoFilePath');

        // Submit response after video recording ends
        _submitResponse();
      } catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }

  void _animateQuestionChange(String newQuestion) async {
    await _controller.reverse();
    setState(() => _currentQuestion = newQuestion);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      _currentQuestion,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  if (isLoading) CircularProgressIndicator(),
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Column(
                      children: [
                        Icon(
                          Icons.mic,
                          size: 60,
                          color: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 10),
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
          // Camera Preview at the Top Right Corner
          Positioned(
            top: 40,
            right: 20,
            child: FutureBuilder<void>(
              future: _initializeCameraFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                    width: 120,
                    height: 160,
                    child: CameraPreview(_cameraController),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
