import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_tracker/mood_tracker.dart';
import 'meditation/meditation.dart';
import 'forum/forum_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Emergency/emergency_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userEmail;
  const DashboardScreen({super.key, required this.userEmail});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildMainDashboard(),
      const SessionsListPage(),
      ForumHomeScreen(),
      MoodTrackerPage(userEmail: widget.userEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FF),
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF2D5DCA),
          unselectedItemColor: Colors.grey.shade500,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Meditate'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Community'),
            BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Mood'),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF0FF), Color(0xFFF4F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildTasksBanner(),
          const SizedBox(height: 28),
          Text(
            "Tools for a Better You",
            style: GoogleFonts.lexend(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D5DCA),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureTile(
            icon: Icons.mood,
            title: "Mood Journal",
            subtitle: "Track your daily emotions",
            onTap: () => setState(() => _currentIndex = 3),
          ),
          _buildFeatureTile(
            icon: Icons.spa,
            title: "Guided Meditations",
            subtitle: "Relax your mind and body",
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _buildFeatureTile(
            icon: Icons.people_alt,
            title: "Community Forum",
            subtitle: "Connect with others",
            onTap: () => setState(() => _currentIndex = 2),
          ),
          _buildFeatureTile(
            icon: Icons.call,
            title: "Emergency Contact",
            subtitle: "Get urgent help now",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnhancedEmergencyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context, Offset offset) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(offset, offset),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(value: 'profile', child: Text('View Profile')),
        const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
      ],
    );

    if (selected == 'profile') {
      Navigator.pushNamed(context, '/profile', arguments: widget.userEmail);
    } else if (selected == 'logout') {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildWelcomeCard() {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showProfileMenu(context, details.globalPosition);
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF92A3FD), Color(0xFF9DCEFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9DCEFF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 36, color: Color(0xFF244C98)),
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back,", style: GoogleFonts.lexend(color: Colors.white70, fontSize: 14)),
                Text(
                  widget.userEmail.split('@')[0],
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTasksBanner() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF9DCEFF), Color(0xFF92A3FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Check today’s wellness goals →",
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA1B5FF).withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF92A3FD), Color(0xFF9DCEFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.lexend(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.lexend(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
