import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'abishekpalani@paypal.sandbox');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _isLoading = false;

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PayPal White Card Container
                Container(
                  width: 420,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PayPal Official Style Wordmark
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Pay',
                            style: TextStyle(
                              color: Color(0xFF003087),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'Pal',
                            style: TextStyle(
                              color: Color(0xFF0070E0),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'PayGo AI Portal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: EventTreasuryColors.neutral,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email or mobile number',
                          labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF0070E0), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF0070E0), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Forgotten password link
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                          child: const Text(
                            'Forgotten password?',
                            style: TextStyle(
                              color: Color(0xFF0070E0),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Log In Pill Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0070E0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Log In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),

                      // Log in with Passkey Pill Button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.person_pin_circle_outlined, size: 18, color: Color(0xFF10213A)),
                        label: const Text('Log in with Passkey', style: TextStyle(color: Color(0xFF10213A), fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: _handleLogin,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF10213A), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // "or" Divider
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                          ),
                          Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Pill Button
                      OutlinedButton(
                        onPressed: _handleLogin,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF10213A), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Sign Up', style: TextStyle(color: Color(0xFF10213A), fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _footerLink('Contact Us'),
                    const SizedBox(width: 14),
                    _footerLink('Privacy'),
                    const SizedBox(width: 14),
                    _footerLink('Legal'),
                    const SizedBox(width: 14),
                    _footerLink('Worldwide'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}

