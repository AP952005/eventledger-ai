import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/event.dart';
import '../../models/ledger_entry.dart';
import '../../models/settlement_proof.dart';

class PublicVerifyScreen extends StatefulWidget {
  final String eventId;
  const PublicVerifyScreen({super.key, required this.eventId});

  @override
  State<PublicVerifyScreen> createState() => _PublicVerifyScreenState();
}

class _PublicVerifyScreenState extends State<PublicVerifyScreen> {
  bool _isLoading = true;
  CollectEvent? _event;
  List<LedgerEntry> _ledger = [];
  SettlementProof? _proof;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final verifyData = await ApiService.verifyEvent(widget.eventId);
      setState(() {
        _event = verifyData['event'] as CollectEvent;
        _ledger = verifyData['ledger'] as List<LedgerEntry>;
        _proof = verifyData['proof'] as SettlementProof?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Could not verify event: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verify Event')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(_error ?? 'Event not found', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final isClosed = _event!.status == EventStatus.closed;
    final totalCollected = _ledger.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: isClosed ? Colors.green.shade50 : Colors.blue.shade50,
              child: Column(
                children: [
                  Icon(
                    isClosed ? Icons.verified : Icons.sync,
                    size: 48,
                    color: isClosed ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isClosed ? 'Cryptographically Verified Ledger' : 'Active Event Ledger',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isClosed ? Colors.green.shade800 : Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isClosed
                        ? 'This event is closed and its ledger is immutable.'
                        : 'This event is currently active. The ledger updates in real-time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isClosed ? Colors.green.shade700 : Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Event Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Title', value: _event!.title),
                  _InfoRow(label: 'Organizer', value: _event!.settlementName),
                  _InfoRow(label: 'Total Collected', value: '₹${totalCollected.toStringAsFixed(2)}'),
                  if (isClosed && _event!.closedAt != null)
                    _InfoRow(label: 'Closed At', value: DateFormat('MMM d, y, h:mm a').format(_event!.closedAt!)),
                  const SizedBox(height: 24),

                  if (isClosed && _proof != null) ...[
                    const Divider(),
                    const SizedBox(height: 24),
                    const Text('Cryptographic Proof', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'SHA-256 Hash', value: _proof!.canonicalSnapshotHash.substring(0, 16) + '...'),
                    _InfoRow(label: 'Signature', value: _proof!.signature.substring(0, 16) + '...'),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  const Text('Public Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('This public view only shows partially obfuscated VPAs/phones for privacy.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),

                  if (_ledger.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('No payments recorded yet', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ledger.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = _ledger[index];
                        // Obfuscate payer VPA for public view
                        final payer = entry.payerVpaOrPhone;
                        final obfuscatedPayer = payer.length > 5
                            ? '${payer.substring(0, 2)}***${payer.substring(payer.length - 2)}'
                            : '***';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry.participantName ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('$obfuscatedPayer\n${DateFormat('MMM d, h:mm a').format(entry.matchedAt)}', style: const TextStyle(fontSize: 12)),
                          trailing: Text('+₹${entry.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                          isThreeLine: true,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontFamily: value.contains('...') ? 'monospace' : null))),
        ],
      ),
    );
  }
}
