import 'package:ecommerce_app/auth/login_page.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'categories_page.dart';
import 'cart_screen.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final pages = const [
    HomePage(),
    CategoriesPage(),
    CartScreen(),
    ProfilePage(),
  ];

  void handleNavigation(int index) {
    /// If user taps Profile tab (index = 3)
    if (index == 3) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        /// User NOT logged in → redirect to LoginPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return; // prevent switching to profile tab
      }
    }

    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: handleNavigation,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Iconsax.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
    );
  }
}
