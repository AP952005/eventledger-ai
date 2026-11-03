import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../models/settlement_proof.dart';
import '../../models/event.dart';
import '../../config/colors.dart';

class SettlementProofScreen extends StatefulWidget {
  final String eventId;
  const SettlementProofScreen({super.key, required this.eventId});

  @override
  State<SettlementProofScreen> createState() => _SettlementProofScreenState();
}

class _SettlementProofScreenState extends State<SettlementProofScreen> {
  bool _isLoading = true;
  SettlementProof? _proof;
  CollectEvent? _event;

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
        _proof = verifyData['proof'] as SettlementProof?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePdf() async {
    if (_proof == null || _event == null) return;
    
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('payGO Event Collect - Settlement Proof', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Event: ${_event!.title}', style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Organizer: ${_event!.settlementName} (${_event!.settlementVpa})'),
              pw.Text('Closed At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_event!.closedAt ?? DateTime.now())}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text('Cryptographic Proof', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Key ID: ${_proof!.keyId}'),
              pw.Text('Signed At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_proof!.signedAt)}'),
              pw.SizedBox(height: 10),
              pw.Text('SHA-256 Hash:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_proof!.canonicalSnapshotHash, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 10),
              pw.Text('ECDSA Signature:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_proof!.signature, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  'This document serves as a cryptographically verifiable proof of the final event ledger state.',
                  style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'settlement_proof_${_event!.id}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_proof == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settlement Proof')),
        body: const Center(child: Text('Proof not found or event not yet closed.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlement Proof'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _generatePdf,
            tooltip: 'Print / Save PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.verified_user, size: 64, color: Colors.green.shade600),
                  const SizedBox(height: 16),
                  const Text('Cryptographically Verified', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 8),
                  const Text(
                    'The ledger state for this event has been hashed and signed. It is now immutable.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            const Text('Event Snapshot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _InfoRow(label: 'Event Title', value: _event!.title),
            _InfoRow(label: 'Organizer VPA', value: _event!.settlementVpa),
            _InfoRow(label: 'Closed At', value: DateFormat('MMM d, y, h:mm a').format(_event!.closedAt ?? DateTime.now())),
            const SizedBox(height: 32),

            const Text('Cryptographic Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _CopyableField(label: 'Key ID', value: _proof!.keyId),
            const SizedBox(height: 16),
            _CopyableField(label: 'SHA-256 Hash', value: _proof!.canonicalSnapshotHash),
            const SizedBox(height: 16),
            _CopyableField(label: 'ECDSA Signature', value: _proof!.signature),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Download PDF Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PayGoColors.oceanBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;
  const _CopyableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied')));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
