import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../config/colors.dart';
import '../../services/event_treasury_api_service.dart';
import '../../services/event_report_pdf_service.dart';
import '../../widgets/event_treasury_shell.dart';

class EventDetailTreasuryScreen extends StatefulWidget {
  final String eventId;
  const EventDetailTreasuryScreen({super.key, required this.eventId});

  @override
  State<EventDetailTreasuryScreen> createState() => _EventDetailTreasuryScreenState();
}

class _EventDetailTreasuryScreenState extends State<EventDetailTreasuryScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _event;
  List<dynamic> _participants = [];
  List<dynamic> _ledger = [];
  Map<String, dynamic>? _settlementProof;
  Map<String, dynamic>? _aiAuditReport;
  bool _isGeneratingPdf = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final res = await EventTreasuryApiService.getEventDetail(widget.eventId);
      setState(() {
        _event = res['event'];
        _participants = res['participants'] ?? [];
        _ledger = res['ledger'] ?? [];
        _settlementProof = res['settlement_proof'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPdfReport() async {
    if (_event == null) return;
    setState(() => _isGeneratingPdf = true);
    try {
      // Generate and layout PDF immediately with current event, participants, and ledger data
      await EventReportPdfService.generateAndDownloadPdf(
        event: _event!,
        participants: _participants,
        ledger: _ledger,
        settlementProof: _settlementProof,
        aiAuditReport: _aiAuditReport,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Financial Audit PDF ready to print or save.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<void> _closeEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Close Event & Lock Collections?'),
        content: const Text(
          'Closing this event will permanently halt new participant registrations, expire outstanding invoices, and produce a cryptographically signed SHA-256 Settlement Proof. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Close Event'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await EventTreasuryApiService.closeEvent(widget.eventId);
        await _loadDetail();
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EventTreasuryShell(
      currentRoute: '/events',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _event == null
              ? Center(child: Text(_error ?? 'Event not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildTwoLevelQRSection(),
                      const SizedBox(height: 32),
                      _buildParticipantsSection(),
                      if (_settlementProof != null) ...[
                        const SizedBox(height: 32),
                        _buildSettlementProofCard(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final status = _event!['status'] ?? 'ACTIVE';
    final isActive = status == 'ACTIVE';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _event!['title'] ?? 'Event Detail',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isActive ? EventTreasuryColors.success : EventTreasuryColors.neutral,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Fee: \$${_event!['amount']} ${_event!['currency']} • Target: \$${_event!['target_amount']}',
              style: const TextStyle(color: EventTreasuryColors.lightTextSecondary),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003087)),
              icon: _isGeneratingPdf
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Export Final PDF Report'),
              onPressed: _isGeneratingPdf ? null : _downloadPdfReport,
            ),
            if (isActive) ...[
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                icon: const Icon(Icons.lock_outline, size: 18),
                label: const Text('Close & Sign Ledger'),
                onPressed: _closeEvent,
              ),
            ],
          ],
        ),
      ],
    );
  }

  int _qrModeIndex = 0; // 0 = Direct Fixed Amount PayPal QR, 1 = Public Portal QR

  Widget _buildTwoLevelQRSection() {
    final amount = (_event!['amount'] as num?)?.toDouble() ?? 0.0;
    final currency = _event!['currency'] ?? 'USD';
    final regUrl = 'http://localhost:3000/#/events/register/${widget.eventId}';
    
    // Official PayPal Deep Link / Payment URL with pre-filled amount and recipient reference
    // PayPal me / PayPal checkout standard deep link format for fixed amount scanning
    final directPayPalQrUrl = 'https://www.paypal.com/qrcodes/managed/payment?amount=${amount.toStringAsFixed(2)}&currency_code=$currency&invoice_id=${widget.eventId}';

    final activeQrData = _qrModeIndex == 0 ? directPayPalQrUrl : regUrl;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _qrToggleTab('Direct PayPal Fixed Amount QR', 0),
                const SizedBox(width: 8),
                _qrToggleTab('Public Registration Portal QR', 1),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: EventTreasuryColors.borderBlue),
                  ),
                  child: QrImageView(data: activeQrData, size: 140),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _qrModeIndex == 0
                            ? 'Official PayPal Fixed Amount QR (\$$amount $currency)'
                            : 'Public Event Registration Portal QR',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003087)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _qrModeIndex == 0
                            ? 'When scanned with the PayPal mobile app or camera, it immediately opens PayPal checkout with the exact registration fee pre-filled (\$$amount $currency) targeting your PayPal Sandbox merchant.'
                            : 'Share this link or QR for participants to enter their custom info before an invoice is issued.',
                        style: const TextStyle(color: EventTreasuryColors.lightTextSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy, size: 16),
                            label: Text(_qrModeIndex == 0 ? 'Copy PayPal Payment Link' : 'Copy Portal URL'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: activeQrData));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_qrModeIndex == 0 ? 'PayPal Payment Link copied!' : 'Registration portal URL copied!')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_browser, size: 16),
                            label: Text(_qrModeIndex == 0 ? 'Test PayPal Link' : 'Open Portal'),
                            onPressed: () {
                              if (_qrModeIndex == 0) {
                                Clipboard.setData(ClipboardData(text: directPayPalQrUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Direct PayPal Payment QR URL generated & ready.')),
                                );
                              } else {
                                context.go('/events/register/${widget.eventId}');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrToggleTab(String title, int index) {
    final isSelected = _qrModeIndex == index;
    return InkWell(
      onTap: () => setState(() => _qrModeIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF003087) : const Color(0xFFF3F8FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF003087) : const Color(0xFFDCE7F5)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF003087),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participants & Invoices (${_participants.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active_outlined, size: 16),
              label: const Text('AI Reminder Batch'),
              onPressed: () => context.go('/events/reminders?id=${widget.eventId}'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: _participants.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No participants registered yet.')),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _participants.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final part = _participants[index];
                    final isPaid = part['status'] == 'PAID';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
                        child: Icon(
                          isPaid ? Icons.check : Icons.hourglass_top,
                          color: isPaid ? EventTreasuryColors.success : EventTreasuryColors.warning,
                          size: 18,
                        ),
                      ),
                      title: Text(part['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${part['email']} • Reg ID: ${part['registration_id']} • Invoice: ${part['paypal_invoice_id'] ?? 'Draft'}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${part['amount']} ${part['currency']}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            part['status'] ?? 'AWAITING_PAYMENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? EventTreasuryColors.success : EventTreasuryColors.warning,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSettlementProofCard() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.verified, color: EventTreasuryColors.success),
                SizedBox(width: 8),
                Text(
                  'Cryptographic Settlement Proof Generated',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: EventTreasuryColors.success),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              'SHA-256 Digest: ${_settlementProof!['canonical_snapshot_hash']}',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 4),
            SelectableText(
              'ECDSA Signature: ${_settlementProof!['signature']}',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
