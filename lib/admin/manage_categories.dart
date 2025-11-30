import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ManageCategories extends StatefulWidget {
  const ManageCategories({super.key});

  @override
  State<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  final nameCtrl = TextEditingController();
  final editNameCtrl = TextEditingController();

  File? pickedImage;
  File? editPickedImage;

  Future<String?> uploadToCloudinary(File file) async {
    try {
      final url =
          "https://api.cloudinary.com/v1_1/${Env.cloudName}/image/upload";

      final request = http.MultipartRequest("POST", Uri.parse(url));
      request.fields["upload_preset"] = Env.uploadPreset;

      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(body);
        return jsonData["secure_url"];
      }
    } catch (e) {
      print("Cloudinary error: $e");
    }
    return null;
  }

  Future pickCategoryImage() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => pickedImage = File(xFile.path));
    }
  }

  Future pickEditCategoryImage() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => editPickedImage = File(xFile.path));
    }
  }

  Future<void> addCategory() async {
    if (nameCtrl.text.trim().isEmpty || pickedImage == null) return;

    final imageUrl = await uploadToCloudinary(pickedImage!);
    if (imageUrl == null) return;

    await FirebaseFirestore.instance.collection("categories").add({
      "name": nameCtrl.text.trim(),
      "image": imageUrl,
      "createdAt": DateTime.now(),
    });

    nameCtrl.clear();
    pickedImage = null;

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Category added")));
  }

  Future<void> updateCategory(String id) async {
    String? updatedImageUrl;

    if (editPickedImage != null) {
      updatedImageUrl = await uploadToCloudinary(editPickedImage!);
    }

    await FirebaseFirestore.instance.collection("categories").doc(id).update({
      "name": editNameCtrl.text.trim(),
      if (updatedImageUrl != null) "image": updatedImageUrl,
    });

    Navigator.pop(context);
    editPickedImage = null;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Category updated")));
  }

  Future<void> deleteCategory(String id) async {
    await FirebaseFirestore.instance.collection("categories").doc(id).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Category deleted")));
  }

  void addDialog() {
    pickedImage = null;
    nameCtrl.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: pickCategoryImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: pickedImage != null
                    ? Image.file(pickedImage!, fit: BoxFit.cover)
                    : const Center(child: Text("Tap to Upload Image")),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(onPressed: addCategory, child: const Text("Add")),
        ],
      ),
    );
  }

  void editDialog(String id, Map data) {
    editNameCtrl.text = data["name"];
    editPickedImage = null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: pickEditCategoryImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: editPickedImage != null
                    ? Image.file(editPickedImage!, fit: BoxFit.cover)
                    : Image.network(
                        data["image"],
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: editNameCtrl,
              decoration: const InputDecoration(labelText: "Category Name"),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => updateCategory(id),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addDialog,
          )
        ],
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("categories")
            .orderBy("name")
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          if (categories.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final data = cat.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(data["image"]),
                  ),

                  title: Text(data["name"]),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "edit", child: Text("Edit")),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                    onSelected: (value) {
                      if (value == "edit") {
                        editDialog(cat.id, data);
                      } else {
                        deleteCategory(cat.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
