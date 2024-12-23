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

  // Function to request permission dynamically
  // Future<void> _requestCameraPermission() async {
  //   final result = await Permission.camera.request();
  //   if (result.isGranted) {
  //     setState(() {
  //       isCameraActive = true;
  //     });
  //   } else {
  //     setState(() {
  //       isCameraActive = false;
  //     });
  //   }
  // }

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

  void _toggleRecording() {
    if (isRecording) {
      _speech.stop();
      if (isCameraActive) {
        _stopVideoRecording();
      }
      _submitResponse();
      setState(() => isRecording = false);
    } else {
      // Start speech recognition
      _speech.initialize().then((available) {
        if (available) {
          _speech.listen(onResult: (result) {
            setState(() {
              _recordedText = result.recognizedWords;
              print("Recorded text: $_recordedText");
            });
          });
        }
      });
      if (isCameraActive) {
        _startVideoRecording();
      }
      setState(() => isRecording = true);
    }
  }


  void _submitResponse() async {
    // if (_recordedText.isNotEmpty &&
    //     (_videoFilePath != null || !isCameraActive)) {
    //   setState(() => isLoading = true);
    //   _conversationHistory
    //       .add({"question": _currentQuestion, "answer": _recordedText});
    //   try {
    //     var request = http.MultipartRequest('POST', apiUrl);
    //     // Add the text fields to the multipart request
    //     request.fields['question'] = _currentQuestion;
    //     request.fields['answer'] = _recordedText;
    //     // Attach the video file if the camera is active
    //     if (isCameraActive && _videoFilePath != null) {
    //       request.files.add(
    //         await http.MultipartFile.fromPath(
    //           'video',
    //           _videoFilePath!,
    //         ),
    //       );
    //     }
    //     var response = await request.send();
    //     setState(() => isLoading = false);
    //     if (response.statusCode == 200) {
    //       var responseBody = await response.stream.bytesToString();
    //       var data = json.decode(responseBody);
    //       double anxietyConfidence = data['anxiety_confidence'] ?? 0;
    //       double depressionConfidence = data['depression_confidence'] ?? 0;
    //
    //       String followUpQuestion = data['follow_up'] ?? '';
    //       if ((anxietyConfidence < 0.4 || depressionConfidence < 0.4)) {
    //         setState(() {
    //           _recordedText = ''; // Clear previous response
    //         });
    //         _animateQuestionChange(followUpQuestion);
    //       } else {
    //         if (isCameraActive) {
    //           _cameraController.dispose(); // Dispose camera before navigating
    //         }
    //         List<Map<String, String>> suggestedActivities = [];
    //         if (data['suggested_activities'] != null) {
    //           suggestedActivities =
    //               (data['suggested_activities'] as List<dynamic>)
    //                   .map((activity) => {
    //                 'activity': activity['activity'].toString(),
    //                 'description': activity['description'].toString(),
    //               })
    //                   .toList();
    //         }
    //         globals.anxiety = data['anxiety'];
    //         globals.depression = data['depression'];
    //
    //         Navigator.pushNamed(context, '/detection', arguments: {
    //           // 'anxiety': data['anxiety'],
    //           // 'depression': data['depression'],
    //           'conversationHistory': _conversationHistory,
    //           'suggestedActivities': suggestedActivities ?? [],
    //         });
    //       }
    //     } else {
    //       print('Failed to get API response. Status: ${response.statusCode}');
    //     }
    //   } catch (e) {
    //     print('Error submitting response: $e');
    //   }
    // }

    final List<Map<String, String>> suggestedActivities = [];
    Navigator.pushNamed(context, '/detection', arguments: {
      'conversationHistory': _conversationHistory,
      'suggestedActivities': suggestedActivities ?? [],
    });
  }

  void _startVideoRecording() async {
    if (isCameraActive && !_cameraController.value.isRecordingVideo) {
      try {
        await _initializeCameraFuture;
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/user_response_video.mp4';
        // Ensure camera is initialized before proceeding
        if (_cameraController.value.isInitialized) {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/user_response_video.mp4';

          await _cameraController.startVideoRecording();
          // await _cameraController.startVideoRecording();

          setState(() {
            _videoFilePath = filePath;
            isRecording = true;
          });
          setState(() {
            _videoFilePath = filePath;
            isRecording = true;
          });

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
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // New background color
      body: Padding(
        padding: const EdgeInsets.only(
          top: 90, // Padding from the top
          left: 30, // Padding from the left
          right: 30, // Padding from the right
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity, // Full width
                  height: 450, // Set the height to 300 as requested

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(40), // Border radius applied here
                    // color: Colors.white, // Background color for the container
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
                      // camera on
                      ? FutureBuilder<void>(
                          future: _initializeCameraFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        40), // Apply border radius to clip the camera preview
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: double
                                            .infinity, // Make camera width fill the container
                                        height: double
                                            .infinity, // Ensure camera height fits container
                                        child: CameraPreview(_cameraController),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 15,
                                    right: 15,
                                    child: GestureDetector(
                                      onTap: _toggleCamera,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 27,
                                      ),
                                    ),
                                  ), // close button
                                ],
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ) // camera off
                      : GestureDetector(
                          //camera off
                          onTap: _toggleCamera,
                          child: const Center(
                            // Centers the content within the box
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Vertically center
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Horizontally center
                              children: [
                                Text(
                                  'Tap to turn on the camera',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w300,
                                    // color: Theme.of(context).primaryColor,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        16), // Adds spacing between text and icon
                                Icon(
                                  Icons.camera_alt,
                                  // color: Theme.of(context).primaryColor,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),

                SizedBox(
                  height: 20,
                ),
                
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center, // Ensure horizontal centering
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/therapist_avatar.png',
                          width: 50, // Set the width of the image
                          height: 50, // Set the height of the image
                          fit: BoxFit.cover, // Ensure the image fills the circular area without distortion
                        ),
                      ), // Avatar
                      const SizedBox(width: 10), // Space between the image and text
                      Text(
                        "SerenCoach",
                        textAlign: TextAlign.center,
                        key: ValueKey<String>(_currentQuestion),
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueAccent,
                        ),
                      ), // SerenCoach
                    ],
                  ),
                ),


                SizedBox(
                  height: 20,
                ),

                FadeTransition(
                  opacity: _questionAnimation,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.vertical, // Ensure the scroll is vertical
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              150, // Set a maximum height for the text box
                        ),
                        child: Text(
                          _currentQuestion,
                          key: ValueKey<String>(_currentQuestion),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ), // question
              ],
            ),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align children at the bottom
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the children horizontally
              children: [
                if (isLoading) CircularProgressIndicator(),

                // mic
                GestureDetector(
                  onTap: isLoading ? null : _toggleRecording,
                  child: Container(
                    width: double
                        .infinity, // Make the width take up the maximum available width
                    height: 60, // Set the height for the button
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.redAccent
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(
                          12), // Optional: Add border radius for rounded corners
                      border: Border.all(
                        color: Colors.white, // White border color
                        width: 1, // Border width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Shadow color
                          blurRadius: 8, // Blur effect for shadow
                          offset: Offset(0, 4), // Position the shadow
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // mic text
                Padding(
                  padding: EdgeInsets.only(top: 5), // Add some padding on top
                  child: Text(
                    isRecording ? 'Recording...' : 'Tap to speak',
                    textAlign: TextAlign.center, // Align the text to the center
                    style: TextStyle(
                      fontSize: 18,
                      color: isRecording
                          ? Colors.red
                          : Colors.blue, // Set the color to blue
                    ),
                  ),
                ),

                //skip
                Container(
                  child: widget.allowSkip
                      ? Align(
                          alignment:
                              Alignment.bottomRight, // Align to the right
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 20), // Optional padding for spacing
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              },
                              child: const Text(
                                'Skip >>', // Your text content
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black, // Set the text color
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(), // Empty container when allowSkip is true
                ),

                const SizedBox(
                    height:
                        20), // Optional: Add space between the bottom of the text and the container
              ],
            ),
          ],
        ),
      ),
    );
  }
}