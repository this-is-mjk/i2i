import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatternAnimatedImage extends StatefulWidget {
  final String id; // e.g. "Q101"

  const PatternAnimatedImage({super.key, required this.id});

  @override
  State<PatternAnimatedImage> createState() => _PatternAnimatedImageState();
}

class _PatternAnimatedImageState extends State<PatternAnimatedImage> {
  late Timer _timer;
  late String pattern; // e.g. "AABB", "ABBA", "ABAB"
  late Duration duration;
  int _currentIndex = 0;
  SharedPreferences? prefs;

  static const String A = "assets/Caricaiture";
  static const String B = "assets/Exaggerated_caricature";

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    pattern = prefs?.getString("imagePattern") ?? 'ABAB';
    double seconds = prefs?.getDouble("interventionlineTime")?.toDouble() ?? 2;

    _timer = Timer.periodic(Duration(milliseconds: (seconds * 1000).round()), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % pattern.length;
      });
    });

    setState(() {}); // trigger rebuild once everything is ready
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefs == null || pattern.isEmpty) {
      // Show a loader / placeholder until prefs load
      return const Center(child: CircularProgressIndicator());
    }
    // Pick which path based on pattern character
    String prefix = pattern[_currentIndex] == "A" ? A : B;
    String suffix = pattern[_currentIndex] == "A" ? '-c' : '-ec';

    String imagePath = "$prefix/${widget.id}$suffix.jpg";

    return Image(image: AssetImage(imagePath), fit: BoxFit.cover);
  }
}
