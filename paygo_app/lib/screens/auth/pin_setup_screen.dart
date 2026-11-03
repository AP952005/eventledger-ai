/// PayGo — PIN Setup Screen
/// 4-digit UPI PIN setup with confirmation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onDigitPress(String digit) {
    setState(() {
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += digit;
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) setState(() => _isConfirming = true);
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
          if (_confirmPin.length == 4) {
            _submitPin();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (!_isConfirming) {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
        }
      }
    });
  }

  Future<void> _submitPin() async {
    if (_pin != _confirmPin) {
      setState(() {
        _confirmPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PINs don\'t match. Try again.'),
          backgroundColor: PayGoColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: PayGoColors.accentGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.lock_outline_rounded, size: 32, color: Colors.white),
                  ).animate().scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 24),

                  Text(
                    _isConfirming ? 'Confirm your PIN' : 'Set UPI PIN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.deepNavy,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isConfirming
                        ? 'Re-enter your 4-digit PIN'
                        : 'Create a 4-digit PIN for secure payments',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < currentPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: filled ? 18 : 16,
                  height: filled ? 18 : 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? PayGoColors.oceanBlue
                        : (isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
                    border: !filled
                        ? Border.all(
                            color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary,
                            width: 1.5,
                          )
                        : null,
                  ),
                );
              }),
            ),

            const Spacer(),

            // Number pad
            if (_isLoading)
              const CircularProgressIndicator(color: PayGoColors.oceanBlue)
            else
              _NumberPad(
                onDigitPress: _onDigitPress,
                onBackspace: _onBackspace,
                isDark: isDark,
              ),

            const SizedBox(height: 40),

            // Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PayGoColors.oceanBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 Demo PIN: 1234',
                style: TextStyle(fontSize: 12, color: PayGoColors.oceanBlue, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String) onDigitPress;
  final VoidCallback onBackspace;
  final bool isDark;

  const _NumberPad({
    required this.onDigitPress,
    required this.onBackspace,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: digits.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((d) {
              if (d.isEmpty) return const SizedBox(width: 72, height: 64);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (d == '⌫') {
                    onBackspace();
                  } else {
                    onDigitPress(d);
                  }
                },
                child: Container(
                  width: 72,
                  height: 64,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: d == '⌫'
                        ? Icon(Icons.backspace_outlined, size: 22,
                            color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)
                        : Text(
                            d,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
