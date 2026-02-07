import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

/// Pinterest logo for auth screen
class PinterestAuthLogo extends StatelessWidget {
  final String assetPath;
  const PinterestAuthLogo({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: 48,
      height: 48,
    );
  }
}

/// "Create a life you love" tagline - BLACK text on white background
class AuthTagline extends StatelessWidget {
  const AuthTagline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Create a life\nyou love',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
    );
  }
}

/// Main auth form section matching Pinterest exactly
class PinterestAuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onContinue;
  final VoidCallback onGoogleTap;
  final VoidCallback? onRecoverAccount;
  final bool isLoading;

  const PinterestAuthForm({
    super.key,
    required this.emailController,
    required this.onContinue,
    required this.onGoogleTap,
    this.onRecoverAccount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field - white with grey border
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
          ),
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Email address',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Continue button - RED
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed:
                isLoading
                    ? null
                    : () {
                      HapticFeedback.mediumImpact();
                      onContinue();
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinterestRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.pinterestRed.withValues(
                alpha: 0.7,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        // Google button - white with grey border
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onGoogleTap();
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/google svg icon.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Facebook notice - dark text
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'Facebook login is no longer\navailable. '),
              TextSpan(
                text: 'Recover your account',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = onRecoverAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Terms and conditions footer - dark grey text
class AuthTermsFooter extends StatelessWidget {
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onNoticeTap;

  const AuthTermsFooter({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onNoticeTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
        children: [
          const TextSpan(text: "By continuing, you agree to Pinterest's "),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.black87,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
          ),
          const TextSpan(text: " and acknowledge that you've read our "),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.black87,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
          const TextSpan(text: '. '),
          TextSpan(
            text: 'Notice at collection',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.black87,
            ),
            recognizer: TapGestureRecognizer()..onTap = onNoticeTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
