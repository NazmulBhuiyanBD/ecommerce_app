import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/screen/main_page.dart';
import 'package:ecommerce_app/service/auth_service.dart';
import 'package:ecommerce_app/shopOwner/shop_owner_dashboard.dart';
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
  final formKey = GlobalKey<FormState>();

  bool showPassword = false;
  bool loading = false;

  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

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

      final doc =
          await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

      if (!doc.exists) {
        await AuthService().signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User profile missing! Contact Admin.")),
        );
        setState(() => loading = false);
        return;
      }

      final role = doc["role"];
      final status = doc["status"];

      if (role == "admin") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      }
      // SHOP OWNER
      else if (role == "shop_owner") {
        if (status == "approved") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ShopOwnerDashboard()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Shop owner account pending approval")));
          await AuthService().signOut();
        }
      }
      // CUSTOMER
      else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainPage()));
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  Future<void> loginWithGoogle() async {
    setState(() => loading = true);

    final user = await AuthService().signInWithGoogle();

    setState(() => loading = false);

    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Login Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.secondary ,
      body: SafeArea(
        child: Center(
          
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: formKey,
              child: Column(
                
                children: [
                  const Text("Welcome Back 👋",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Login with your email or Google",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                 
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? "Please enter email" : null,
                  ),
                  const SizedBox(height: 15),

                  
                  TextFormField(
                    controller: password,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Password",
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15),),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? "Enter your password" : null,
                  ),
                  const SizedBox(height: 25),

                
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,   
      foregroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
                      onPressed: loading ? null : loginUser,
                      child: loading
                          ? const CircularProgressIndicator(color: AppColors.secondary)
                          : const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Image.asset("assets/google.png", height: 22),
                      label: const Text("Continue with Google",
                          style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                      ),
                      onPressed: loginWithGoogle,
                    ),
                  ),

                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
