import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SerenCoach',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // To handle JSON
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   final ThemeData lightTheme = ThemeData(
//     brightness: Brightness.light,
//     scaffoldBackgroundColor: Color(0xFFF7F8FA),
//     colorScheme: ColorScheme.light(
//       primary: Color(0xFF4A90E2),
//       secondary: Color(0xFF6495ED),
//     ),
//     textTheme: TextTheme(
//       headlineLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: Color(0xFF333333),
//       ),
//       bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF666666)),
//     ),
//   );
//
//   final ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: Color(0xFF1E1E1E),
//     colorScheme: ColorScheme.dark(
//       primary: Color(0xFF4A90E2),
//       secondary: Color(0xFFB0C4DE),
//     ),
//     textTheme: TextTheme(
//       headlineLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: Color(0xFFF1F1F1),
//       ),
//       bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFB0B0B0)),
//     ),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SerenCoach',
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: ThemeMode.system,
//       home: WelcomePage(),
//     );
//   }
// }
//
// class WelcomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 15,
//                       offset: Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Image.asset(
//                   'assets/images/welcome_image.png',
//                   height: 150,
//                   width: 150,
//                 ),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 'SerenCoach',
//                 style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                   color: Theme.of(context).colorScheme.primary,
//                   letterSpacing: 1.2,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 4.0,
//                       color: Theme.of(context).colorScheme.secondary,
//                       offset: Offset(1, 2),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'Talk to your therapist. Anytime, Anywhere.',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w400,
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//               ),
//               SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).push(_createRoute());
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).colorScheme.primary,
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   shadowColor: Colors.black.withOpacity(0.2),
//                   elevation: 10,
//                 ),
//                 child: Text(
//                   'Get Started',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Your mental health matters.',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Create route with animation for the next page transition
// Route _createRoute() {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => TherapistScreen(),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       const begin = Offset(1.0, 0.0);
//       const end = Offset.zero;
//       const curve = Curves.ease;
//
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }
//
//
// class TherapistScreen extends StatefulWidget {
//   @override
//   _TherapistScreenState createState() => _TherapistScreenState();
// }
//
// class _TherapistScreenState extends State<TherapistScreen>
//     with SingleTickerProviderStateMixin {
//   bool isRecording = false;
//   String recognizedText = '';
//   String anxietyLevel = '';
//   String depressionLevel = '';
//   String errorMessage = '';
//   late AnimationController _controller;
//   late Animation _colorAnimation;
//   late Animation _questionAnimation;
//   stt.SpeechToText _speech = stt.SpeechToText();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
//     _colorAnimation = ColorTween(
//       begin: Theme.of(context).colorScheme.primary,
//       end: Colors.red,
//     ).animate(_controller);
//     _questionAnimation = Tween(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//     _initializeSpeechRecognition();
//   }
//
//   Future<void> _initializeSpeechRecognition() async {
//     bool available = await _speech.initialize();
//     if (!available) {
//       setState(() {
//         errorMessage = 'Speech recognition not available';
//       });
//     }
//   }
//
//   Future<void> _toggleRecording() async {
//     if (!isRecording) {
//       bool available = await _speech.initialize();
//       if (available) {
//         setState(() {
//           isRecording = true;
//           recognizedText = 'Listening...';
//         });
//         _controller.forward();
//         _speech.listen(
//           onResult: (result) {
//             setState(() {
//               recognizedText = result.recognizedWords;
//             });
//           },
//         );
//       }
//     } else {
//       setState(() {
//         isRecording = false;
//       });
//       _controller.reverse();
//       _speech.stop();
//       await _sendToTherapistApi(recognizedText);
//     }
//   }
//
//   Future<void> _sendToTherapistApi(String userInput) async {
//     final apiUrl = 'http://127.0.0.1:5000/therapist';
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "response": userInput,
//         }),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           anxietyLevel = data['anxiety'] ?? 'Unknown';
//           depressionLevel = data['depression'] ?? 'Unknown';
//           errorMessage = '';
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Error: Failed to get a valid response from the API';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error: $e';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ... (rest of the build method remains the same)
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _speech.cancel();
//     super.dispose();
//   }
// }