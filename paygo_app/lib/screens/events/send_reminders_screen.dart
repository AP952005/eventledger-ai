import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/reminder_template.dart';
import '../../models/contact.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';

class SendRemindersScreen extends StatefulWidget {
  final String eventId;
  const SendRemindersScreen({super.key, required this.eventId});

  @override
  State<SendRemindersScreen> createState() => _SendRemindersScreenState();
}

class _SendRemindersScreenState extends State<SendRemindersScreen> {
  bool _isLoading = true;
  CollectEvent? _event;
  List<ReminderTemplate> _templates = [];
  List<Contact> _contacts = [];
  
  ReminderTemplate? _selectedTemplate;
  final Set<String> _selectedContactIds = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final eventData = await ApiService.getEventDetail(widget.eventId);
      final templates = await ApiService.getReminderTemplates();
      final contacts = await ApiService.getRecentContacts();
      
      setState(() {
        _event = eventData['event'] as CollectEvent;
        _templates = templates;
        _contacts = contacts;
        if (_templates.isNotEmpty) _selectedTemplate = _templates.first;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReminders() async {
    if (_selectedTemplate == null || _selectedContactIds.isEmpty) return;
    
    setState(() => _isSending = true);
    try {
      await ApiService.sendReminders(widget.eventId, _selectedTemplate!.id, _selectedContactIds.toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminders sent to ${_selectedContactIds.length} people')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _toggleContact(String id) {
    setState(() {
      if (_selectedContactIds.contains(id)) {
        _selectedContactIds.remove(id);
      } else {
        _selectedContactIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Reminders')),
      body: Column(
        children: [
          // Info banner enforcing No-AI rule
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: PayGoColors.oceanBlue, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Reminders are manual. payGO does not auto-send messages or use AI to generate text. Choose a fixed template below.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // Template Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Template', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ReminderTemplate>(
                      isExpanded: true,
                      value: _selectedTemplate,
                      items: _templates.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedTemplate = v),
                    ),
                  ),
                ),
                if (_selectedTemplate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      _selectedTemplate!.bodyTemplate
                          .replaceAll('{participantName}', '[Name]')
                          .replaceAll('{amount}', _event!.amount != null ? '₹${_event!.amount}' : 'your contribution')
                          .replaceAll('{eventTitle}', _event!.title)
                          .replaceAll('{deadline}', DateFormat('MMM d').format(_event!.expiryAt)),
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),

          // Contact Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Recipients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedContactIds.length == _contacts.length) {
                        _selectedContactIds.clear();
                      } else {
                        _selectedContactIds.addAll(_contacts.map((c) => c.id));
                      }
                    });
                  },
                  child: Text(_selectedContactIds.length == _contacts.length ? 'Deselect All' : 'Select All'),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                final isSelected = _selectedContactIds.contains(contact.id);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleContact(contact.id),
                  title: Text(contact.name),
                  subtitle: Text(contact.phone),
                  secondary: CircleAvatar(
                    backgroundColor: PayGoColors.oceanBlue.withValues(alpha: 0.1),
                    child: Text(contact.name[0].toUpperCase(), style: const TextStyle(color: PayGoColors.oceanBlue)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSending || _selectedContactIds.isEmpty ? null : _sendReminders,
            style: ElevatedButton.styleFrom(
              backgroundColor: PayGoColors.oceanBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSending
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Send to ${_selectedContactIds.length} people', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
