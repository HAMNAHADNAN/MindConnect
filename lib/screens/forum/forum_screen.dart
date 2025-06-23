import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mind_connect/constants/app_colors.dart';

class Post {
  String id;
  String title;
  String content;
  String category;
  List<Map<String, String>> comments;
  DateTime createdAt;
  String author;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.comments,
    required this.createdAt,
    required this.author,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'category': category,
    'comments': comments,
    'createdAt': createdAt.toIso8601String(),
    'author': author,
  };

  factory Post.fromJson(String id, Map<dynamic, dynamic> data) {
    return Post(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      comments: List<Map<String, String>>.from(
        (data['comments'] ?? []).map<Map<String, String>>(
              (item) => Map<String, String>.from(item),
        ),
      ),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      author: data['author'] ?? 'Anonymous',
    );
  }
}

class ForumHomeScreen extends StatefulWidget {
  @override
  _ForumHomeScreenState createState() => _ForumHomeScreenState();
}

class _ForumHomeScreenState extends State<ForumHomeScreen> {
  final database = FirebaseDatabase.instance.ref("posts");
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    database.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final loadedPosts = data.entries.map((e) {
          return Post.fromJson(e.key, Map<String, dynamic>.from(e.value));
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          posts = loadedPosts;
        });
      } else {
        setState(() {
          posts = [];
        });
      }
    });
  }

  void _addNewPost(Post post) {
    final newRef = database.push();
    post.id = newRef.key!;
    newRef.set(post.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(gradient: AppColor.linearDarkGradient),
          child: AppBar(
            title: Text('MindConnect Forum'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            color: AppColor.contentBg,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              title: Text(post.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${post.category} • by ${post.author}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewPostScreen(post: post),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColor.buttonGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Make button background transparent
              shadowColor: Colors.transparent, // Remove shadow for cleaner look
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Create New Post'),
            onPressed: () async {
              final newPost = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatePostScreen()),
              );
              if (newPost != null) _addNewPost(newPost);
            },
          ),
        ),
      ),
    );
  }
}

class ViewPostScreen extends StatefulWidget {
  final Post post;
  ViewPostScreen({required this.post});

  @override
  _ViewPostScreenState createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  final _dbRef = FirebaseDatabase.instance.ref("posts");
  bool isAnonymous = false;

  void _addComment(String commentText, String userName) async {
    widget.post.comments.add({'text': commentText, 'user': userName});
    await _dbRef.child(widget.post.id).update({
      'comments': widget.post.comments,
    });
    _commentController.clear();
    _nameController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(gradient: AppColor.linearDarkGradient),
          child: AppBar(
            title: Text('Post Details'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('By: ${widget.post.author}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14)),
            SizedBox(height: 12),
            Text(widget.post.content),
            Divider(height: 32),
            Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  final comment = widget.post.comments[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColor.linearDarkGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        comment['text'] ?? '',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        comment['user'] ?? 'Anonymous',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },

              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(labelText: 'Add a comment...'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Your name'),
                    enabled: !isAnonymous,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            isAnonymous = value!;
                          });
                        },
                      ),
                      Text('Post anonymously'),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppColor.buttonGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Post Comment'),
                      ),
                    ),
                    onPressed: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        _addComment(
                          _commentController.text.trim(),
                          isAnonymous || _nameController.text.trim().isEmpty
                              ? 'Anonymous'
                              : _nameController.text.trim(),
                        );
                      }
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _authorController = TextEditingController();
  bool isAnonymous = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(gradient: AppColor.linearDarkGradient),
          child: AppBar(
            title: Text('Create Post'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Your name'),
              enabled: !isAnonymous,
            ),
            Row(
              children: [
                Checkbox(
                  value: isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      isAnonymous = value!;
                      if (isAnonymous) _authorController.clear();
                    });
                  },
                ),
                Text('Post anonymously'),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColor.buttonGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Submit'),
                ),
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _contentController.text.isNotEmpty) {
                  final newPost = Post(
                    id: '',
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    category: _categoryController.text.trim().isEmpty
                        ? 'General'
                        : _categoryController.text.trim(),
                    comments: [],
                    createdAt: DateTime.now(),
                    author: isAnonymous || _authorController.text.trim().isEmpty
                        ? 'Anonymous'
                        : _authorController.text.trim(),
                  );
                  Navigator.of(context).pop(newPost);
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}