import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({Key? key}) : super(key: key);

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
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
  final TextEditingController _noteController = TextEditingController();
  final List<Map<String, String>> moodHistory = [];

  late DatabaseReference moodRef;

  @override
  void initState() {
    super.initState();
    moodRef = FirebaseDatabase.instance.ref().child('moods');
    fetchMoodHistory();
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
                final mood = value['mood'] ?? 'assets/emojis/sleepy.png';
                final note = value['note'] ?? 'No note';
                final date = value['date'] ?? 'Unknown';

                moodHistory.add({
                  'mood': mood,
                  'note': note,
                  'date': date,
                });
              }
            });
          });
        });
      }
    });
  }

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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Hi there! 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF244C98),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'How are you feeling today?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mood Selector
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
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
                                          color: isSelected
                                              ? const Color(0xFF446CB6)
                                              : const Color(0xFFAFCBEA),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: Colors.blueAccent.withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 3,
                                              ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            moods[index]['emoji']!,
                                            height: isSelected ? 70 : 65,
                                            width: isSelected ? 70 : 65,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        moods[index]['label']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF244C98),
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

                        // Notes
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Write your thoughts...",
                            fillColor: Colors.white.withOpacity(0.8),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Submit Button
                        ElevatedButton.icon(
                          onPressed: submitMood,
                          icon: const Icon(Icons.send),
                          label: Text(
                            "Submit",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF244C98),
                            foregroundColor: Colors.white,
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

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mood History",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF244C98),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Mood History List
              Expanded(
                child: moodHistory.isEmpty
                    ? Center(
                  child: Text(
                    "No moods tracked yet!",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                )
                    : ListView.builder(
                  itemCount: moodHistory.length,
                  itemBuilder: (context, index) {
                    final entry = moodHistory[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          entry['mood'] ?? 'assets/emojis/neutral.png',
                          height: 40,
                          width: 40,
                        ),
                        title: Text(entry['note'] ?? ''),
                        subtitle: Text(entry['date'] ?? ''),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
