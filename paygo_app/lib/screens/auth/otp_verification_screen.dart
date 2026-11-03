/// PayGo — OTP Verification Screen
/// 6-digit OTP input with auto-focus, countdown timer, resend.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phone;
  final String sessionId;

  const OTPVerificationScreen({
    super.key,
    required this.phone,
    required this.sessionId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final otp = _otp;
    if (otp.length != 6) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.verifyOTP(widget.sessionId, otp);
      if (mounted) {
        context.go(AppRoutes.pinSetup);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid OTP. Try: 123456'),
            backgroundColor: PayGoColors.error,
          ),
        );
        // Clear fields
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOtpFieldChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otp.length == 6) {
      _verify();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
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

              GestureDetector(
                onTap: () => context.pop(),
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
                'Verify OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.deepNavy,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 8),

              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to '),
                    TextSpan(
                      text: '+91 ${widget.phone}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 40),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace) {
                          _onBackspace(index);
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.deepNavy,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          filled: true,
                          fillColor: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: PayGoColors.oceanBlue, width: 2),
                          ),
                        ),
                        onChanged: (val) => _onOtpFieldChanged(index, val),
                      ),
                    ),
                  );
                }),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Resend / Countdown
              Center(
                child: _countdown > 0
                    ? Text(
                        'Resend OTP in ${_countdown}s',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          _startCountdown();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP resent! Use: 123456')),
                          );
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: PayGoColors.oceanBlue,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Hint for mock
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PayGoColors.oceanBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '💡 Demo OTP: 123456',
                    style: TextStyle(fontSize: 12, color: PayGoColors.oceanBlue, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const Spacer(),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: PayGoColors.oceanBlue),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
