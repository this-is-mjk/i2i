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
  Timer? _timer;
  String pattern = 'ABAB'; // e.g. "AABB", "ABBA", "ABAB"
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

    // Precache both asset variants used by the pattern so switching doesn't flicker.
    if (mounted) {
      final uniqueChars = pattern.split('').toSet();
      final futures = <Future<void>>[];
      for (final ch in uniqueChars) {
        final prefix = ch == "A" ? A : B;
        final suffix = ch == "A" ? '-c' : '-ec';
        final asset = AssetImage("$prefix/${widget.id}$suffix.jpg");
        futures.add(precacheImage(asset, context));
      }
      // Wait for all precache attempts to complete (best-effort)
      try {
        await Future.wait(futures);
      } catch (_) {
        // If a precache fails (missing asset), continue — we still want the animation.
      }
    }

    // Start periodic timer after images are prepared to avoid visible reloads.
    _timer = Timer.periodic(Duration(milliseconds: (seconds * 1000).round()), (
      _,
    ) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % pattern.length;
      });
    });

    setState(() {}); // trigger rebuild once everything is ready
  }

  @override
  void dispose() {
    _timer?.cancel();
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
