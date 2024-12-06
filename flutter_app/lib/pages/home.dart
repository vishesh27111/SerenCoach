import 'package:flutter/material.dart';
import 'package:my_flutter_app/pages/ai-chat.dart';
import 'package:my_flutter_app/pages/chats.dart';
import 'package:my_flutter_app/pages/combat.dart';
import 'package:my_flutter_app/pages/emergency.dart';
import 'package:my_flutter_app/pages/gratitude-journaling.dart';
import 'package:my_flutter_app/pages/guided-meditation.dart';
import 'package:my_flutter_app/pages/track-progress.dart';
import '../pages/set-goals.dart';
import '../widgets/MainTile.dart';
import '../widgets/SmallTile.dart';
import '../globals.dart' as globals; // Import globals

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var anxiety = globals.anxiety ?? "low"; // Default to "low" if null
    var depression = globals.depression ?? "low"; // Default to "low" if null

    int level = getLevel(anxiety, depression);
    List<SmallTile> tiles = getTilesForLevel(level, context);

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
                  children: tiles,
                  // children: [
                  //   SmallTile(
                  //     text: 'Set Goals',
                  //     avatarPath: 'assets/images/goal.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => const SetGoalsPage())
                  //       );
                  //     },
                  //     color: Colors.red[800]
                  //   ),
                  //   SmallTile(
                  //     text: 'Your Conversations',
                  //     avatarPath: 'assets/images/chats.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => ChatsPage())
                  //       );
                  //     },
                  //     color: Colors.blue[900]
                  //   ),
                  //   SmallTile(
                  //     text: 'Track Progress',
                  //     avatarPath: 'assets/images/progress.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => TrackProgressPage())
                  //       );
                  //     },
                  //     color: Colors.green[700],
                  //   ),
                  //   SmallTile(
                  //     text: 'Gratitude Journaling',
                  //     avatarPath: 'assets/images/journal.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => GratitudeJournalPage())
                  //       );
                  //     },
                  //     color: Colors.pink[900]
                  //   ),
                  //   SmallTile(
                  //     text: 'Guided Meditation',
                  //     avatarPath: 'assets/images/guided.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => GuidedMeditationsPage())
                  //       );
                  //     },
                  //     color: Colors.deepPurple,
                  //   ),
                  //   SmallTile(
                  //     text: 'Combat anxiety and depression',
                  //     avatarPath: 'assets/images/combat.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => ArticlePage())
                  //       );
                  //     },
                  //     color: Colors.deepOrange[200],
                  //   ),
                  //   SmallTile(
                  //     text: 'Chat with AI Therapist',
                  //     avatarPath: 'assets/images/ai.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => ChatWithTherapistPage())
                  //       );
                  //     },
                  //     color: Colors.orange,
                  //   ),
                  //   SmallTile(
                  //     text: 'Seek urgent help',
                  //     avatarPath: 'assets/images/emergency.png',
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => EmergencyPage())
                  //       );
                  //     },
                  //     color: Colors.red[900],
                  //   ),
                  // ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Return the tiles to display based on level
  List<SmallTile> getTilesForLevel(int level, BuildContext context) {

    List<SmallTile> alwaysDisplayedTiles = [
      SmallTile(
          text: 'Set Goals',
          avatarPath: 'assets/images/goal.png',
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetGoalsPage())
            );
          },
          color: Colors.red[800]
      ),
      SmallTile(
          text: 'Your Conversations',
          avatarPath: 'assets/images/chats.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatsPage())
            );
          },
          color: Colors.blue[900]
      ),
      SmallTile(
          text: 'Track Progress',
          avatarPath: 'assets/images/progress.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrackProgressPage())
          );
        },
        color: Colors.green[700],
      )
    ];

    if (level == 0) {
      return [...alwaysDisplayedTiles, ...
        [
          SmallTile(
            text: 'Gratitude Journaling',
            avatarPath: 'assets/images/journal.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GratitudeJournalPage()),
              );
            },
            color: Colors.pink[900],
          ),
          SmallTile(
            text: 'Guided Meditation',
            avatarPath: 'assets/images/guided.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GuidedMeditationsPage()),
              );
            },
            color: Colors.deepPurple,
          ),
          SmallTile(
            text: 'Combat anxiety and depression',
            avatarPath: 'assets/images/combat.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArticlePage()),
              );
            },
            color: Colors.deepOrange[200],
          ),
        ]
      ];
    } else if (level == 1) {
      return [...alwaysDisplayedTiles, ...
        [
          SmallTile(
            text: 'Guided Meditation',
            avatarPath: 'assets/images/guided.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GuidedMeditationsPage()),
              );
            },
            color: Colors.deepPurple,
          ),
          SmallTile(
          text: 'Chat with AI Therapist',
          avatarPath: 'assets/images/ai.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatWithTherapistPage()),
            );
          },
          color: Colors.orange,
        ),
        ]
      ];
    } else if (level == 2) {
      return [ ...alwaysDisplayedTiles, ...
        [
          SmallTile(
            text: 'Chat with AI Therapist',
            avatarPath: 'assets/images/ai.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatWithTherapistPage()),
              );
            },
            color: Colors.orange,
          ),
          SmallTile(
            text: 'Seek urgent help',
            avatarPath: 'assets/images/emergency.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmergencyPage()),
              );
            },
            color: Colors.red[900],
          ),
        ]
      ];
    }

    return alwaysDisplayedTiles;
  }

  int getLevel(String anxiety, String depression){
    if (anxiety=="low" && depression=="low"){
      return 0;
    }
    else if(anxiety=="high" || depression=="high"){
      return 2;
    }
    else{
      return 1;
    }
  }
}