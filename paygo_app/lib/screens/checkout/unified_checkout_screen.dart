/// EventLedger AI — Unified Multi-Provider Checkout Screen
/// Dynamically routes to Cashfree UPI QR (Domestic INR) or PayPal Invoicing QR (International USD/EUR).
/// Verifies backend amounts and supports browser refresh status recovery.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/colors.dart';
import '../../services/event_treasury_api_service.dart';

class UnifiedCheckoutScreen extends StatefulWidget {
  final String orderId;
  const UnifiedCheckoutScreen({super.key, required this.orderId});

  @override
  State<UnifiedCheckoutScreen> createState() => _UnifiedCheckoutScreenState();
}

class _UnifiedCheckoutScreenState extends State<UnifiedCheckoutScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderData;
  String? _error;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderStatus();
  }

  Future<void> _fetchOrderStatus() async {
    setState(() => _isLoading = true);
    try {
      final res = await EventTreasuryApiService.getPaymentOrderStatus(widget.orderId);
      setState(() {
        _orderData = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifySandboxPayment() async {
    setState(() => _isVerifying = true);
    try {
      await EventTreasuryApiService.verifySandboxPaymentOrder(widget.orderId);
      await _fetchOrderStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF10B981),
            content: Text('Payment verified and recorded in the authoritative ledger!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _orderData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Unable to load payment order'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchOrderStatus, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final order = _orderData!['order'] as Map<String, dynamic>;
    final status = _orderData!['status'] as String? ?? 'PENDING';
    final isSuccess = status == 'SUCCESS';
    final provider = order['provider'] as String? ?? 'PAYPAL';
    final isCashfree = provider == 'CASHFREE';
    final amount = (order['amount'] as num?)?.toDouble() ?? 0.0;
    final currency = order['currency'] as String? ?? 'USD';

    final attempts = _orderData!['attempts'] as List<dynamic>? ?? [];
    final latestAttempt = attempts.isNotEmpty ? attempts.last as Map<String, dynamic> : null;
    final qrData = latestAttempt?['provider_qr_data'] as String? ?? '';
    final paymentUrl = latestAttempt?['provider_payment_url'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('EventLedger AI — Checkout'),
        backgroundColor: const Color(0xFF001C64),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/events');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: _fetchOrderStatus,
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // Provider Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isCashfree ? const Color(0xFFFFF1F2) : const Color(0xFFEBF3FC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCashfree ? Icons.qr_code_2 : Icons.payments_outlined,
                                size: 16,
                                color: isCashfree ? const Color(0xFFE11D48) : const Color(0xFF003087),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isCashfree ? 'Cashfree UPI Sandbox' : 'PayPal Invoicing v2',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCashfree ? const Color(0xFFE11D48) : const Color(0xFF003087),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Order Details
                    Text(
                      '$currency ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order Ref: ${widget.orderId}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const Divider(height: 32),

                    // QR Display
                    if (!isSuccess) ...[
                      Text(
                        isCashfree ? 'Scan with any UPI App (GPay, PhonePe, Paytm)' : 'Scan with PayPal App or Camera',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: !isCashfree && qrData.length > 200
                            ? Image.memory(base64Decode(qrData), width: 220, height: 220)
                            : QrImageView(
                                data: qrData.isNotEmpty ? qrData : paymentUrl,
                                size: 220,
                              ),
                      ),
                      const SizedBox(height: 16),
                      if (paymentUrl.isNotEmpty) ...[
                        OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: Text(isCashfree ? 'Open Hosted UPI Checkout' : 'Open PayPal Invoice'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: paymentUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment link copied to clipboard!')),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                          icon: const Icon(Icons.verified_rounded, size: 18),
                          label: _isVerifying
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Simulate / Verify Sandbox Payment'),
                          onPressed: _isVerifying ? null : _verifySandboxPayment,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 64),
                      const SizedBox(height: 16),
                      const Text('Payment Completed Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                        'Verified and immutably settled in the EventLedger AI Master Ledger.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001C64), foregroundColor: Colors.white),
                        onPressed: () => context.go('/events'),
                        child: const Text('Return to Events Dashboard'),
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

