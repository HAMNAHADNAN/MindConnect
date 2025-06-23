import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mind_connect/constants/app_colors.dart';

class EnhancedEmergencyScreen extends StatelessWidget {
  final List<Map<String, dynamic>> emergencies = [
    {
      'title': 'Suicidal Thoughts',
      'icon': Icons.emergency,
      'desc': 'Get urgent emotional support',
      'url': 'https://www.befrienders.org/pakistan',
    },
    {
      'title': 'Panic Attack',
      'icon': Icons.self_improvement,
      'desc': 'Grounding & calming resources',
      'route': '/panicHelp',
    },
    {
      'title': 'Violence/Abuse',
      'icon': Icons.report_problem,
      'desc': 'Report or get help for abuse',
      'url': 'https://www.pakistan.gov.pk/report_abuse.html',
    },
    {
      'title': 'Call Therapist',
      'icon': Icons.local_hospital,
      'desc': 'Call your assigned therapist',
      'url': 'https://counseling.pk/',
    },
  ];

  final List<Map<String, String>> contacts = [
    {'title': 'Emaan Syed Psychotherapist', 'number': 'tel:+92 333 7420855'},
    {'title': 'Karachi Psychiatric Hospital ', 'number': 'tel:021-36646944'},
  ];

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }


  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
    );

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: AppColor.dark.withOpacity(0.7),
        leading: Builder(
          builder: (context) => ShaderMask(
            shaderCallback: (bounds) => AppColor.linearDarkGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            blendMode: BlendMode.srcIn,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => AppColor.linearDarkGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          blendMode: BlendMode.srcIn,
          child: Text(
            "🚨 Emergency Help",
            style: titleStyle.copyWith(
              color: Colors.white, // overridden by ShaderMask
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),


      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColor.linearDarkGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What kind of emergency?",
                style: titleStyle.copyWith(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),



              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: emergencies.map((e) {
                    return _EmergencyCard(
                      title: e['title'],
                      description: e['desc'],
                      icon: e['icon'],
                      onTap: () {
                        final url = e['url'];
                        final route = e['route'];
                        final number = e['number'];

                        if (url != null) {
                          _launchUrl(url);
                        } else if (route != null) {
                          Navigator.pushNamed(context, route);
                        } else if (number != null) {
                          _launchUrl(number);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected: ${e['title']}'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red[700],
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Text(
                      "Press SOS for Help",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _SosButton(),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              Text(
                "📞 Contact Options",
                style: titleStyle.copyWith(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),


              const SizedBox(height: 18),

              ...contacts.map((c) {
                final number = c['number'] ?? '';
                return Card(
                  color: Colors.white.withOpacity(0.98),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 10,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: AppColor.primary, size: 30),
                    title: Text(
                      c['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      number.replaceAll('tel:', ''),
                      style: const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    trailing: const Icon(Icons.call_outlined, size: 26, color: AppColor.primary),
                    onTap: () => _launchUrl(number),
                  ),
                );
              }).toList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_EmergencyCard> createState() => _EmergencyCardState();
}

class _EmergencyCardState extends State<_EmergencyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.08,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _pressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _pressed = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.42,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.red.shade200.withOpacity(0.5), Colors.red.shade700.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade700.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosButton extends StatefulWidget {
  @override
  State<_SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<_SosButton> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Material(
          shape: const CircleBorder(),
          elevation: 20,
          shadowColor: Colors.red.withOpacity(_glowController.value * 0.8),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS sent! Help is on the way!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            splashColor: Colors.redAccent.withOpacity(0.5),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(_glowController.value),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
