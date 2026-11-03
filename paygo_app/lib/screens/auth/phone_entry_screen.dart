/// PayGo — Phone Entry Screen
/// Phone number input with country code for auth flow.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _isValid = _phoneController.text.length == 10;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    try {
      final sessionId = await ApiService.requestOTP('+91${_phoneController.text}');
      if (mounted) {
        context.push(
          '${AppRoutes.otpVerification}?phone=${_phoneController.text}&sessionId=$sessionId',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Back button
              GestureDetector(
                onTap: () => context.go(AppRoutes.onboarding),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Enter your\nmobile number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.deepNavy,
                  height: 1.2,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              Text(
                'We\'ll send you a verification code',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 40),

              // Phone input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isValid ? PayGoColors.oceanBlue : (isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
                    width: _isValid ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? PayGoColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🇮🇳 +91',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
                          letterSpacing: 2,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: '98765 43210',
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const Spacer(),

              // Proceed button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isValid && !_isLoading ? _proceed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PayGoColors.oceanBlue,
                    disabledBackgroundColor: PayGoColors.oceanBlue.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
