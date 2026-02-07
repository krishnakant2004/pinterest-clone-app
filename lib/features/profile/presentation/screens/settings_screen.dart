import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Account',
            items: [
              _SettingsItem(
                icon: Icons.person_outline,
                title: 'Account management',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.visibility_outlined,
                title: 'Profile visibility',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.tune_outlined,
                title: 'Home feed tuner',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Notifications',
            items: [
              _SettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Push notifications',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                title: 'Email notifications',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Privacy & Data',
            items: [
              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Privacy and data',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.security_outlined,
                title: 'Security',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Display',
            items: [
              _SettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'System default',
                onTap: () {
                  _showThemeDialog(context);
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'Support',
            items: [
              _SettingsItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                _showLogoutDialog(context, ref);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.pinterestRed,
                side: const BorderSide(color: AppColors.pinterestRed),
              ),
              child: const Text('Log out'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Light'),
                  leading: const Icon(Icons.light_mode_outlined),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  title: const Text('Dark'),
                  leading: const Icon(Icons.dark_mode_outlined),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  title: const Text('System default'),
                  leading: const Icon(Icons.settings_outlined),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Log out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  // Sign out from Clerk
                  try {
                    final clerk = ClerkAuth.of(context);
                    await clerk.signOut();
                  } catch (e) {
                    debugPrint('Clerk signOut error: $e');
                  }

                  // Clear local user data
                  await ref
                      .read(currentUserProfileProvider.notifier)
                      .clearUser();

                  // Navigate to login
                  if (context.mounted) {
                    context.go(RouteNames.login);
                  }
                },
                child: const Text(
                  'Log out',
                  style: TextStyle(color: AppColors.pinterestRed),
                ),
              ),
            ],
          ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
    );
  }
}
