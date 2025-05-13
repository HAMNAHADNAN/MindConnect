import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/mood_tracker/mood_tracker.dart';
import 'constants/app_colors.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
  await Firebase.initializeApp(options: FirebaseOptions( apiKey: "AIzaSyDB-id4TH6iyiGXYcXNzG0voBlJjSmkxoc",
      authDomain: "mindconnect-32f08.firebaseapp.com",
      projectId: "mindconnect-32f08",
      storageBucket: "mindconnect-32f08.firebasestorage.app",
      messagingSenderId: "290416442896",
      appId: "1:290416442896:web:7f4570357bdd7d4a6f5495",
      measurementId: "G-DZ5J5VYQR3",
    databaseURL: "https://mindconnect-32f08-default-rtdb.firebaseio.com"
  )); }
  else {
    await  Firebase.initializeApp();// Initialize Firebase
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.background,
        primaryColor: AppColor.primary,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2667AA),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColor.contentBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: MoodTrackerPage(),
    );
  }
}
