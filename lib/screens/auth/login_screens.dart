import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../utils/app_theme.dart';
import './sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey           = GlobalKey<FormState>();
  final _emailCtrl         = TextEditingController();
  final _passwordCtrl      = TextEditingController();
  bool  _obscurePassword   = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: const Offset(0, 0.08), end: Offset.zero));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Submit 
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    await auth.signIn(
      email:    _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    // On success, AuthWrapper automatically navigates to HomeScreen
    // (LoginScreen is rendered directly by AuthWrapper, not pushed)
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          // Decorative background blobs 
          _blob(top: -100, right: -80,  size: 260, opacity: 0.06),
          _blob(bottom: -80, left: -60, size: 220, opacity: 0.04),

          //Scrollable form 
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100),

                        // Heading 
                        const Center(
                          child: Text('Welcome Back',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              )),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text('Sign in to explore Kigali City',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              )),
                        ),

                        const SizedBox(height: 40),

                        // Error banner 
                        if (auth.errorMessage != null) ...[
                          _errorBanner(auth.errorMessage!),
                          const SizedBox(height: 20),
                        ],

                        //  Email
                        _label('Email Address'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'your@email.com',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.textHint, size: 20),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$')
                                .hasMatch(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          onChanged: (_) => auth.clearError(),
                        ),

                        const SizedBox(height: 20),

                        // Password 
                        _label('Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.textHint, size: 20),
                            suffixIcon: _eyeToggle(
                              value: _obscurePassword,
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 6) {
                              return 'At least 6 characters required';
                            }
                            return null;
                          },
                          onChanged: (_) => auth.clearError(),
                        ),

                        const SizedBox(height: 10),
                        const SizedBox(height: 28),

                        //Sign In button 
                        isLoading
                            ? _loadingBtn()
                            : ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Sign In'),
                              ),

                        const SizedBox(height: 36),

                        // Divider 
                        _divider(),

                        const SizedBox(height: 28),

                        //Sign Up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ",
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14)),
                            GestureDetector(
                              onTap: () {
                                auth.clearError();
                                Navigator.push(
                                    context, _fade(const SignUpScreen()));
                              },
                              child: const Text('Sign Up',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widgets 

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      );

  Widget _errorBanner(String message) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13, height: 1.4)),
            ),
          ],
        ),
      );

  Widget _eyeToggle({required bool value, required VoidCallback onTap}) =>
      IconButton(
        onPressed: onTap,
        icon: Icon(
          value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textHint,
          size: 20,
        ),
      );

  Widget _loadingBtn() => Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          ),
        ),
      );

  Widget _divider() => Row(
        children: [
          const Expanded(
              child: Divider(color: AppColors.navyBorder, thickness: 1)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('OR',
                style:
                    TextStyle(color: AppColors.textHint, fontSize: 12)),
          ),
          const Expanded(
              child: Divider(color: AppColors.navyBorder, thickness: 1)),
        ],
      );

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) =>
      Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withOpacity(opacity),
          ),
        ),
      );

  PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );
}