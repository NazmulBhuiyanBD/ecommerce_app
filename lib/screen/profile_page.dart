import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/login_page.dart';
import 'edit_profile_page.dart';
import 'order_history_page.dart';

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
    loadUser();
  }

  Future<void> loadUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) return redirectToLogin();

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (!doc.exists) return redirectToLogin();

    setState(() => userData = doc.data());
  }

  void redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  // 🔥 Upload Profile Picture
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    File imgFile = File(file.path);

    final imageUrl = await CloudinaryService.uploadImage(imgFile);
    if (imageUrl == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update({"profilePic": imageUrl});

    loadUser();
  }
  void addAddressPopup() {
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Delivery Address"),
        content: TextField(
          controller: addressCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Enter full address"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (addressCtrl.text.trim().isEmpty) return;

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(user!.uid)
                  .update({"address": addressCtrl.text.trim()});

              setState(() => userData!["address"] = addressCtrl.text.trim());

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pic = userData!["profilePic"] ?? "";
    final address = userData!["address"] ?? "";
    final name = userData!["name"] ?? "User";
    final email = userData!["email"] ?? "";

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text("Account"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              redirectToLogin();
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickProfileImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: pic.isNotEmpty ? NetworkImage(pic) : null,
                child: pic.isEmpty
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.grey)
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              email,
              style: const TextStyle(color: Colors.grey),
            ),

            if (address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("📍 $address",
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 14)),
              ),

            const SizedBox(height: 20),

            profileMenu(Icons.receipt_long, "Order History", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            }),

            profileMenu(Icons.person, "Edit Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            }),

            profileMenu(Icons.location_on, "Delivery Address", () {
              addAddressPopup();
            }),

            profileMenu(Icons.notifications, "Notifications", () {}),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget profileMenu(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
