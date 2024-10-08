import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Widget for the Main Tile
class MainTile extends StatelessWidget {
  const MainTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/therapist');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.width * 0.55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4A90E2),
                const Color(0xFFB0C4DE),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 20,
                offset: const Offset(0, 10), // Shadow position
              ),
            ],
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.01).animate(
                CurvedAnimation(
                  parent: AnimationController(
                    duration: const Duration(milliseconds: 500),
                    vsync: TestVSync(),
                  )..repeat(reverse: true),
                  curve: Curves.easeInOut,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Therapist Avatar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundImage: const AssetImage('assets/images/therapist_avatar.png'), // Replace with actual avatar
                      radius: 50.0,
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  // Tile Text
                  Expanded(
                    child: Text(
                      'Talk to SerenCoach again',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// TestVSync implementation for AnimationController
class TestVSync extends TickerProvider {
  @override
  Ticker createTicker(onTick) => Ticker(onTick);
}