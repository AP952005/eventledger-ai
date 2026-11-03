import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class EventAliasSetupScreen extends StatefulWidget {
  const EventAliasSetupScreen({super.key});

  @override
  State<EventAliasSetupScreen> createState() => _EventAliasSetupScreenState();
}

class _EventAliasSetupScreenState extends State<EventAliasSetupScreen> {
  final _handleController = TextEditingController();
  bool _isLoading = false;
  bool? _isAvailable;
  String _errorMessage = '';

  Future<void> _checkAvailability() async {
    final handle = _handleController.text.trim();
    if (handle.length < 3) return;
    setState(() => _isLoading = true);
    try {
      final available = await ApiService.checkAliasAvailability(handle);
      setState(() {
        _isAvailable = available;
        _errorMessage = available ? '' : 'Handle already taken';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _registerAlias() async {
    if (_isAvailable != true) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.registerAlias(_handleController.text.trim());
      // Re-fetch user to get the updated eventVpa
      await ApiService.getUserProfile();
      if (mounted) {
        context.pushReplacement(AppRoutes.createEvent);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Registration failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Event Alias')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: isDark ? Colors.blue.shade200 : PayGoColors.oceanBlue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This alias hides your phone number from event QR codes. Your registered account name will still be shown to anyone who scans and pays — this is a UPI network rule, not something payGO can turn off.',
                      style: TextStyle(height: 1.4, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Choose an Alias Handle', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _handleController,
              decoration: InputDecoration(
                hintText: 'e.g. csfarewell',
                suffixText: '@paygo',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: _checkAvailability,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) {
                setState(() {
                  _isAvailable = null;
                  _errorMessage = '';
                });
              },
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            if (_isAvailable == true)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Available!', style: TextStyle(color: Colors.green, fontSize: 12)),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAvailable == true && !_isLoading ? _registerAlias : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PayGoColors.oceanBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Register & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
