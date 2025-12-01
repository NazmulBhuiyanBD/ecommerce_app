import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  File? pickedImage;
  Map<String, dynamic>? userData;
  User? user;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    user = FirebaseAuth.instance.currentUser;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(user!.uid).get();
    userData = doc.data();

    nameCtrl.text = userData?["name"] ?? "";
    emailCtrl.text = userData?["email"] ?? "";

    setState(() {});
  }

  Future<void> pickImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => pickedImage = File(file.path));
  }

  Future<void> save() async {
    String? photoUrl = userData?["profilePic"];

    if (pickedImage != null) {
      photoUrl = await CloudinaryService.uploadImage(pickedImage!);
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update({
      "name": nameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "profilePic": photoUrl
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: pickedImage != null
                    ? FileImage(pickedImage!)
                    : (userData!["profilePic"] != null
                        ? NetworkImage(userData!["profilePic"]) as ImageProvider
                        : null),
                child: pickedImage == null &&
                        (userData!["profilePic"] == null)
                    ? const Icon(Icons.camera_alt, size: 35)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}
