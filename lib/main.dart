import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/mood_tracker/mood_tracker.dart';
import 'screens/dashboard.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'constants/app_colors.dart';
import 'screens/forum/forum_screen.dart';
import 'screens/Emergency/emergency_screen.dart';
import 'screens/Emergency/panic_help.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDB-id4TH6iyiGXYcXNzG0voBlJjSmkxoc",
        authDomain: "mindconnect-32f08.firebaseapp.com",
        projectId: "mindconnect-32f08",
        storageBucket: "mindconnect-32f08.appspot.com",
        messagingSenderId: "290416442896",
        appId: "1:290416442896:web:7f4570357bdd7d4a6f5495",
        measurementId: "G-DZ5J5VYQR3",
        databaseURL: "https://mindconnect-32f08-default-rtdb.firebaseio.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.lexendTextTheme(),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => ProfileScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return MoodTrackerPage(userEmail: args);
        },
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return DashboardScreen(userEmail: args ?? 'guest@example.com');
        },
        '/forum': (context) => ForumHomeScreen(),
        '/emergency': (context) => EnhancedEmergencyScreen(),
        '/panicHelp': (context) => PanicHelpScreen(),
      },
    );
  }
}
