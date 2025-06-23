import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_connect/constants/app_colors.dart';

class MoodTrackerPage extends StatefulWidget {
  final String userEmail;

  const MoodTrackerPage({required this.userEmail, super.key});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  String? _userName;
  String? _userKey;
  late DatabaseReference moodRef;
  final TextEditingController _noteController = TextEditingController();
  final List<Map<String, String?>> moodHistory = [];

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    final DataSnapshot snapshot = await dbRef.child('users').get();

    if (snapshot.exists) {
      final users = snapshot.value as Map<dynamic, dynamic>;
      String? foundName;
      String? foundKey;

      users.forEach((key, value) {
        if (value['email'] == widget.userEmail) {
          foundName = value['name'];
          foundKey = key;
        }
      });

      if (foundName != null && foundKey != null) {
        setState(() {
          _userName = foundName;
          _userKey = foundKey;
          moodRef = FirebaseDatabase.instance.ref().child('users/$_userKey/moods');
        });
        fetchMoodHistory();
      }
    }
  }

  void fetchMoodHistory() async {
    moodRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            moodHistory.clear();
            (data as Map).forEach((key, value) {
              if (value is Map) {
                final mood = value['mood'] ?? 'assets/emojis/neutral.png';
                final note = value['note'] ?? 'No note';
                final date = value['date'] ?? 'Unknown';

                moodHistory.add({
                  'mood': mood,
                  'note': note,
                  'date': date,
                  'key': key,
                });
              }
            });
          });
        });
      }
    });
  }

  final List<Map<String, String>> moods = [
    {'emoji': 'assets/emojis/sleepy.png', 'label': 'Sleepy'},
    {'emoji': 'assets/emojis/surprised.png', 'label': 'Surprised'},
    {'emoji': 'assets/emojis/happy.png', 'label': 'Happy'},
    {'emoji': 'assets/emojis/sad.png', 'label': 'Sad'},
    {'emoji': 'assets/emojis/angry.png', 'label': 'Angry'},
    {'emoji': 'assets/emojis/excited.png', 'label': 'Excited'},
    {'emoji': 'assets/emojis/bored.png', 'label': 'Bored'},
    {'emoji': 'assets/emojis/confused.png', 'label': 'Confused'},
    {'emoji': 'assets/emojis/love.png', 'label': 'Loved'},
    {'emoji': 'assets/emojis/neutral.png', 'label': 'Neutral'},
  ];

  String? selectedMoodPath;
  String? selectedMoodLabel;

  void submitMood() async {
    if (selectedMoodPath != null && _noteController.text.isNotEmpty) {
      final newEntry = {
        'mood': selectedMoodPath!,
        'note': _noteController.text,
        'date': DateTime.now().toLocal().toString().split(' ')[0],
      };

      setState(() {
        moodHistory.insert(0, newEntry);
      });

      await moodRef.push().set(newEntry);

      selectedMoodPath = null;
      selectedMoodLabel = null;
      _noteController.clear();
    }
  }

  void deleteMoodHistory(String key) async {
    await moodRef.child(key).remove();
    setState(() {
      moodHistory.removeWhere((entry) => entry['key'] == key);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(
          'Mood Tracker',
          style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColor.darkGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName != null ? 'Hi, $_userName 👋' : 'Loading...',
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColor.dark,
                  ),
                ),
                Text(
                  'How are you feeling today?',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColor.darkGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: moods.length,
                              itemBuilder: (context, index) {
                                final isSelected = selectedMoodPath == moods[index]['emoji'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMoodPath = moods[index]['emoji'];
                                      selectedMoodLabel = moods[index]['label'];
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          height: isSelected ? 70 : 55,
                                          width: isSelected ? 70 : 55,
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              if (isSelected)
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.6),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              moods[index]['emoji']!,
                                              height: isSelected ? 70 : 60,
                                              width: isSelected ? 70 : 60,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          moods[index]['label']!,
                                          style: GoogleFonts.lexend(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Write your thoughts...",
                              fillColor: Colors.white.withOpacity(0.9),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: submitMood,
                            icon: const Icon(Icons.send),
                            label: Text(
                              "Submit",
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColor.dark,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 10),
                Text(
                  "Mood History",
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.dark,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: moodHistory.length,
                  itemBuilder: (context, index) {
                    final entry = moodHistory[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColor.darkGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          entry['mood'] ?? 'assets/emojis/neutral.png',
                          height: 40,
                          width: 40,
                        ),
                        title: Text(
                          entry['note'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          entry['date'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            deleteMoodHistory(entry['key']!);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
