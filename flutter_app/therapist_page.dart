import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import '../globals.dart' as globals;
import 'package:permission_handler/permission_handler.dart';

class TherapistPage extends StatefulWidget {
  final bool allowSkip;
  TherapistPage({this.allowSkip = false});
  @override
  _TherapistPageState createState() => _TherapistPageState();
}

class _TherapistPageState extends State<TherapistPage>
    with TickerProviderStateMixin {
  bool isRecording = false;
  bool isLoading = false;
  bool isListening = false; // To check whether speech-to-text is listening
  bool isCameraActive = false;
  late stt.SpeechToText _speech;
  String _recordedText = '';
  late AnimationController _controller;
  late Animation<double> _avatarAnimation;
  late Animation<double> _questionAnimation;
  final apiUrl = Uri.parse('${globals.api_base_url}/detect');
  String _currentQuestion = "How are you feeling today?";
  List<Map<String, String>> _conversationHistory = [];
  late CameraController _cameraController;
  late Future<void> _initializeCameraFuture;
  String? _videoFilePath;
  @override
  void initState() {
    super.initState();
    _initializeCameraState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _avatarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    _speech = stt.SpeechToText();

    _initializeCamera();

    checkResources().then((resourcesAvailable) {
      if (resourcesAvailable) {
        _initializeCamera();
        // _initializeSpeech();
      } else {
        print("Resources unavailable");
      }
    });
  }

  Future<void> _initializeCameraState() async {
    // Check if the camera permission is granted
    final cameraPermissionStatus = await Permission.camera.status;
    if (cameraPermissionStatus.isGranted) {
      setState(() {
        isCameraActive = true;
      });
    } else {
      setState(() {
        isCameraActive = false;
      });
    }
  }

  Future<bool> checkResources() async {
    final micPermission = await Permission.microphone.isGranted;
    final cameraPermission = await Permission.camera.isGranted;

    if (!micPermission || !cameraPermission) {
      await [Permission.microphone, Permission.camera].request();
    }

    return micPermission && cameraPermission;
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

  void _toggleCamera() async {
    // _requestCameraPermission();
    if (isCameraActive) {
      await _cameraController.dispose();
      setState(() => isCameraActive = false);
    } else {
      _initializeCamera();
      setState(() => isCameraActive = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (isCameraActive) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  void _toggleRecording() async {
    if (isRecording) {
      // Stop recording
      setState(() {
        isRecording = false;
      });
      await _speech.stop();
      if (isCameraActive) {
        _stopVideoRecording();
      }
      print("Recording stopped. Recorded Text: $_recordedText");

      // Call submitResponse to submit the recorded text
      _submitResponse();
    } else {
      // Start recording
      setState(() {
        isRecording = true;
        _recordedText = ''; // Clear previous text
      });

      if (isCameraActive) {
        _startVideoRecording();
      }

      bool available = await _speech.initialize();
      if (available) {
        // Start listening and convert speech to text
        _speech.listen(onResult: (result) {
          setState(() {
            _recordedText = result.recognizedWords;
          });
          print("Recognized Text: ${result.recognizedWords}");
        });
      } else {
        print("Speech recognition not available");
        setState(() {
          isRecording = false;
        });
      }
    }
  }

  void _submitResponse() async {
    print("REcorded Text --------------------");
    print(_recordedText);
    print("Cond ???????????????????????");
    print(_recordedText.isNotEmpty);
    print(_videoFilePath != null || !isCameraActive);
    print("Video path");
    print(_videoFilePath);
    print(!isCameraActive);
    if (_recordedText.isNotEmpty &&
        (_videoFilePath != null || !isCameraActive)) {
      print("Inside ###################################");
      setState(() => isLoading = true);
      _conversationHistory
          .add({"question": _currentQuestion, "answer": _recordedText});
      try {
        var request = http.MultipartRequest('POST', apiUrl);
        // Add the text fields to the multipart request
        request.fields['question'] = _currentQuestion;
        request.fields['answer'] = _recordedText;
        // Attach the video file if the camera is active
        if (isCameraActive && _videoFilePath != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'video',
              _videoFilePath!,
            ),
          );
        }
        var response = await request.send();
        setState(() => isLoading = false);
        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          var data = json.decode(responseBody);
          double anxietyConfidence = data['anxiety_confidence'] ?? 0;
          double depressionConfidence = data['depression_confidence'] ?? 0;

          String followUpQuestion = data['follow_up'] ?? '';
          if ((anxietyConfidence < 0.4 || depressionConfidence < 0.4)) {
            setState(() {
              _recordedText = ''; // Clear previous response
            });
            _animateQuestionChange(followUpQuestion);
          } else {
            if (isCameraActive) {
              _cameraController.dispose(); // Dispose camera before navigating
            }
            List<Map<String, String>> suggestedActivities = [];
            if (data['suggested_activities'] != null) {
              suggestedActivities =
                  (data['suggested_activities'] as List<dynamic>)
                      .map((activity) => {
                    'activity': activity['activity'].toString(),
                    'description': activity['description'].toString(),
                  })
                      .toList();
            }
            globals.anxiety = data['anxiety'];
            globals.depression = data['depression'];

            Navigator.pushNamed(context, '/detection', arguments: {
              // 'anxiety': data['anxiety'],
              // 'depression': data['depression'],
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

    // final List<Map<String, String>> suggestedActivities = [];
    // Navigator.pushNamed(context, '/detection', arguments: {
    //   'conversationHistory': _conversationHistory,
    //   'suggestedActivities': suggestedActivities ?? [],
    // });
  }

  void _startVideoRecording() async {
    if (isCameraActive && !_cameraController.value.isRecordingVideo) {
      try {
        await _initializeCameraFuture;
        // final directory = await getTemporaryDirectory();
        // final filePath = '${directory.path}/user_response_video.mp4';
        // Ensure camera is initialized before proceeding
        if (_cameraController.value.isInitialized) {
          // final directory = await getTemporaryDirectory();
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/user_response_video.mp4';

          await _cameraController.startVideoRecording();

          setState(() {
            _videoFilePath = filePath;
            isRecording = true;
          });
          // setState(() {
          //   _videoFilePath = filePath;
          //   isRecording = true;
          // });

          print('Video will be saved to: $filePath');
          // print('Video will be saved to: $filePath');
        }
      } catch (e) {
        print('Error starting video recording: $e');
      }
    }
  }

  void _stopVideoRecording() async {
    if (isCameraActive && _cameraController.value.isRecordingVideo) {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.1, // Adjust top padding dynamically
          left: screenWidth * 0.08, // Adjust left padding dynamically
          right: screenWidth * 0.08, // Adjust right padding dynamically
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.5, // Adjust dynamically for smaller devices
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isCameraActive
                      ? FutureBuilder<void>(
                    future: _initializeCameraFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _cameraController.value.previewSize?.width ?? 0,
                                    height: _cameraController.value.previewSize?.height ?? 0,
                                    child: CameraPreview(_cameraController),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 15,
                                right: 15,
                                child: GestureDetector(
                                  onTap: _toggleCamera,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 27,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                      : GestureDetector(
          onTap: _toggleCamera, // Toggle the camera when tapped
          child: Center(
            // Center the content when the camera is off
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap to turn on the camera',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07, // Scale text size
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: screenWidth * 0.1, // Scale icon size
                ),
              ],
            ),
          ),
        ),

      ),

                SizedBox(height: screenHeight * 0.03), // Adjust dynamically
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/therapist_avatar.png',
                          width: screenWidth * 0.12, // Scale avatar size
                          height: screenWidth * 0.12,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        "SerenCoach",
                        key: ValueKey<String>(_currentQuestion),
                        style: TextStyle(
                          fontSize: screenWidth * 0.09, // Scale text size
                          fontWeight: FontWeight.w700,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                FadeTransition(
                  opacity: _questionAnimation,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: SingleChildScrollView(
                      child: Text(
                        _currentQuestion,
                        key: ValueKey<String>(_currentQuestion),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.055, // Scale text size
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isLoading) CircularProgressIndicator(),
                GestureDetector(
                  onTap: isLoading ? null : _toggleRecording,
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.07, // Adjust button height
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.redAccent
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.mic,
                        size: screenWidth * 0.1, // Scale icon size
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Text(
                    isRecording ? 'Recording...' : 'Tap to speak',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // Scale text size
                      color: isRecording ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
                if (widget.allowSkip)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.05),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text(
                          'Skip >>',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ],
        ),
      ),
    );
  }
}