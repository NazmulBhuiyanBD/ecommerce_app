import 'package:ecommerce_app/auth/login_page.dart';
import 'package:ecommerce_app/service/auth_service.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'shop_owner_products_page.dart';
import 'add_product_page.dart';
import 'shop_settings_page.dart';
import 'shop_orders_page.dart';

class ShopOwnerDashboard extends StatelessWidget {
  const ShopOwnerDashboard({super.key});

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

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
      backgroundColor: AppColors.secondary,

      appBar: AppBar(
        title: const Text(
          "Shop Owner Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => logout(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 0.90,

          children: [

            modernTile(
              title: "Shop Settings",
              icon: Icons.settings,
              gradient: const [Color(0xff6a11cb), Color(0xff2575fc)],
              showCount: false,
              stream: Stream.value(0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopSettingsPage()),
              ),
            ),

            modernTile(
              title: "Add Product",
              icon: Icons.add_box_rounded,
              gradient: const [Color(0xff11998e), Color(0xff38ef7d)],
              showCount: false,
              stream: Stream.value(0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              ),
            ),

            modernTile(
              title: "My Products",
              icon: Icons.inventory,
              gradient: const [Color(0xffff512f), Color(0xffdd2476)],
              showCount: true,
              stream: countOwnerProducts(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopOwnerProductsPage()),
              ),
            ),

            modernTile(
              title: "Orders",
              icon: Icons.receipt_long,
              gradient: const [Color(0xffee0979), Color(0xffff6a00)],
              showCount: true,
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

  Widget modernTile({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required Stream<int> stream,
    required Function() onTap,
    bool showCount = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: const [Colors.white, Colors.white70],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              offset: Offset(-4, -4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient.last.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),

            const SizedBox(height: 18),

            showCount
                ? StreamBuilder<int>(
                    stream: stream,
                    builder: (_, snap) {
                      int value = snap.data ?? 0;
                      return Text(
                        "$value",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: gradient.first,
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
