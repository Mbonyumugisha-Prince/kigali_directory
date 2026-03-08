import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OtpService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Gmail credentials loaded from .env
  static String get _gmailUser   => dotenv.env['GMAIL_USER']   ?? '';
  static String get _gmailPass   => dotenv.env['GMAIL_PASS']   ?? '';
  static String get _senderEmail => _gmailUser;

  // Generate 6-digit OTP
  String _generateOtp() =>
      List.generate(6, (_) => Random.secure().nextInt(10)).join();

  // Send OTP: save to Firestore + email via Gmail SMTP
  Future<void> sendOtp(String email, {String name = ''}) async {
    final displayName = name.isNotEmpty ? name : email.split('@')[0];
    final otp     = _generateOtp();
    final expires = DateTime.now().add(const Duration(minutes: 10));

    // Save to Firestore /otps/{email}
    await _db.collection('otps').doc(email).set({
      'otp':       otp,
      'email':     email,
      'expiresAt': Timestamp.fromDate(expires),
      'verified':  false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Build Gmail SMTP server
    final smtpServer = gmail(_gmailUser, _gmailPass);

    // Build email message
    final message = Message()
      ..from    = Address(_senderEmail, 'Kigali City Directory')
      ..recipients.add(email)
      ..subject = 'Your Verification Code – Kigali City Directory'
      ..html    = '''
<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;background-color:#f4f6f9;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f6f9;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background-color:#0D1B2A;padding:32px 40px;text-align:center;">
              <div style="display:inline-block;background-color:#F5A623;border-radius:12px;padding:10px 18px;margin-bottom:16px;">
                <span style="color:#0D1B2A;font-size:20px;font-weight:800;letter-spacing:1px;">KCD</span>
              </div>
              <h1 style="color:#ffffff;font-size:22px;font-weight:700;margin:0;">Kigali City Directory</h1>
              <p style="color:#B0BEC5;font-size:14px;margin:6px 0 0;">Email Verification</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:40px;">
              <p style="color:#333;font-size:16px;margin:0 0 8px;">Hello <strong>$displayName</strong>,</p>
              <p style="color:#555;font-size:15px;line-height:1.6;margin:0 0 28px;">
                Thank you for signing up! Use the verification code below to confirm your email address and complete your registration.
              </p>

              <!-- OTP Box -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <div style="background-color:#0D1B2A;border-radius:14px;padding:32px 40px;display:inline-block;text-align:center;">
                      <p style="color:#B0BEC5;font-size:13px;margin:0 0 12px;letter-spacing:2px;text-transform:uppercase;">Verification Code</p>
                      <div style="color:#F5A623;font-size:48px;font-weight:900;letter-spacing:16px;font-family:monospace;">$otp</div>
                      <p style="color:#607D8B;font-size:13px;margin:14px 0 0;">Expires in <strong style="color:#F5A623;">10 minutes</strong></p>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="color:#555;font-size:14px;line-height:1.7;margin:28px 0 0;">
                Enter this code in the app to verify your email and access Kigali City Directory. Do not share this code with anyone.
              </p>
            </td>
          </tr>

          <!-- Divider -->
          <tr>
            <td style="padding:0 40px;">
              <hr style="border:none;border-top:1px solid #eee;margin:0;">
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:24px 40px;text-align:center;">
              <p style="color:#999;font-size:12px;line-height:1.6;margin:0;">
                If you did not create an account with Kigali City Directory, you can safely ignore this email.<br>
                © 2025 Kigali City Directory. All rights reserved.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
      ''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      // Clean up Firestore if email failed
      await _db.collection('otps').doc(email).delete();
      throw Exception('Failed to send OTP. Please try again. ($e)');
    }
  }

  // Verify OTP
  Future<OtpResult> verifyOtp(String email, String enteredOtp) async {
    try {
      final doc = await _db.collection('otps').doc(email).get();

      if (!doc.exists) return OtpResult.notFound;

      final data      = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified  = data['verified'] as bool? ?? false;

      if (verified) return OtpResult.alreadyUsed;

      if (DateTime.now().isAfter(expiresAt)) {
        await _db.collection('otps').doc(email).delete();
        return OtpResult.expired;
      }

      if (enteredOtp.trim() != storedOtp) return OtpResult.invalid;

      // Mark as verified
      await _db.collection('otps').doc(email).update({'verified': true});
      return OtpResult.success;
    } catch (e) {
      return OtpResult.notFound;
    }
  }

  // Delete OTP after confirmed
  Future<void> deleteOtp(String email) async {
    try {
      await _db.collection('otps').doc(email).delete();
    } catch (_) {}
  }
}

enum OtpResult { success, invalid, expired, notFound, alreadyUsed }
