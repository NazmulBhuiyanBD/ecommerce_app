import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// New Google API
  final GoogleSignIn signIn = GoogleSignIn.instance;

  Future<User?> signInWithGoogle() async {
    try {
      // Step 1 — initialize Google client
      await signIn.initialize();

      // Step 2 — open Google Sign-In popup
      await signIn.authenticate();

      // Step 3 — wait for sign-in event
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

      if (account == null) {
        print("❌ Google Sign-In cancelled");
        return null;
      }

      // Step 4 — request server auth code (this acts as idToken for Firebase)
      final serverAuth = await account.authorizationClient.authorizeServer(
        ['email', 'profile', 'openid'],
      );

      if (serverAuth == null || serverAuth.serverAuthCode.isEmpty) {
        print("❌ Failed to get serverAuthCode");
        return null;
      }

      // Step 5 — Use serverAuthCode as idToken for Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: serverAuth.serverAuthCode,
      );

      // Step 6 — Sign in to Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;

    } catch (e) {
      print("🔥 Google Sign-In Error: $e");
      return null;
    }
  }

  // Email Login
  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  // Email Register
  Future<User?> registerWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  // Logout
  Future<void> signOut() async {
    await signIn.disconnect();
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
