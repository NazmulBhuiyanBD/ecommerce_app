import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';

import 'manage_shop_owners.dart';
import 'manage_products.dart';
import 'manage_users.dart';
import 'manage_orders.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile(
            title: "Manage Shop Owners",
            icon: Icons.store,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageShopOwners()),
            ),
          ),
          _tile(
            title: "Manage Products",
            icon: Icons.shopping_bag,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageProducts()),
            ),
          ),
          _tile(
            title: "Manage Users",
            icon: Icons.people,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsers()),
            ),
          ),
          _tile(
            title: "Manage Orders",
            icon: Icons.receipt_long,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageOrders()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({required String title, required IconData icon, required Function() onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
