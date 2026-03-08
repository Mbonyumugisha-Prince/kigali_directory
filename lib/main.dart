import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_providers.dart';
import 'providers/listing_provider.dart';
import 'utils/app_theme.dart';
import 'screens/auth/login_screens.dart';
import 'package:kigali_directory/screens/auth/otp_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali City Directory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Loading while Firebase checks auth state
    if (auth.status == AuthStatus.initial) {
      return const Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (auth.status == AuthStatus.authenticated) {
      // Email not yet verified → show verification screen
      if (!auth.isOtpVerified) {
        return OtpScreen(email: auth.user?.email ?? '');
      }
      // Email verified → main app
      return const HomeScreen();
    }

    // unauthenticated / loading / error → login screen
    return const LoginScreen();
  }
}
