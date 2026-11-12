import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../config/colors.dart';
import '../../services/event_treasury_api_service.dart';

class PublicEventRegistrationScreen extends StatefulWidget {
  final String eventId;
  const PublicEventRegistrationScreen({super.key, required this.eventId});

  @override
  State<PublicEventRegistrationScreen> createState() => _PublicEventRegistrationScreenState();
}

class _PublicEventRegistrationScreenState extends State<PublicEventRegistrationScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _event;
  String? _error;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  // Level 2 Result
  Map<String, dynamic>? _registeredParticipant;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() => _isLoading = true);
    try {
      final data = await EventTreasuryApiService.getEventDetail(widget.eventId);
      setState(() {
        _event = data['event'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name and valid email address.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final participant = await EventTreasuryApiService.registerParticipant(
        widget.eventId,
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
      );
      setState(() {
        _registeredParticipant = participant;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e')),
      );
    }
  }

  Future<void> _simulateSandboxPayment() async {
    if (_registeredParticipant == null) return;
    setState(() => _isSubmitting = true);
    try {
      final res = await EventTreasuryApiService.verifySandboxPayment(_registeredParticipant!['id']);
      setState(() {
        _registeredParticipant = res['participant'];
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: EventTreasuryColors.success,
            content: Text('Payment verified via PayPal Sandbox! Registration confirmed.'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Registration')),
        body: Center(child: Text(_error ?? 'Event not found')),
      );
    }

    final isPaid = _registeredParticipant != null && _registeredParticipant!['status'] == 'PAID';

    return Scaffold(
      backgroundColor: EventTreasuryColors.lightBg,
      appBar: AppBar(
        title: const Text('PayGo Registration (PayPal Sandbox)'),
        backgroundColor: Colors.white,
        elevation: 1,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _registeredParticipant == null
                ? _buildRegistrationForm()
                : _buildPayPalPaymentView(isPaid),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    final amount = (_event!['amount'] as num?)?.toDouble() ?? 0.0;
    final currency = _event!['currency'] ?? 'USD';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EventTreasuryColors.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _event!['category'] ?? 'Event',
                    style: const TextStyle(
                      color: EventTreasuryColors.paypalBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$$amount $currency',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: EventTreasuryColors.paypalNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _event!['title'] ?? 'Event',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _event!['description'] ?? '',
              style: const TextStyle(color: EventTreasuryColors.lightTextSecondary),
            ),
            const Divider(height: 32),
            const Text(
              'Participant Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Proceed to PayPal Invoice (\$$amount $currency)'),
                onPressed: _isSubmitting ? null : _handleRegister,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '🔒 Secured with PayPal REST Invoicing v2 Engine',
                style: TextStyle(fontSize: 11, color: EventTreasuryColors.neutral),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayPalPaymentView(bool isPaid) {
    final part = _registeredParticipant!;
    final qrBase64 = part['paypal_qr_base64'] as String?;
    final paymentUrl = part['paypal_payment_url'] as String? ?? 'https://www.sandbox.paypal.com';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              isPaid ? Icons.check_circle_outline : Icons.qr_code_scanner,
              size: 56,
              color: isPaid ? EventTreasuryColors.success : EventTreasuryColors.paypalBlue,
            ),
            const SizedBox(height: 12),
            Text(
              isPaid ? 'Payment Confirmed!' : 'Official PayPal Payment QR',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              isPaid
                  ? 'Your event spot has been secured in the verified ledger.'
                  : 'Scan with your phone or open the PayPal sandbox checkout link.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: EventTreasuryColors.lightTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            // Render QR Code (Level 2 PayPal QR)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EventTreasuryColors.borderBlue),
              ),
              child: qrBase64 != null && qrBase64.isNotEmpty
                  ? Image.memory(base64Decode(qrBase64), width: 220, height: 220)
                  : QrImageView(data: paymentUrl, size: 220),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: EventTreasuryColors.lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Invoice Ref: ${part['paypal_invoice_id'] ?? 'INV2-SBX'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EventTreasuryColors.paypalNavy),
              ),
            ),
            const SizedBox(height: 20),
            if (!isPaid) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy PayPal Payment Link'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: paymentUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PayPal Payment Link copied!')),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: EventTreasuryColors.success),
                  icon: const Icon(Icons.verified),
                  label: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Verify Sandbox Payment'),
                  onPressed: _isSubmitting ? null : _simulateSandboxPayment,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Registration ID: ${part['registration_id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text(
                      'Txn Ref: ${part['transaction_reference'] ?? 'PAYID-CONFIRMED'}',
                      style: TextStyle(fontSize: 11, color: Colors.green.shade800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/events'),
                child: const Text('Return to Events'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

