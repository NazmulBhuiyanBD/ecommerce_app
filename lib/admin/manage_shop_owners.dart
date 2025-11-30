import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageShopOwners extends StatelessWidget {
  const ManageShopOwners({super.key});

  Future<void> approveShopOwner(String uid) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "status": "approved",
    });

    final shopId = FirebaseFirestore.instance.collection("shops").doc().id;

    await FirebaseFirestore.instance.collection("shops").doc(shopId).set({
      "ownerId": uid,
      "name": "My Shop",
      "description": "",
      "bannerImage": "",
      "status": "approved",
    });

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "shopId": shopId,
    });
  }

  Future<void> rejectShopOwner(String uid) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "status": "rejected",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shop Owners")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "shop_owner")
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, index) {
              final owner = data[index];
              return Card(
                child: ListTile(
                  title: Text(owner["email"]),
                  subtitle: Text("Status: ${owner["status"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (owner["status"] == "pending")
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => approveShopOwner(owner.id),
                        ),
                      if (owner["status"] == "pending")
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => rejectShopOwner(owner.id),
                        ),
                    ],
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
