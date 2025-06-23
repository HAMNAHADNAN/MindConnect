import 'package:flutter/material.dart';
import 'package:mind_connect/constants/app_colors.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _scale = 0.0;

  @override
  void initState() {
    super.initState();

    // Start animation
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _scale = 1.0;
      });
    });

    // Navigate after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColor.background, // Use background color from AppColor
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: _scale),
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeOutBack,
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: scale.clamp(0.0, 1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.self_improvement,
                      size: 100,
                      color:
                          AppColor.primary, // Use primary color from AppColor
                    ),
                    SizedBox(height: 20),
                    Text(
                      'MindConnect',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColor.dark, // Use dark color from AppColor
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Breathe. Reflect. Heal.',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.2,
                        color:
                            AppColor.primary, // Use primary color from AppColor
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
