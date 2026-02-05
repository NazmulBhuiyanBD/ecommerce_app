import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ v6 constructor (THIS IS IMPORTANT)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ================= GOOGLE LOGIN =================
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCred =
          await _auth.signInWithCredential(credential);

      await _saveUserToFirestore(userCred.user!);

      return userCred.user;
    } catch (e) {
      print("🔥 Google Sign-In Error: $e");
      return null;
    }
  }

  // ================= EMAIL LOGIN =================
  Future<User?> signInWithEmail(String email, String password) async {
    final UserCredential cred =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // ================= EMAIL REGISTER =================
  Future<User?> registerWithEmail(String email, String password) async {
    final UserCredential cred =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _saveUserToFirestore(cred.user!);
    return cred.user;
  }

  // ================= SAVE USER =================
  Future<void> _saveUserToFirestore(User user) async {
    final doc =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    if (!(await doc.get()).exists) {
      await doc.set({
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "role": "customer",
        "status": "approved",
        "shopId": "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ================= AUTH STATE =================
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
