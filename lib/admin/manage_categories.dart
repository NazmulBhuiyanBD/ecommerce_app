import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/service/cloudinary_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ManageCategories extends StatefulWidget {
  const ManageCategories({super.key});

  @override
  State<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  final nameCtrl = TextEditingController();
  final editCtrl = TextEditingController();

  File? pickedImage;
  Uint8List? pickedBytes;

  String? imageUrl;
  String? editImageUrl;

  bool uploading = false;

  Future<void> pickMobileImage(bool isEditing,
      void Function(void Function()) setDialogState) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    pickedImage = File(file.path);
    pickedBytes = null;

    setDialogState(() {});
    await uploadToCloudinary(isEditing, setDialogState);
  }

  Future<void> pickWebImage(bool isEditing,
      void Function(void Function()) setDialogState) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.image,
    );

    if (result == null) return;

    pickedBytes = result.files.first.bytes;
    pickedImage = null;

    setDialogState(() {});
    await uploadToCloudinary(isEditing, setDialogState);
  }

  Future<void> uploadToCloudinary(bool isEditing,
      void Function(void Function()) setDialogState) async {
    setDialogState(() => uploading = true);

    String? url;

    if (!kIsWeb && pickedImage != null) {
      url = await CloudinaryService.uploadImage(pickedImage!);
    }

    if (kIsWeb && pickedBytes != null) {
      url = await CloudinaryService.uploadBytes(pickedBytes!);
    }

    if (isEditing) {
      editImageUrl = url;
    } else {
      imageUrl = url;
    }

    setDialogState(() => uploading = false);
  }


  Future<void> addCategory() async {
    if (nameCtrl.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection("categories").add({
      "name": nameCtrl.text.trim(),
      "image": imageUrl,
      "createdAt": DateTime.now(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Category added")));
  }


  Future<void> updateCategory(String id) async {
    await FirebaseFirestore.instance.collection("categories").doc(id).update({
      "name": editCtrl.text.trim(),
      "image": editImageUrl,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Category updated")));
  }

  void addCategoryDialog() {
    nameCtrl.clear();
    pickedImage = null;
    pickedBytes = null;
    imageUrl = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Category Name"),
              ),
              const SizedBox(height: 12),

              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: uploading
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrl != null
                        ? Image.network(imageUrl!, fit: BoxFit.cover)
                        : pickedBytes != null
                            ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                            : const Center(child: Text("Select image")),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Choose Image"),
                onPressed: () async {
                  if (kIsWeb) {
                    await pickWebImage(false, setDialogState);
                  } else {
                    await pickMobileImage(false, setDialogState);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: addCategory,
              child: const Text("Add"),
            ),
          ],
        );
      }),
    );
  }

  void editCategoryDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    editCtrl.text = data["name"];
    editImageUrl = data["image"];

    pickedImage = null;
    pickedBytes = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (_, setDialogState) {
        return AlertDialog(
          title: const Text("Edit Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editCtrl,
                decoration: const InputDecoration(labelText: "Category Name"),
              ),
              const SizedBox(height: 12),

              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: uploading
                    ? const Center(child: CircularProgressIndicator())
                    : editImageUrl != null
                        ? Image.network(editImageUrl!, fit: BoxFit.cover)
                        : pickedBytes != null
                            ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                            : const Center(child: Text("Select image")),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Change Image"),
                onPressed: () async {
                  if (kIsWeb) {
                    await pickWebImage(true, setDialogState);
                  } else {
                    await pickMobileImage(true, setDialogState);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () => updateCategory(doc.id),
              child: const Text("Update"),
            ),
          ],
        );
      }),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addCategoryDialog,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("categories")
            .orderBy("name")
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final cat = list[i];
              final data = cat.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: data["image"] != null
                      ? Image.network(
                          data["image"],
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 40),
                  title: Text(data["name"] ?? ""),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "edit", child: Text("Edit")),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                    onSelected: (value) {
                      if (value == "edit") {
                        editCategoryDialog(cat);
                      } else {
                        FirebaseFirestore.instance
                            .collection("categories")
                            .doc(cat.id)
                            .delete();
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
