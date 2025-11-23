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
    final user = FirebaseAuth.instance.currentUser;

    if (index == 3 && user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: handleNavigation,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,

          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,

          showSelectedLabels: true,
          showUnselectedLabels: true,

          items: const [
            BottomNavigationBarItem(
                icon: Icon(Iconsax.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Iconsax.category), label: 'Categories'),
            BottomNavigationBarItem(
                icon: Icon(Iconsax.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(
                icon: Icon(Iconsax.user), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
