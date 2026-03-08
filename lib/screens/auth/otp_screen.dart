import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../utils/app_theme.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  int    _countdown = 60;
  bool   _canResend = false;
  Timer? _resendTimer;
  Timer? _pollTimer;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
  late AnimationController _successCtrl;
  late Animation<double>   _successAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _fadeCtrl.forward();

    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successAnim = CurvedAnimation(
            parent: _successCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));

    _startCountdown();
    _startPolling();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pollTimer?.cancel();
    _fadeCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _countdown--;
        if (_countdown <= 0) { _canResend = true; t.cancel(); }
      });
    });
  }

  // Polls Firebase every 3 seconds — when emailVerified becomes true, auto-navigates
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      final verified =
          await context.read<AuthProvider>().silentCheckEmailVerified();
      if (verified && mounted) {
        _pollTimer?.cancel();
        _onVerified();
      }
    });
  }

  Future<void> _onVerified() async {
    _successCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    // Sign out so AuthWrapper returns LoginScreen at the root
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    // Pop back to root — AuthWrapper now shows LoginScreen (user signed out)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    await context.read<AuthProvider>().resendVerificationEmail();
    if (!mounted) return;
    _startCountdown();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Verification email resent!'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthProvider>();
    final isVerified = auth.otpStatus == OtpStatus.verified;
    final isSending  = auth.otpStatus == OtpStatus.sending;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          Positioned(top: -80, right: -60, child: _blob(200, 0.06)),
          Positioned(bottom: -60, left: -40, child: _blob(180, 0.04)),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Back — cancel verification and return to login
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () async {
                        _pollTimer?.cancel();
                        final nav = Navigator.of(context);
                        await context.read<AuthProvider>().signOut();
                        if (!mounted) return;
                        nav.popUntil((route) => route.isFirst);
                      },
                      padding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 32),

                    // Icon — envelope or success checkmark
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: isVerified
                          ? ScaleTransition(
                              scale: _successAnim,
                              child: Container(
                                key: const ValueKey('success'),
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.success
                                          .withValues(alpha: 0.4),
                                      width: 1.5),
                                ),
                                child: const Icon(Icons.check_circle_rounded,
                                    color: AppColors.success, size: 40),
                              ),
                            )
                          : Container(
                              key: const ValueKey('email'),
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.3),
                                    width: 1.5),
                              ),
                              child: const Icon(
                                  Icons.mark_email_unread_rounded,
                                  color: AppColors.accent,
                                  size: 36),
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isVerified ? 'Email Verified!' : 'Verify Your Email',
                        key: ValueKey(isVerified),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: RichText(
                        key: ValueKey(isVerified),
                        text: TextSpan(
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.6),
                          children: isVerified
                              ? [
                                  const TextSpan(
                                      text: 'Redirecting you to login...'),
                                ]
                              : [
                                  const TextSpan(
                                      text:
                                          'We sent a verification link to\n'),
                                  TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        '\n\nOpen your email and click the link. This page will update automatically once your email is verified.',
                                  ),
                                ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Waiting indicator (auto-polling)
                    if (!isVerified)
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: AppColors.accent, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Waiting for verification…',
                              style: TextStyle(
                                  color: AppColors.textHint, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Resend link with countdown
                    if (!isVerified)
                      Center(
                        child: isSending
                            ? const Text('Sending verification email...',
                                style: TextStyle(
                                    color: AppColors.textHint, fontSize: 14))
                            : GestureDetector(
                                onTap: _canResend ? _resend : null,
                                child: RichText(
                                  text: TextSpan(children: [
                                    const TextSpan(
                                      text: "Didn't receive it? ",
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14),
                                    ),
                                    TextSpan(
                                      text: _canResend
                                          ? 'Resend email'
                                          : 'Resend in ${_countdown}s',
                                      style: TextStyle(
                                        color: _canResend
                                            ? AppColors.accent
                                            : AppColors.textHint,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ]),
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

  Widget _blob(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withValues(alpha: opacity)),
      );
}
