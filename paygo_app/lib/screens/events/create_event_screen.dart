import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/event.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _amountController = TextEditingController();
  
  EventAmountMode _amountMode = EventAmountMode.fixed;
  bool _sameAmountFromEveryone = true;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  Future<void> _createEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    
    double? amount;
    if (_amountMode != EventAmountMode.flexible) {
      amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
        return;
      }
    }

    double? targetAmount = double.tryParse(_targetAmountController.text);

    setState(() => _isLoading = true);
    try {
      final event = await ApiService.createEvent(
        title: title,
        amountMode: _amountMode,
        amount: amount,
        targetAmount: targetAmount,
        sameAmountFromEveryone: _amountMode == EventAmountMode.fixed,
        expiryAt: _expiryDate,
      );
      if (mounted) {
        context.pushReplacement('${AppRoutes.eventDetail}?eventId=${event.id}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Title', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Goa Trip Fund',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Target Amount (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 50000',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Contribution Mode', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<EventAmountMode>(
              segments: const [
                ButtonSegment(value: EventAmountMode.fixed, label: Text('Fixed')),
                ButtonSegment(value: EventAmountMode.suggested, label: Text('Suggested')),
                ButtonSegment(value: EventAmountMode.flexible, label: Text('Flexible')),
              ],
              selected: {_amountMode},
              onSelectionChanged: (set) {
                setState(() {
                  _amountMode = set.first;
                  if (_amountMode == EventAmountMode.flexible) {
                    _sameAmountFromEveryone = false;
                  }
                });
              },
            ),
            const SizedBox(height: 6),
            Text(
              _amountMode == EventAmountMode.fixed
                  ? 'Everyone pays the exact same amount. Amount is locked in the QR.'
                  : _amountMode == EventAmountMode.suggested
                      ? 'Suggested amount shown in QR, but payer can change it.'
                      : 'No amount in QR — payer enters any amount they want.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            if (_amountMode != EventAmountMode.flexible) ...[
              Text(
                _amountMode == EventAmountMode.fixed ? 'Fixed Amount per Person' : 'Suggested Amount',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 500',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _expiryDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}', style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This event QR will be automatically disabled after 90 days.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PayGoColors.oceanBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Event QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
