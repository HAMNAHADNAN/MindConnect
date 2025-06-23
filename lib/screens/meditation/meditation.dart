import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_connect/constants/app_colors.dart';

class SessionsListPage extends StatefulWidget {
  const SessionsListPage({super.key});

  @override
  State<SessionsListPage> createState() => _SessionsListPageState();
}

class _SessionsListPageState extends State<SessionsListPage> {
  final List<String> categories = ['Angry', 'Confused', 'Happy', 'stress'];
  String selectedCategory = 'Happy';
  List<Map<String, dynamic>> sessionList = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises(selectedCategory);
  }

  Future<void> _fetchExercises(String mood) async {
    final snap = await FirebaseFirestore.instance
        .collection('moods')
        .doc(mood)
        .collection('exercise')
        .get();

    setState(() {
      sessionList = snap.docs.map((d) {
        final m = d.data();
        return {
          'title': m['title'] ?? 'Untitled',
          'duration': m['duration'] ?? 'Unknown',
          'description': m['description'] ?? 'No description',
          'imageUrl': m['imageURL'] ?? '',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
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
        title: const Text(
          'Meditation & Self-Help',
          style: TextStyle(color: AppColor.contentBg, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildMoodStrip(),
            const SizedBox(height: 20),
            Expanded(child: _buildExerciseList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodStrip() => SizedBox(
    height: 140,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        final sel = cat == selectedCategory;
        return GestureDetector(
          onTap: () {
            setState(() => selectedCategory = cat);
            _fetchExercises(cat);
          },
          child: Container(
            width: 160,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: sel
                  ? const LinearGradient(
                colors: AppColor.darkGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: sel ? null : AppColor.contentBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: sel
                  ? [
                BoxShadow(
                  color: AppColor.dark.withOpacity(.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
                  : null,
            ),
            child: Center(
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: sel ? AppColor.contentBg : AppColor.dark,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildExerciseList(BuildContext ctx) => sessionList.isEmpty
      ? const Center(child: Text('No exercises found.'))
      : ListView.builder(
    itemCount: sessionList.length,
    itemBuilder: (_, i) {
      final s = sessionList[i];
      return Card(
        color: AppColor.contentBg,
        shadowColor: Colors.black12,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.self_improvement, color: AppColor.dark),
          title: Text(s['title']),
          subtitle: Text('Duration: ${s['duration']}'),
          trailing: const Icon(Icons.play_arrow, color: AppColor.primary),
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ExerciseDetailPage(
                title: s['title'],
                description: s['description'],
                imageUrl: s['imageUrl'],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class ExerciseDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const ExerciseDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      // ExerciseDetailPage AppBar (Readable Title + Gradient Background)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColor.darkGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColor.contentBg,
            letterSpacing: 1.1,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.contentBg),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.contentBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // Inside ExerciseDetailPage -> body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColor.dark,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: AppColor.primary),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColor.darkGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // TODO: Start exercise action
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.play_arrow, color: AppColor.contentBg),
                            SizedBox(width: 8),
                            Text(
                              "Start Exercise",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColor.contentBg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
