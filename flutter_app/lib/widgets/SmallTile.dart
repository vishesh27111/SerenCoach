import 'package:flutter/material.dart';

// Widget for Small Tiles
class SmallTile extends StatelessWidget {
  final String text;
  final String avatarPath;
  final VoidCallback onTap;
  final Color? color;

  const SmallTile({
    Key? key,
    required this.text,
    required this.avatarPath,
    required this.onTap,
    this.color, // Required gradient colors
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color != null
                ? [color!, Color(0xFFB0C4DE)
              // color!.withOpacity(0.3)
            ] // Use provided color with a gradient effect
                : [Color(0xFF4A90E2), Color(0xFFB0C4DE)], // Default gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 5), // Shadow position
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(avatarPath),
              backgroundColor: Colors.white,
              radius: 40.0, // Smaller avatar for small tiles
            ),
            const SizedBox(height: 10.0),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}