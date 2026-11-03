/// PayGo — To Mobile Contact Screen
/// Contact search, recent contacts, and contact list for P2P transfer.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/mock_data.dart';
import '../../widgets/search_bar_widget.dart';

class ToMobileContactScreen extends StatefulWidget {
  const ToMobileContactScreen({super.key});

  @override
  State<ToMobileContactScreen> createState() => _ToMobileContactScreenState();
}

class _ToMobileContactScreenState extends State<ToMobileContactScreen> {
  String _query = '';

  List get _filteredContacts {
    if (_query.isEmpty) return MockData.contacts;
    final q = _query.toLowerCase();
    return MockData.contacts.where((c) =>
      c.name.toLowerCase().contains(q) || c.phone.contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recentContacts = MockData.recentContacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send to Contact'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PayGoSearchBar(
            placeholder: 'Search Name or Mobile Number',
            onChanged: (val) => setState(() => _query = val),
          ),

          // Recent contacts
          if (_query.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Recent', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentContacts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final c = recentContacts[index];
                  return GestureDetector(
                    onTap: () => context.push('${AppRoutes.confirmPayment}?name=${Uri.encodeComponent(c.name)}&upiId=${c.upiId}'),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: _avatarColor(index),
                          child: Text(c.initials, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 60,
                          child: Text(c.name.split(' ').first, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
          ],

          // All contacts
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(_query.isEmpty ? 'All Contacts' : 'Results', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final c = _filteredContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _avatarColor(index),
                    child: Text(c.initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  title: Text(c.name),
                  subtitle: Text(c.phone, style: TextStyle(fontSize: 12,
                    color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14,
                    color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                  onTap: () => context.push('${AppRoutes.confirmPayment}?name=${Uri.encodeComponent(c.name)}&upiId=${c.upiId}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _avatarColor(int index) {
    const colors = [PayGoColors.oceanBlue, PayGoColors.deepNavy, Color(0xFF6C63FF), Color(0xFF00BFA6), Color(0xFFFF6B6B)];
    return colors[index % colors.length];
  }
}
