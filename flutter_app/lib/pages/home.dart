import 'package:flutter/material.dart';
import '../pages/set-goals.dart';
import '../widgets/MainTile.dart';
import '../widgets/SmallTile.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title "SerenCoach"
              Center(
                child: Text(
                  'SerenCoach',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40.0), // Space between title and main tile

              // Main "Talk to SerenCoach again" Tile
              const MainTile(),

              const SizedBox(height: 20.0), // Space between main and smaller tiles

              // 2x2 Grid of Smaller Tiles
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // 2 columns
                  mainAxisSpacing: 16.0, // Space between rows
                  crossAxisSpacing: 16.0, // Space between columns
                  childAspectRatio: 1.0, // Ensures the tiles are square
                  children: [
                    SmallTile(
                      text: 'Set Goals',
                      avatarPath: 'assets/images/therapist_avatar.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SetGoalsPage())
                        );
                      },
                    ),
                    SmallTile(
                      text: 'Set Goals',
                      avatarPath: 'assets/images/therapist_avatar.png',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SetGoalsPage())
                        );
                      },
                    ),
                    SmallTile(
                      text: 'Set Goals',
                      avatarPath: 'assets/images/therapist_avatar.png',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SetGoalsPage())
                        );
                      },
                    ),
                    SmallTile(
                      text: 'Set Goals',
                      avatarPath: 'assets/images/therapist_avatar.png',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SetGoalsPage())
                        );
                      },
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