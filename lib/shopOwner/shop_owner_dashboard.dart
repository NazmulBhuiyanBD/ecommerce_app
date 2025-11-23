import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_product_page.dart';
import 'shop_settings_page.dart';
import 'shop_orders_page.dart';

class ShopOwnerDashboard extends StatelessWidget {
  const ShopOwnerDashboard({super.key});

  Stream<int> countOwnerProducts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("products")
        .where("ownerId", isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<int> countOwnerOrders() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("orders")
        .where("shopOwnerId", isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),

      appBar: AppBar(
        title: const Text("Shop Owner Dashboard"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(15.0),

        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85,

          children: [

            dashboardCard(
              title: "Shop Settings",
              icon: Icons.settings,
              iconColor: Colors.teal,
              badgeColor: Colors.teal.shade50,
              stream: Stream.value(0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopSettingsPage()),
              ),
            ),

            dashboardCard(
              title: "Add Product",
              icon: Icons.add_box,
              iconColor: Colors.blue,
              badgeColor: Colors.blue.shade50,
              stream: Stream.value(0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              ),
            ),

            dashboardCard(
              title: "My Products",
              icon: Icons.shopping_bag,
              iconColor: Colors.orange,
              badgeColor: Colors.orange.shade50,
              stream: countOwnerProducts(),
              onTap: () {},
            ),

            dashboardCard(
              title: "Orders",
              icon: Icons.list_alt,
              iconColor: Colors.red,
              badgeColor: Colors.red.shade50,
              stream: countOwnerOrders(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopOrdersPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required Stream<int> stream,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              offset: const Offset(0, 4),
              blurRadius: 10,
            )
          ],
        ),
        padding: const EdgeInsets.all(18),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: badgeColor,
              child: Icon(icon, color: iconColor, size: 28),
            ),

            const SizedBox(height: 14),

            StreamBuilder<int>(
              stream: stream,
              builder: (_, snapshot) {
                int value = snapshot.data ?? 0;
                return Text(
                  "$value",
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 6),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
