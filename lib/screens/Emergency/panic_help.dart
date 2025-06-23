import 'package:flutter/material.dart';
import 'package:mind_connect/constants/app_colors.dart';

class PanicHelpScreen extends StatelessWidget {
  const PanicHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(fontSize: 26, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "🧘 Panic Attack Help",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColor.linearDarkGradient,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // back arrow in white
      ),
      backgroundColor: Colors.white, // White body background
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Calming Techniques",
              style: titleStyle.copyWith(
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildTipCard("Take slow, deep breaths", Icons.air),
            _buildTipCard("Focus on your senses", Icons.visibility),
            _buildTipCard("Try grounding exercises", Icons.self_improvement),
            _buildTipCard("Listen to calming music", Icons.music_note),
            _buildTipCard("Call a friend or counselor", Icons.call),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String text, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColor.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColor.primary),
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
