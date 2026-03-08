import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }
enum OtpStatus  { idle, verifying, verified, sending }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  OtpStatus _otpStatus   = OtpStatus.idle;
  bool      _otpVerified = false;

  AuthStatus _status       = AuthStatus.initial;
  String?    _errorMessage;
  User?      _user;

  // Getters
  AuthStatus get status          => _status;
  String?    get errorMessage    => _errorMessage;
  User?      get user            => _user;
  bool       get isEmailVerified => _service.isEmailVerified;
  OtpStatus  get otpStatus       => _otpStatus;
  bool       get isOtpVerified   => _otpVerified;

  // Constructor — listen to Firebase auth state changes
  AuthProvider() {
    _service.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    if (user != null) {
      _status      = AuthStatus.authenticated;
      // Allow through only if Firebase email is verified
      _otpVerified = user.emailVerified;
    } else {
      _status      = AuthStatus.unauthenticated;
      _otpVerified = false;
    }
    notifyListeners();
  }

  // Sign Up — creates user, saves profile, sends Firebase verification email
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading();
    try {
      await _service.signUp(
        email:    email,
        password: password,
        fullName: fullName,
      );
      // Send Firebase's verification link (not a custom OTP)
      await _service.sendVerificationEmail();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [signUp] code: ${e.code} | msg: ${e.message}');
      _setError(_mapError(e.code));
      return false;
    } catch (e, st) {
      debugPrint('signUp unexpected error: $e\n$st');
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _service.signIn(email: email, password: password);
      // Explicitly update state so AuthWrapper navigates immediately
      _user        = _service.currentUser;
      _status      = AuthStatus.authenticated;
      _otpVerified = _user?.emailVerified ?? false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [signIn] code: ${e.code} | msg: ${e.message}');
      _setError(_mapError(e.code));
      return false;
    } catch (e) {
      debugPrint('signIn unexpected error: $e');
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _service.signOut();
  }

  // Reload user (used internally)
  Future<void> reloadUser() async {
    await _service.reloadUser();
    _user = _service.currentUser;
    notifyListeners();
  }

  // Silent background poll — no UI status change, used by the auto-polling timer
  Future<bool> silentCheckEmailVerified() async {
    await _service.reloadUser();
    _user = _service.currentUser;

    if (_service.isEmailVerified) {
      _otpStatus   = OtpStatus.verified;
      _otpVerified = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Resend Firebase verification email
  Future<void> resendVerificationEmail() async {
    _otpStatus    = OtpStatus.sending;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.sendVerificationEmail();
    } catch (e) {
      _errorMessage = 'Failed to send email. Please try again.';
    }
    _otpStatus = OtpStatus.idle;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Private helpers
  void _setLoading() {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status       = AuthStatus.error;
    notifyListeners();
  }

  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'EMAIL_NOT_FOUND':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'INVALID_PASSWORD':
        return 'Incorrect email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';
      case 'channel-error':
        return 'Please enter your email and password.';
      case 'internal-error':
        return 'A server error occurred. Please try again later.';
      default:
        debugPrint('Unmapped Firebase error code: $code');
        return 'Authentication failed ($code). Please try again.';
    }
  }
}
