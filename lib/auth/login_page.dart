import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screen/main_page.dart';
import 'package:ecommerce_app/service/auth_service.dart';
import 'package:ecommerce_app/shopOwner/shop_owner_dashboard.dart';
import 'package:flutter/material.dart';

import '../admin/admin_dashboard.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = await AuthService().signInWithEmail(
        email.text.trim(),
        password.text.trim(),
      );

      if (user == null) {
        setState(() => loading = false);
        return;
      }

      /// fetch Firestore profile
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        /// if profile missing → logout → force login page
        await AuthService().signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile not found. Contact admin.")),
        );
        setState(() => loading = false);
        return;
      }

      final role = doc["role"];
      final status = doc["status"];

      /// Admin → Admin Dashboard
      if (role == "admin") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      }

      /// Shop Owner → require approval
      else if (role == "shop_owner") {
        if (status == "approved") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const ShopOwnerDashboard()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Account pending admin approval")),
          );
          await AuthService().signOut();
        }
      }

      /// Customer → MainPage
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text("Login",
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),

                const SizedBox(height: 30),

                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                      labelText: "Email", border: OutlineInputBorder()),
                  validator: (v) =>
                      v!.isEmpty ? "Enter your email" : null,
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Password", border: OutlineInputBorder()),
                  validator: (v) =>
                      v!.isEmpty ? "Enter your password" : null,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : loginUser,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterPage()),
                  ),
                  child: const Text(
                    "Don't have an account? Register",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
