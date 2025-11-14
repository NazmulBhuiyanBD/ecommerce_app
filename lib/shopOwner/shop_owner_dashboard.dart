import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'shop_settings_page.dart';
import 'shop_orders_page.dart';

class ShopOwnerDashboard extends StatelessWidget {
  const ShopOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shop Owner Dashboard")),
      
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile(
            icon: Icons.settings,
            title: "Shop Settings",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopSettingsPage()),
            ),
          ),
          _tile(
            icon: Icons.add_box,
            title: "Add Product",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductPage()),
            ),
          ),
          _tile(
            icon: Icons.list_alt,
            title: "Orders",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopOrdersPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({required IconData icon, required String title, required Function() onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
