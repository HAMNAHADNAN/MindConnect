import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_tracker/mood_tracker.dart';

class DashboardScreen extends StatefulWidget {
  final String userEmail;
  //final String profileImageUrl;

  const DashboardScreen({
    super.key,
    required this.userEmail,
    //required this.profileImageUrl,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Placeholder(), // Replace with Mood Tracker page
    Placeholder(), // Replace with Meditation page
    Placeholder(), // Replace with Community page
    Placeholder(), // Replace with Profile/settings page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: _currentIndex == 0 ? _buildMainDashboard() : _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF244C98),
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: 'Meditation'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // CircleAvatar(
              // radius: 28,
              // backgroundImage: AssetImage(widget.profileImageUrl),
              // ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    widget.userEmail,
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF244C98),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
          //     image: const DecorationImage(
          //       image: AssetImage("assets/bg_image.png"),
          //       fit: BoxFit.cover,
          // ),
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
          
                const SizedBox(height: 6),
                Text(
                  "View your self-care tasks for today →",
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: const Color(0xFF244C98),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              buildTile(context, "Mood Tracker", Icons.mood, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoodTrackerPage(userEmail: widget.userEmail),
                  ),
                );
              }),
              buildTile(context, "Meditation", Icons.self_improvement, () {}),
              buildTile(context, "Therapist", Icons.support_agent, () {}),
              buildTile(context, "Community", Icons.group, () {}),
              buildTile(context, "Emergency Help", Icons.warning, () {}),
            ],
          ),

        ]
      )
    );
  }

  Widget buildTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF244C98)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF244C98),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
