import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/event_treasury_api_service.dart';
import '../../widgets/event_treasury_shell.dart';

class EventTreasuryListScreen extends StatefulWidget {
  const EventTreasuryListScreen({super.key});

  @override
  State<EventTreasuryListScreen> createState() => _EventTreasuryListScreenState();
}

class _EventTreasuryListScreenState extends State<EventTreasuryListScreen> {
  bool _isLoading = true;
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final list = await EventTreasuryApiService.listEvents();
    setState(() {
      _events = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EventTreasuryShell(
      currentRoute: AppRoutes.eventList,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Events & Collections',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Event'),
                          onPressed: () => context.go(AppRoutes.createEvent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_events.isEmpty)
                      const Center(child: Text('No events created yet.'))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _events.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final ev = _events[index];
                          final collected = (ev['collected_amount'] as num?)?.toDouble() ?? 0.0;
                          final target = (ev['target_amount'] as num?)?.toDouble() ?? 1.0;
                          final progress = (target > 0) ? (collected / target).clamp(0.0, 1.0) : 1.0;
                          final status = ev['status'] ?? 'ACTIVE';

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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: status == 'ACTIVE' ? Colors.green.shade50 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: status == 'ACTIVE' ? EventTreasuryColors.success : EventTreasuryColors.neutral,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$$collected / \$$target ${ev['currency'] ?? 'USD'}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    ev['title'] ?? 'Event',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ev['description'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: EventTreasuryColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(value: progress, color: EventTreasuryColors.paypalBlue, backgroundColor: Colors.grey.shade200),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(
                                        '${ev['paid_count'] ?? 0} paid • ${ev['registered_count'] ?? 0} total registered',
                                        style: const TextStyle(fontSize: 12, color: EventTreasuryColors.lightTextSecondary),
                                      ),
                                      const Spacer(),
                                      OutlinedButton(
                                        onPressed: () => context.go('/events/register/${ev['id']}'),
                                        child: const Text('Public Registration QR'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => context.go('/events/detail?id=${ev['id']}'),
                                        child: const Text('Manage Event'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
