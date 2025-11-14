import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final name = TextEditingController();
  final price = TextEditingController();
  final description = TextEditingController();
  final image = TextEditingController();

  bool loading = false;

  Future<void> saveProduct() async {
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final shopId = userDoc["shopId"];

    await FirebaseFirestore.instance.collection("products").add({
      "shopId": shopId,
      "name": name.text.trim(),
      "price": double.tryParse(price.text.trim()) ?? 0,
      "description": description.text.trim(),
      "image": image.text.trim(),
      "createdAt": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product Added Successfully")),
    );

    setState(() => loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: image,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : saveProduct,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }
}
