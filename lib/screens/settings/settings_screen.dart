import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final auth        = context.watch<AuthProvider>();
    final user        = auth.user;
    final displayName = user?.displayName ?? 'User';
    final email       = user?.email ?? '';
    final initials    = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // ── Header ──────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 4),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Text(
              'My Account',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 28),

            // Profile card 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navyCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.navyBorder),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFFFBF47)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.darkNavy,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Preferences section
            _sectionLabel('PREFERENCES'),
            _settingsCard(
              children: [
                _toggleRow(
                  icon: Icons.notifications_rounded,
                  label: 'Location Notifications',
                  subtitle: 'Get alerts for nearby places',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Account section ──────────────────────────────────────────
            _sectionLabel('ACCOUNT'),
            _settingsCard(
              children: [
                _actionRow(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  color: AppColors.error,
                  onTap: () => _confirmSignOut(context, auth),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Footer
            const Center(
              child: Text(
                '© 2025 Kigali City Directory',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      );

  Widget _settingsCard({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: AppColors.navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navyBorder),
        ),
        child: Column(children: children),
      );

  Widget _toggleRow({
    required IconData icon,
    required String   label,
    required String   subtitle,
    required bool     value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.accent,
              trackColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? AppColors.accent.withOpacity(0.3)
                      : AppColors.navyBorder),
            ),
          ],
        ),
      );

  Widget _actionRow({
    required IconData  icon,
    required String    label,
    required Color     color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
        ),
      );

  Future<void> _confirmSignOut(
      BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await auth.signOut();
    }
  }
}
