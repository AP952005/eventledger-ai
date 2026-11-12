import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class EventReportPdfService {
  static Future<void> generateAndDownloadPdf({
    required Map<String, dynamic> event,
    required List<dynamic> participants,
    required List<dynamic> ledger,
    Map<String, dynamic>? settlementProof,
    Map<String, dynamic>? aiAuditReport,
  }) async {
    final pdf = pw.Document();

    final title = event['title'] ?? 'Event';
    final currency = event['currency'] ?? 'USD';
    final amount = (event['amount'] as num?)?.toDouble() ?? 0.0;
    final target = (event['target_amount'] as num?)?.toDouble() ?? 0.0;
    final status = event['status'] ?? 'ACTIVE';

    final totalCollected = ledger.fold<double>(0.0, (sum, item) {
      final amt = (item['amount'] as num?)?.toDouble() ?? 0.0;
      return sum + amt;
    });

    final paidCount = participants.where((p) => p['payment_status'] == 'CAPTURED' || p['status'] == 'PAID').length;
    final pendingCount = participants.length - paidCount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PayGo AI', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text('Official Event Financial Audit & Settlement Report', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  pw.Text('Powered by PayPal REST Invoicing v2', style: pw.TextStyle(fontSize: 10, color: PdfColors.blue700)),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text('STATUS: $status', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 12),

          // Event Summary Table
          pw.Text('Event Overview', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Event Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(title)),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Registration Fee', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('\$$amount $currency')),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Collection Target', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('\$$target $currency')),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total Verified Collections', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('\$$totalCollected $currency', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800))),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Participant Roster', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${participants.length} registered ($paidCount paid, $pendingCount pending)')),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Gemini AI Executive Summary
          if (aiAuditReport != null && aiAuditReport['executive_summary'] != null) ...[
            pw.Text('Gemini AI Executive Assessment', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Text(
                aiAuditReport['executive_summary'],
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.3),
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Verified Participant Roster & Ledger
          pw.Text('Participant Invoicing & Ledger Records', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Name', 'Email', 'Registration ID', 'Invoice Ref', 'Status', 'Amount'],
            data: participants.map((p) => [
              p['name'] ?? '',
              p['email'] ?? '',
              p['registration_id'] ?? '',
              p['paypal_invoice_id'] ?? '-',
              p['payment_status'] ?? p['status'] ?? 'UNPAID',
              '\$${p['amount']} $currency',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(5),
          ),
          pw.SizedBox(height: 16),

          // Cryptographic Proof (if event closed)
          if (settlementProof != null) ...[
            pw.Text('Cryptographic Settlement Proof (SHA-256 / ECDSA)', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                border: pw.Border.all(color: PdfColors.green300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Canonical Snapshot Hash: ${settlementProof['canonical_snapshot_hash']}', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800)),
                  pw.SizedBox(height: 3),
                  pw.Text('ECDSA Signature: ${settlementProof['signature']}', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800)),
                  pw.SizedBox(height: 3),
                  pw.Text('Key ID: ${settlementProof['key_id']} • Signed: ${settlementProof['signed_at']}', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800)),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('PayGo Financial Systems • Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.Text('Verified by PayPal Sandbox REST API v2', style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue800, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );

    // Save and print/download
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}_Financial_Report.pdf',
    );
  }
}

