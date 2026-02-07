import 'package:clerk_auth/clerk_auth.dart' as clerk_auth;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_provider.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // Show Clerk auth for email sign in
    _showClerkAuth();
  }

  /// Directly trigger Google OAuth sign-in using Clerk's ssoSignIn
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final authState = ClerkAuth.of(context, listen: false);
      // Clear Clerk session
      await authState.signOut();

      // Use Clerk's ssoSignIn to directly open Google OAuth
      await authState.ssoSignIn(context, clerk_auth.Strategy.oauthGoogle);

      // After successful sign in, sync user and navigate
      if (mounted && authState.user != null) {
        ref.read(currentUserProfileProvider.notifier).syncUser(authState.user!);
        context.go(RouteNames.home);
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showClerkAuth() {
    setState(() => _isLoading = false);
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => Container(
            height: MediaQuery.of(sheetContext).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ClerkErrorListener(
              child: ClerkAuthBuilder(
                signedInBuilder: (innerContext, authState) {
                  final user = authState.user;
                  if (user != null) {
                    ref
                        .read(currentUserProfileProvider.notifier)
                        .syncUser(user);
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_hasNavigated) {
                      _hasNavigated = true;
                      if (Navigator.of(sheetContext).canPop()) {
                        Navigator.of(sheetContext).pop();
                      }
                      context.go(RouteNames.home);
                    }
                  });
                  return const Center(child: CircularProgressIndicator());
                },
                signedOutBuilder: (innerContext, authState) {
                  return const ClerkAuthentication();
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) {
        final user = authState.user;
        if (user != null) {
          ref.read(currentUserProfileProvider.notifier).syncUser(user);
        }

        if (!_hasNavigated) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go(RouteNames.home);
          });
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      signedOutBuilder: (context, authState) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Photo collage at top
                    const ScatteredFloatingPhotos(),
                    // Content section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Pinterest Logo
                          const PinterestAuthLogo(assetPath: 'assets/icons/pinterest svg icon.svg',),
                          const SizedBox(height: 16),
                          // Tagline
                          const AuthTagline(),
                          const SizedBox(height: 24),
                          // Auth form
                          PinterestAuthForm(
                            emailController: _emailController,
                            onContinue: _handleContinue,
                            onGoogleTap: _handleGoogleSignIn,
                            onRecoverAccount: () {},
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 24),
                          // Terms footer
                          const AuthTermsFooter(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
