import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/driver/driver_verification_status_screen.dart';
import 'package:testtale3/screens/passenger/passenger_verification_success_screen.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final UserRole role;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _pollTimer;
  Timer? _resendCooldownTimer;
  int _resendCooldown = 0;
  bool _isCheckingManually = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!mounted) return;
      final verified =
          await context.read<app_auth.AuthProvider>().checkEmailVerified();
      if (verified && mounted) {
        _pollTimer?.cancel();
        _navigateNext();
      }
    });
  }

  void _navigateNext() {
    if (widget.role == UserRole.passenger) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const PassengerVerificationSuccessScreen(),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const DriverVerificationStatusScreen(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _handleManualCheck() async {
    setState(() => _isCheckingManually = true);
    final verified =
        await context.read<app_auth.AuthProvider>().checkEmailVerified();
    if (!mounted) return;
    setState(() => _isCheckingManually = false);
    if (verified) {
      _pollTimer?.cancel();
      _navigateNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.emailNotYetVerified),
          backgroundColor: AppStyles.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0) return;
    final error =
        await context.read<app_auth.AuthProvider>().sendVerificationEmail();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      setState(() => _resendCooldown = 60);
      _resendCooldownTimer =
          Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) t.cancel();
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.verificationCodeResent),
          backgroundColor: AppStyles.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.verifyYourEmail,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Decorative email icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.highlightBackgroundColor
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.highlightBackgroundColor,
                    ),
                  ),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppStyles.primaryColor,
                    ),
                    child: const Icon(
                      Icons.mail_outline_rounded,
                      color: AppStyles.onPrimary,
                      size: 34,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Title
              Text(
                context.l10n.checkYourInbox,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Description with bold email
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                    height: 1.6,
                  ),
                  children: [
                    TextSpan(text: '${context.l10n.emailLinkSentTo} '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                    TextSpan(
                        text: '.\n${context.l10n.emailVerifyInstructions}'),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Waiting indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppStyles.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.waitingForVerification,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Resend section
              Text(
                context.l10n.didntReceiveEmail,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
              _resendCooldown > 0
                  ? Text(
                      '${context.l10n.resendIn} $_resendCooldown s',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textTertiary,
                      ),
                    )
                  : GestureDetector(
                      onTap: _handleResend,
                      child: Text(
                        context.l10n.resendEmail,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),

              const Spacer(),

              // Manual verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isCheckingManually ? null : _handleManualCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.darkMaroon,
                    foregroundColor: AppStyles.onPrimary,
                    disabledBackgroundColor: context.colors.borderColor,
                    disabledForegroundColor: context.colors.textTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isCheckingManually
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppStyles.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.iVerifiedMyEmail,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_outline, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
