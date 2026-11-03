import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/ledger_entry.dart';
import '../../models/contact.dart';
import '../../config/colors.dart';

class UnmatchedPaymentsScreen extends StatefulWidget {
  final String eventId;
  const UnmatchedPaymentsScreen({super.key, required this.eventId});

  @override
  State<UnmatchedPaymentsScreen> createState() => _UnmatchedPaymentsScreenState();
}

class _UnmatchedPaymentsScreenState extends State<UnmatchedPaymentsScreen> {
  bool _isLoading = true;
  List<LedgerEntry> _unmatched = [];
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getEventDetail(widget.eventId);
      final ledger = data['ledger'] as List<LedgerEntry>;
      final contacts = await ApiService.getRecentContacts(); // Pre-load some contacts
      setState(() {
        _unmatched = ledger.where((e) => e.isUnmatched).toList();
        _unmatched.sort((a, b) => b.matchedAt.compareTo(a.matchedAt));
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _tagPayment(LedgerEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _TagPaymentModal(
        entry: entry,
        contacts: _contacts,
        onTagged: (contact) async {
          context.pop();
          setState(() => _isLoading = true);
          try {
            await ApiService.tagLedgerEntry(widget.eventId, entry.id, contact.id, contact.name);
            await _loadData();
          } catch (e) {
            setState(() => _isLoading = false);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unmatched Payments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _unmatched.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _unmatched.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = _unmatched[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.payerVpaOrPhone, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Ref: ${entry.txnRef}\n${DateFormat('MMM d, h:mm a').format(entry.matchedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+₹${entry.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _tagPayment(entry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: PayGoColors.oceanBlue,
                              elevation: 0,
                            ),
                            child: const Text('Tag'),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade300),
            const SizedBox(height: 24),
            const Text('All caught up!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'There are no unmatched payments for this event. Every transaction is tied to a participant.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPaymentModal extends StatefulWidget {
  final LedgerEntry entry;
  final List<Contact> contacts;
  final Function(Contact) onTagged;

  const _TagPaymentModal({required this.entry, required this.contacts, required this.onTagged});

  @override
  State<_TagPaymentModal> createState() => _TagPaymentModalState();
}

class _TagPaymentModalState extends State<_TagPaymentModal> {
  final _searchController = TextEditingController();
  List<Contact> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _results = widget.contacts;
  }

  void _search(String q) async {
    if (q.isEmpty) {
      setState(() {
        _results = widget.contacts;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await ApiService.searchContacts(q);
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tag Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Received ₹${widget.entry.amount.toStringAsFixed(0)} from ${widget.entry.payerVpaOrPhone}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No contacts found')),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final contact = _results[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: PayGoColors.oceanBlue.withValues(alpha: 0.1),
                      child: Text(contact.name[0].toUpperCase(), style: const TextStyle(color: PayGoColors.oceanBlue)),
                    ),
                    title: Text(contact.name),
                    subtitle: Text(contact.phone),
                    onTap: () => widget.onTagged(contact),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
