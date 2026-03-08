import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth     _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db  = FirebaseFirestore.instance;

  // Streams & getters 
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User?         get currentUser      => _auth.currentUser;
  bool          get isEmailVerified  => _auth.currentUser?.emailVerified ?? false;

  //Sign Up 
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // 1. Create user in Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email:    email.trim(),
      password: password,
    );

    final user = credential.user!;

    // 2. Set display name
    await user.updateDisplayName(fullName.trim());

    // 3. Save user profile to Firestore /users/{uid}
    await _db.collection('users').doc(user.uid).set({
      'uid':         user.uid,
      'email':       email.trim(),
      'displayName': fullName.trim(),
      'createdAt':   FieldValue.serverTimestamp(),
      'notificationsEnabled': true,
    });
  }

  // Sign In 
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email:    email.trim(),
      password: password,
    );
  }

  //Sign Out 
  Future<void> signOut() async => await _auth.signOut();

  // Reload user (check if email verified)
  Future<void> reloadUser() async => await _auth.currentUser?.reload();

  //Resend verification email 
  Future<void> sendVerificationEmail() async =>
      await _auth.currentUser?.sendEmailVerification();

  // Get user profile from Firestore 
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}