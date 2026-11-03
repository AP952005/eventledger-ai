/// PayGo — Consent Management Screen
/// View active/expired/revoked consents, revoke consent, consent artifact details.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../services/financial_service.dart';
import '../../models/consent.dart';

class ConsentManagementScreen extends StatefulWidget {
  const ConsentManagementScreen({super.key});

  @override
  State<ConsentManagementScreen> createState() => _ConsentManagementScreenState();
}

class _ConsentManagementScreenState extends State<ConsentManagementScreen> {
  List<Consent> _consents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final consents = await FinancialService.listConsents();
    setState(() { _consents = consents; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Management'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _consents.isEmpty
              ? const Center(child: Text('No consents found', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _consents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = _consents[index];
                    return _ConsentCard(consent: c, isDark: isDark, onRevoke: () => _revokeConsent(c));
                  },
                ),
    );
  }

  void _revokeConsent(Consent consent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Consent?'),
        content: Text('This will revoke data access consent ${consent.consentId}. No new data will be fetched.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FinancialService.revokeConsent(consent.consentId);
              _load();
            },
            child: const Text('Revoke', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  final Consent consent;
  final bool isDark;
  final VoidCallback onRevoke;

  const _ConsentCard({required this.consent, required this.isDark, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'APPROVED': Colors.green, 'PENDING': Colors.orange,
      'REJECTED': Colors.red, 'EXPIRED': Colors.grey, 'REVOKED': Colors.grey,
    };
    final color = statusColors[consent.status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PayGoColors.darkCardElevated : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.verified_user_rounded, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(consent.consentId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                    if (consent.bankName != null)
                      Text(consent.bankName!, style: TextStyle(fontSize: 12, color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(consent.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Consent artifact details
          _DetailRow(label: 'Purpose', value: consent.purpose),
          _DetailRow(label: 'Frequency', value: consent.frequency),
          if (consent.dataTypes.isNotEmpty)
            _DetailRow(label: 'Data Types', value: consent.dataTypes.join(', ')),
          if (consent.createdAt.isNotEmpty)
            _DetailRow(label: 'Created', value: _formatDate(consent.createdAt)),

          if (consent.status == 'APPROVED') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRevoke,
                icon: const Icon(Icons.block_rounded, size: 16, color: Colors.red),
                label: const Text('Revoke Consent', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
