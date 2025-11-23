import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/role_checker.dart';
import 'onboarding_screen.dart';

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});
  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  bool? seen;

  @override
  void initState() {
    super.initState();
    _checkSeen();
  }

  Future<void> _checkSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getBool('seenOnboarding') ?? false;
    setState(() => seen = s);
  }

  @override
  Widget build(BuildContext context) {
    if (seen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return seen! ? const RoleChecker() : const OnBoardingScreen();
  }
}
