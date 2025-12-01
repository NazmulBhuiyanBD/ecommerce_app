import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  bool uploading = false;

  Future pickAndUpload({
    required String collection,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => uploading = true);

    File file = File(picked.path);

    // UPLOAD TO CLOUDINARY
    final url = await CloudinaryService.uploadImage(file);

    if (url != null) {
      await FirebaseFirestore.instance.collection(collection).add({
        "image": url,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
    }

    setState(() => uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7E9),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Manage App Screen"),
        centerTitle: true,
        backgroundColor: const Color(0xffF4F7E9),
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const SizedBox(height: 10),

        
          sectionTitle("Upload Home Banner"),
          uploadButton(() => pickAndUpload(collection: "banners")),
          bannerList("banners"),

          const SizedBox(height: 25),

          sectionTitle("Upload Offer Banner"),
          uploadButton(() => pickAndUpload(collection: "offer_banners")),
          bannerList("offer_banners"),

          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget uploadButton(Function() onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      icon: const Icon(Icons.upload),
      label: Text(uploading ? "Uploading..." : "Pick Image & Upload"),
      onPressed: uploading ? null : onTap,
    );
  }


  Widget bannerList(String collection) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();

        final items = snap.data!.docs;

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text("No banners added yet"),
          );
        }

        return Column(
          children: items.map((e) {
            final data = e.data() as Map<String, dynamic>;
            final img = data["image"];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Image.network(
                  img,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                ),
                title: Text(collection == "banners"
                    ? "Home Banner"
                    : "Offer Banner"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection(collection)
                        .doc(e.id)
                        .delete();
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
