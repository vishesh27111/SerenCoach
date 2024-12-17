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
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fetchStars();
    checkGoalsForExpiration(); // Call this function when the page loads
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier<int> totalStarsNotifier = ValueNotifier<int>(0);
  // HomePage({Key? key}) : super(key: key);
  int level = globals.level;

  void fetchStars() async {
    int stars = await _fetchTotalStars();
    totalStarsNotifier.value = stars;
  }

  void checkGoalsForExpiration() async {
    try {
      final response = await http.get(Uri.parse('${globals.api_base_url}/goals'));
      if (response.statusCode == 200) {
        final goals = json.decode(response.body) as List;
        for (var goal in goals) {
          DateTime deadline = DateTime.parse(goal['deadline']);
          if (goal['status'] == 'in-progress' && deadline.isBefore(DateTime.now())) {
            // Goal is past the deadline, mark it as expired
            await _updateGoalStatus(goal['_id'], 'expired');
          }
        }
      }
    } catch (e) {
      // Handle error
      print('Error checking goals for expiration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    List<SmallTile> tiles = getTilesForLevel(level, context);

    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ValueListenableBuilder<int>(
          valueListenable: totalStarsNotifier,
          builder: (context, totalStars, child) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SerenCoach',
                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Stars Earned: $totalStars',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                  title: Text('Profile', style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {},
                ),
                // ListTile(
                //   leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                //   title: Text('Notifications', style: Theme.of(context).textTheme.bodyLarge),
                //   onTap: () {},
                // ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
                  title: Text('Logout', style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {},
                ),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 40.0),
                    const MainTile(),
                    const SizedBox(height: 20.0),

                    // Personalized Features Section
                    _buildPersonalizedFeatures(level, context),

                    // Common Features Section
                    _buildCommonFeatures(tiles, context),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16.0,
              left: 16.0,
              child: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, size: 28),
                  onPressed: () {
                    fetchStars();
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedFeatures(int level, BuildContext context) {
    final personalizedTiles = getTilesForLevel(level, context)
        .where((tile) => tile.text != 'Set Goals' && tile.text != 'Your Conversations' && tile.text != 'Track Progress')
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended therapies for you',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 10.0),
          GridView.builder(
            shrinkWrap: true, // Allows GridView to adjust height
            physics: NeverScrollableScrollPhysics(), // Disables GridView's scrolling
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: personalizedTiles.length,
            itemBuilder: (context, index) {
              return personalizedTiles[index];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFeatures(List<SmallTile> tiles, BuildContext context) {
    final commonTiles = tiles.where((tile) => tile.text == 'Set Goals' || tile.text == 'Your Conversations' || tile.text == 'Track Progress').toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Activity',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 10.0),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: commonTiles.length,
            itemBuilder: (context, index) {
              return commonTiles[index];
            },
          ),
        ],
      ),
    );
  }

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
              MaterialPageRoute(builder: (context) => MeditationPage()),
            );
          },
          color: Colors.deepPurple,
        ),
        SmallTile(
          text: 'Self-help resources from experts',
          avatarPath: 'assets/images/combat.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArticleListPage()),
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
              MaterialPageRoute(builder: (context) => MeditationPage()),
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

  Future<int> _fetchTotalStars() async {
    try {
      final response = await http.get(Uri.parse('${globals.api_base_url}/total_stars'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['total_stars'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<void> _updateGoalStatus(String goalId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${globals.api_base_url}/update_goal/$goalId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        print('Goal $goalId status updated to $status');
      } else {
        print('Failed to update goal status: ${response.body}');
      }
    } catch (e) {
      print('Error updating goal status: $e');
    }
  }

}