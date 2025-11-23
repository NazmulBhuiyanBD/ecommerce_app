import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  final GoogleSignIn signIn = GoogleSignIn.instance;

  Future<User?> signInWithGoogle() async {
    try {
      await signIn.initialize();
      await signIn.authenticate();

      final completer = Completer<GoogleSignInAccount?>();
      late StreamSubscription sub;

      sub = signIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          completer.complete(event.user);
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          completer.complete(null);
        }
      });

      final GoogleSignInAccount? account = await completer.future;
      await sub.cancel();

      if (account == null) return null;

      final serverAuth = await account.authorizationClient.authorizeServer(
        ['email', 'profile', 'openid'],
      );

      if (serverAuth == null || serverAuth.serverAuthCode.isEmpty) {
        print("Google authCode error");
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: serverAuth.serverAuthCode,
      );

      final userCred = await _auth.signInWithCredential(credential);

      await _saveUserToFirestore(userCred.user!);

      return userCred.user;

    } catch (e) {
      print("🔥 Google Sign-In Error: $e");
      return null;
    }
  }


  Future<void> _saveUserToFirestore(User user) async {
    final doc = FirebaseFirestore.instance.collection("users").doc(user.uid);

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

  Future<User?> signInWithEmail(String email, String password) async {
    return (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
  }


  Future<User?> registerWithEmail(String email, String password) async {
    return (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
  }


  Future<void> signOut() async {
    try {
      await signIn.disconnect();
    } catch (_) {}
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
