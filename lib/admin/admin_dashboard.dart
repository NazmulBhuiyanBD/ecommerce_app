import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/service/auth_service.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import 'manage_products.dart';
import 'manage_users.dart';
import 'manage_shop_owners.dart';
import 'manage_orders.dart';
import 'store_list.dart';
import 'manage_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Stream<int> customerCount() {
    return FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "customer")
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<int> shopOwnerCount() {
    return FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "shop_owner")
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<int> getCount(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .map((snap) => snap.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(15.0),

        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            dashboardCard(
              title: "Products",
              icon: Icons.shopping_bag,
              iconColor: Colors.blue,
              badgeColor: Colors.blue.shade50,
              stream: getCount("products"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProducts()),
              ),
            ),

            dashboardCard(
              title: "Customers",
              icon: Icons.people,
              iconColor: Colors.green,
              badgeColor: Colors.green.shade50,
              stream: customerCount(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsers()),
              ),
            ),

            dashboardCard(
              title: "Shop Owners",
              icon: Icons.people_alt,
              iconColor: Colors.orange,
              badgeColor: Colors.orange.shade50,
              stream: shopOwnerCount(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageShopOwners()),
              ),
            ),

            dashboardCard(
              title: "Orders",
              icon: Icons.receipt_long,
              iconColor: Colors.red,
              badgeColor: Colors.red.shade50,
              stream: getCount("orders"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOrders()),
              ),
            ),

            dashboardCard(
              title: "Store List",
              icon: Icons.store,
              iconColor: Colors.purple,
              badgeColor: Colors.purple.shade50,
              stream: getCount("shops"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreList()),
              ),
            ),
            dashboardCard(
              title: "Manage Screen",
              icon: Icons.settings_applications,
              iconColor: Colors.teal,
              badgeColor: Colors.teal.shade50,
              stream: Stream.value(0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageScreen()),
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
              color: Colors.black12.withOpacity(0.05),
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

            const SizedBox(height: 12),

            StreamBuilder<int>(
              stream: stream,
              builder: (_, snap) {
                int count = snap.data ?? 0;
                return Text(
                  "$count",
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 6),

            Text(
              "View All",
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
