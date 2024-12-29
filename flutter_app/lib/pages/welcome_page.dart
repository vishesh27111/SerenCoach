import 'package:flutter/material.dart';
import 'therapist_page.dart'; // Import TherapistPage for navigation

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
              'assets/images/welcome_image.png',
                width: 170,
                height: 170,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 40),
              Text(
                'SerenCoach',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.blueAccent,
                  letterSpacing: 1.2,
                  fontSize: 36,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Talk to your therapist. Anytime, Anywhere.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 40),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/therapist');
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Theme.of(context).colorScheme.primary,
              //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //   ),
              //   child: Text(
              //     'Get Started',
              //     style: TextStyle(
              //       fontSize: 20,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/therapist');
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your mental health matters.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}