import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/event.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  bool _isLoading = true;
  List<CollectEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await ApiService.getMyEvents();
      // Sort by creation date descending
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onCreateTap() {
    context.push(AppRoutes.createEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Pay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('What is Event Pay?'),
                  content: const Text('Create a dedicated QR code for group collections (trips, farewells, etc.). Money goes directly to your bank account via UPI. payGO does not hold your funds.'),
                  actions: [TextButton(onPressed: () => context.pop(), child: const Text('Got it'))],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyState()
              : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreateTap,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
        backgroundColor: PayGoColors.oceanBlue,
        foregroundColor: Colors.white,
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
            Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'No events yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create a dedicated QR code to collect money for trips, parties, and group gifts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 80, top: 16),
        itemCount: _events.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final event = _events[index];
          final isActive = event.status == EventStatus.active;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'CLOSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Target: ₹${event.targetAmount?.toStringAsFixed(0) ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('${AppRoutes.eventDetail}?eventId=${event.id}').then((_) => _loadEvents());
            },
          );
        },
      ),
    );
  }
}
