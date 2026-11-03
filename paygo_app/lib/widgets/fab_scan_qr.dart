/// PayGo — FAB Scan QR Widget
/// Persistent floating action button for QR scanning.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class FabScanQR extends StatelessWidget {
  final VoidCallback onPressed;

  const FabScanQR({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: PayGoColors.oceanBlue.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: PayGoColors.oceanBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
        label: const Text(
          'Scan QR',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
