import 'package:flutter/material.dart';
import '../pages/detection.dart';
import '../pages/welcome_page.dart';
import '../pages/therapist_page.dart';

class AppRoutes {
  // Change this to a static variable
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => WelcomePage(),
    '/therapist': (context) => TherapistPage(),
    // Uncomment and fix this route when necessary:
    // '/detection': (context) => (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>).let((args) {
    //   return Detection(
    //     anxiety: args['anxiety'],
    //     depression: args['depression'],
    //     conversationHistory: args['conversationHistory'],
    //   );
    // }),
  };
}
