/// PayGo — Confirm Payment Screen
/// Payee card, amount input, note, pay button with UPI PIN bottom sheet.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  final String payeeName;
  final String payeeUpiId;

  const ConfirmPaymentScreen({
    super.key,
    required this.payeeName,
    required this.payeeUpiId,
  });

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  void _showPinSheet() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UPIPinSheet(
        amount: amount,
        payeeName: widget.payeeName,
        note: _noteController.text,
        onSuccess: () {
          Navigator.pop(ctx);
          _showSuccessDialog(amount);
        },
        onFailure: (reason) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(reason), backgroundColor: PayGoColors.error),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: PayGoColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 48, color: PayGoColors.success),
            ),
            const SizedBox(height: 16),
            const Text('Payment Successful! 🎉', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('₹${amount.toStringAsFixed(0)} sent to ${widget.payeeName}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.home);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Payee card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? PayGoColors.darkCard : PayGoColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: PayGoColors.oceanBlue,
                    child: Text(
                      widget.payeeName.isNotEmpty ? widget.payeeName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.payeeName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
                        const SizedBox(height: 2),
                        Text(widget.payeeUpiId, style: TextStyle(fontSize: 13,
                          color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_rounded, color: PayGoColors.oceanBlue, size: 22),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Amount input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300,
                  color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                const SizedBox(width: 4),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.deepNavy,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      hintText: '0',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Note input
            TextField(
              controller: _noteController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
              ),
            ),

            const Spacer(),

            // Pay button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _showPinSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PayGoColors.oceanBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _UPIPinSheet extends StatefulWidget {
  final double amount;
  final String payeeName;
  final String note;
  final VoidCallback onSuccess;
  final ValueChanged<String> onFailure;

  const _UPIPinSheet({required this.amount, required this.payeeName, required this.note, required this.onSuccess, required this.onFailure});

  @override
  State<_UPIPinSheet> createState() => _UPIPinSheetState();
}

class _UPIPinSheetState extends State<_UPIPinSheet> {
  String _pin = '';
  bool _isProcessing = false;

  void _onDigit(String d) async {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);

    if (_pin.length == 4) {
      setState(() => _isProcessing = true);
      try {
        final result = await ApiService.initiatePayment(
          payeeUpiId: widget.payeeName,
          amount: widget.amount,
          category: 'p2p',
          note: widget.note,
        );
        final confirm = await ApiService.confirmPayment(result['txn_id'], _pin);
        if (confirm['status'] == 'success') {
          widget.onSuccess();
        } else {
          widget.onFailure(confirm['reason'] ?? 'Payment failed');
        }
      } catch (e) {
        widget.onFailure('Error: $e');
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty && !_isProcessing) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Enter UPI PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('₹${widget.amount.toStringAsFixed(0)} to ${widget.payeeName}', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          Text('💡 Demo PIN: 1234', style: TextStyle(fontSize: 11, color: PayGoColors.oceanBlue)),
          const SizedBox(height: 20),

          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 14, height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < _pin.length ? PayGoColors.oceanBlue : Colors.grey.shade300,
              ),
            )),
          ),

          if (_isProcessing) ...[
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: PayGoColors.oceanBlue),
          ] else ...[
            const SizedBox(height: 24),
            // Mini keypad
            ...List.generate(4, (row) {
              final digits = [['1','2','3'], ['4','5','6'], ['7','8','9'], ['','0','⌫']][row];
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: digits.map((d) {
                  if (d.isEmpty) return const SizedBox(width: 64, height: 52);
                  return GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); d == '⌫' ? _onBackspace() : _onDigit(d); },
                    child: Container(
                      width: 64, height: 52, margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: d == '⌫'
                        ? const Icon(Icons.backspace_outlined, size: 20)
                        : Text(d, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ],
      ),
    );
  }
}
