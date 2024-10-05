import 'package:flutter/material.dart';
import '../pages/welcome_page.dart';
import '../pages/therapist_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => WelcomePage(),
    '/therapist': (context) => TherapistPage(),
  };
}
