import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../utils/app_theme.dart';
import 'package:kigali_directory/screens/auth/otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey              = GlobalKey<FormState>();
  final _nameCtrl             = TextEditingController();
  final _emailCtrl            = TextEditingController();
  final _passwordCtrl         = TextEditingController();
  final _confirmCtrl          = TextEditingController();
  bool  _obscurePassword      = true;
  bool  _obscureConfirm       = true;
  bool  _agreedToTerms        = false;

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showSnack('Please agree to the Terms & Conditions first.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    final auth    = context.read<AuthProvider>();
    final success = await auth.signUp(
      email:    _emailCtrl.text,
      password: _passwordCtrl.text,
      fullName: _nameCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        _fade(OtpScreen(email: _emailCtrl.text.trim())),
      );
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          _blob(top: -80, right: -60,   size: 220, opacity: 0.06),
          _blob(bottom: -60, left: -40, size: 180, opacity: 0.04),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textPrimary, size: 20),
                            onPressed: () {
                              auth.clearError();
                              Navigator.pop(context);
                            },
                          ),
                          const Spacer(),
                          const Text('Create Account',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),

                              // Heading
                              const Text('Join Kigali City',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  )),
                              const SizedBox(height: 6),
                              const Text(
                                  'Create your account to get started',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                  )),

                              const SizedBox(height: 32),

                              // Error banner
                              if (auth.errorMessage != null) ...[
                                _errorBanner(auth.errorMessage!),
                                const SizedBox(height: 20),
                              ],

                              // Full Name 
                              _label('Full Name'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameCtrl,
                                textInputAction: TextInputAction.next,
                                textCapitalization:
                                    TextCapitalization.words,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15),
                                decoration: const InputDecoration(
                                  hintText: 'Enter your full name',
                                  prefixIcon: Icon(Icons.person_outline_rounded,
                                      color: AppColors.textHint, size: 20),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Full name is required';
                                  }
                                  if (v.trim().length < 2) {
                                    return 'Name too short';
                                  }
                                  return null;
                                },
                                onChanged: (_) => auth.clearError(),
                              ),

                              const SizedBox(height: 18),

                              // Email 
                              _label('Email Address'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15),
                                decoration: const InputDecoration(
                                  hintText: 'your@email.com',
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: AppColors.textHint, size: 20),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                          r'^[\w\.\-]+@[\w\-]+\.\w{2,}$')
                                      .hasMatch(v.trim())) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                                onChanged: (_) => auth.clearError(),
                              ),

                              const SizedBox(height: 18),

                              // Password
                              _label('Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Min. 6 characters',
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: AppColors.textHint, size: 20),
                                  suffixIcon: _eyeToggle(
                                    value: _obscurePassword,
                                    onTap: () => setState(() =>
                                        _obscurePassword =
                                            !_obscurePassword),
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
                              ),

                              const SizedBox(height: 18),

                              // ── Confirm Password ──────────
                              _label('Confirm Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Re-enter your password',
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: AppColors.textHint, size: 20),
                                  suffixIcon: _eyeToggle(
                                    value: _obscureConfirm,
                                    onTap: () => setState(
                                        () => _obscureConfirm =
                                            !_obscureConfirm),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (v != _passwordCtrl.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // ── Terms checkbox ────────────
                              _termsRow(),

                              const SizedBox(height: 32),

                              // ── Create Account button ─────
                              isLoading
                                  ? _loadingBtn()
                                  : ElevatedButton(
                                      onPressed: _submit,
                                      child: const Text('Create Account'),
                                    ),

                              const SizedBox(height: 28),

                              // ── Sign in link ──────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Text(
                                      'Already have an account? ',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14)),
                                  GestureDetector(
                                    onTap: () {
                                      auth.clearError();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Sign In',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _termsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color:
                  _agreedToTerms ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms
                    ? AppColors.accent
                    : AppColors.navyBorder,
                width: 2,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Reusable widgets

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      );

  Widget _errorBanner(String msg) => Container(
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
              child: Text(msg,
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
          value
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
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