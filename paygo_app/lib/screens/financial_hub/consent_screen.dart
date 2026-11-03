/// PayGo — Consent Screen
/// Shows exactly what data will be accessed, purpose, date range, frequency.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/financial_service.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _toDate = DateTime.now();
  String _frequency = 'ONE_TIME';
  bool _isLoading = false;

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    try {
      await FinancialService.createConsent(
        purpose: 'Personal financial management',
        fromDate: _fromDate.toIso8601String(),
        toDate: _toDate.toIso8601String(),
        frequency: _frequency,
      );
      if (mounted) {
        context.push(AppRoutes.mockBankApproval);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Access Consent'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Financial data access', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Your app wants access to:', style: TextStyle(fontSize: 14,
              color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
            const SizedBox(height: 20),

            // Data types
            _DataTypeRow(icon: Icons.check_circle_rounded, label: 'Account information'),
            _DataTypeRow(icon: Icons.check_circle_rounded, label: 'Transactions'),
            _DataTypeRow(icon: Icons.check_circle_rounded, label: 'Transaction dates'),
            _DataTypeRow(icon: Icons.check_circle_rounded, label: 'Transaction amounts'),

            const SizedBox(height: 24),
            // Purpose
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF059669)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Purpose: Personal financial management\nYour data is used only within this app.',
                    style: TextStyle(fontSize: 13, height: 1.4))),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Date Range
            const Text('Period', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _DateButton(label: 'From', date: _fromDate, onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _fromDate,
                    firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (d != null) setState(() => _fromDate = d);
                })),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(child: _DateButton(label: 'To', date: _toDate, onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _toDate,
                    firstDate: _fromDate, lastDate: DateTime.now());
                  if (d != null) setState(() => _toDate = d);
                })),
              ],
            ),

            const SizedBox(height: 24),
            // Frequency
            const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _FreqOption(label: 'One-time', value: 'ONE_TIME', selected: _frequency,
                  onTap: () => setState(() => _frequency = 'ONE_TIME'))),
                const SizedBox(width: 12),
                Expanded(child: _FreqOption(label: 'Recurring', value: 'RECURRING', selected: _frequency,
                  onTap: () => setState(() => _frequency = 'RECURRING'))),
              ],
            ),

            const SizedBox(height: 16),
            // Privacy
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security_rounded, size: 16, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(child: Text('You will be redirected to approve this with your bank. Your bank credentials are never shared with us.',
                    style: TextStyle(fontSize: 12, height: 1.4))),
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataTypeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DataTypeRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF059669)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 14)),
            const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _FreqOption extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;
  const _FreqOption({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF059669) : Colors.grey.shade400, width: isSelected ? 2 : 1),
        ),
        child: Center(child: Text(label, style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          color: isSelected ? const Color(0xFF059669) : null,
        ))),
      ),
    );
  }
}
