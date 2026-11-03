/// PayGo — Scan & Pay Screen
/// Camera placeholder with QR overlay for scanning.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class ScanAndPayScreen extends StatelessWidget {
  const ScanAndPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated camera background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      const Text(
                        'Scan QR Code',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // QR Scanner frame
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: PayGoColors.oceanBlue, width: 3),
                    ),
                    child: Stack(
                      children: [
                        // Corner accents
                        ..._cornerAccents(),
                        // Center content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'Place QR code here',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ScanAction(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gallery import — demo mode')),
                          );
                        },
                      ),
                      _ScanAction(
                        icon: Icons.qr_code_rounded,
                        label: 'My QR',
                        onTap: () => context.push(AppRoutes.myQR),
                      ),
                      _ScanAction(
                        icon: Icons.contacts_rounded,
                        label: 'To Contact',
                        onTap: () => context.push(AppRoutes.toMobileContact),
                      ),
                    ],
                  ),
                ),

                // Demo: simulate scan
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '${AppRoutes.confirmPayment}?name=Coffee%20Shop&upiId=coffeeshop@paygo',
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                      label: const Text('Simulate QR Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PayGoColors.oceanBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _cornerAccents() {
    const size = 30.0;
    const thickness = 4.0;
    const color = PayGoColors.oceanBlue;

    return [
      // Top-left
      Positioned(top: 0, left: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(top: 0, left: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      // Top-right
      Positioned(top: 0, right: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(top: 0, right: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      // Bottom-left
      Positioned(bottom: 0, left: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(bottom: 0, left: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      // Bottom-right
      Positioned(bottom: 0, right: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(bottom: 0, right: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
    ];
  }
}

class _ScanAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ScanAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
