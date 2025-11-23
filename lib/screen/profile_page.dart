import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    checkUser();
  }


  Future<void> checkUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      redirectToLogin();
      return;
    }


    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();
      redirectToLogin();
      return;
    }

    setState(() {
      userData = doc.data();
    });
  }

  void redirectToLogin() {
    Future.microtask(() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${userData!["name"]}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            Text("Email: ${userData!["email"]}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            Text("Role: ${userData!["role"]}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            if (userData!["role"] == "shop_owner")
              Text("Shop Status: ${userData!["status"]}",
                  style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
