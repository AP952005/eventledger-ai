/// PayGo — Search Screen
/// Global search with categorized results.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../widgets/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  final _allActions = [
    _SearchAction('Send Money', Icons.send_rounded, 'Transfer money to anyone', AppRoutes.toMobileContact),
    _SearchAction('Event Pay', Icons.groups_rounded, 'Collect money for group events', AppRoutes.eventList),
    _SearchAction('Financial Hub', Icons.account_balance_rounded, 'Merge bank accounts & track spending', AppRoutes.financialHub),
    _SearchAction('Spending Summary', Icons.pie_chart_rounded, 'View income, expenses & savings', AppRoutes.spendingSummary),
    _SearchAction('Merge Accounts', Icons.merge_rounded, 'Link bank accounts via Account Aggregator', AppRoutes.connectAccount),
    _SearchAction('Scan & Pay', Icons.qr_code_scanner_rounded, 'Scan QR code to pay', AppRoutes.scanQR),
    _SearchAction('Mobile Recharge', Icons.phone_android_rounded, 'Recharge prepaid mobile', AppRoutes.billsAndRecharges),
    _SearchAction('Electricity Bill', Icons.bolt_rounded, 'Pay electricity bill', AppRoutes.billsAndRecharges),
    _SearchAction('Credit Card Bill', Icons.credit_card_rounded, 'Pay credit card bill', AppRoutes.billsAndRecharges),
    _SearchAction('DTH Recharge', Icons.satellite_alt_rounded, 'Recharge DTH connection', AppRoutes.billsAndRecharges),
    _SearchAction('FASTag Recharge', Icons.directions_car_rounded, 'Recharge FASTag', AppRoutes.billsAndRecharges),
    _SearchAction('Balance & History', Icons.history_rounded, 'Check balance & transactions', AppRoutes.balanceHistory),
    _SearchAction('My QR Code', Icons.qr_code_rounded, 'Show your QR code', AppRoutes.myQR),
    _SearchAction('Financial Services', Icons.trending_up_rounded, 'Loans, Insurance, Stocks', AppRoutes.financialServices),
    _SearchAction('Messages', Icons.chat_bubble_outline_rounded, 'Payment conversations', AppRoutes.messages),
    _SearchAction('Settings', Icons.settings_rounded, 'App settings & preferences', AppRoutes.settings),
    _SearchAction('Get Loan', Icons.currency_rupee_rounded, 'Apply for personal loan', AppRoutes.financialServices),
    _SearchAction('Car Insurance', Icons.directions_car_rounded, 'Get car insurance', AppRoutes.financialServices),
    _SearchAction('Health Insurance', Icons.health_and_safety_rounded, 'Get health insurance', AppRoutes.financialServices),
    _SearchAction('Flight Booking', Icons.flight_rounded, 'Book flights', AppRoutes.home),
    _SearchAction('Train Booking', Icons.train_rounded, 'Book train tickets', AppRoutes.home),
    _SearchAction('Water Bill', Icons.water_drop_rounded, 'Pay water bill', AppRoutes.billsAndRecharges),
    _SearchAction('Gas Bill', Icons.local_fire_department_rounded, 'Pay piped gas bill', AppRoutes.billsAndRecharges),
    _SearchAction('Notifications', Icons.notifications_outlined, 'View notifications', AppRoutes.notifications),
  ];

  List<_SearchAction> get _filteredActions {
    if (_query.isEmpty) return _allActions.sublist(0, 8);
    final q = _query.toLowerCase();
    return _allActions.where((a) =>
      a.title.toLowerCase().contains(q) || a.subtitle.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PayGoSearchBar(
            placeholder: 'Search services, bills, contacts...',
            onChanged: (val) => setState(() => _query = val),
          ),

          if (_query.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
            ),

          Expanded(
            child: _filteredActions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64,
                          color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                        const SizedBox(height: 16),
                        Text('No results found', style: TextStyle(fontSize: 16,
                          color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredActions.length,
                    itemBuilder: (context, index) {
                      final action = _filteredActions[index];
                      return ListTile(
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: PayGoColors.oceanBlue.withValues(alpha: isDark ? 0.2 : 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(action.icon, size: 20, color: PayGoColors.oceanBlue),
                        ),
                        title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(action.subtitle, style: TextStyle(fontSize: 12,
                          color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 14,
                          color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                        onTap: () => context.push(action.route),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchAction {
  final String title;
  final IconData icon;
  final String subtitle;
  final String route;

  const _SearchAction(this.title, this.icon, this.subtitle, this.route);
}
