/// EventTreasury AI — GoRouter navigation configuration
/// Enterprise routes for EventTreasury AI — Powered by PayPal

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_dashboard.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/events/event_list_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/public_event_registration_screen.dart';
import '../screens/events/send_reminders_screen.dart';
import '../screens/ai_assistant/paygo_ai_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/financial_hub/spending_summary_screen.dart';
import '../screens/financial_hub/financial_hub_screen.dart';
import '../screens/financial_hub/account_list_screen.dart';
import '../screens/financial_hub/connect_account_screen.dart';
import '../screens/financial_hub/consent_management_screen.dart';
import '../screens/financial_hub/consent_screen.dart';
import '../screens/financial_hub/mock_bank_approval_screen.dart';
import '../screens/financial_hub/transaction_list_screen.dart';
import '../screens/financial_hub/recurring_transactions_screen.dart';
import '../screens/checkout/unified_checkout_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String homeAlias = '/home';
  static const String login = '/login';
  static const String eventList = '/events';
  static const String createEvent = '/events/create';
  static const String eventDetail = '/events/detail';
  static const String publicRegistration = '/events/register/:eventId';
  static const String unifiedCheckout = '/checkout/:orderId';
  static const String sendReminders = '/events/reminders';
  static const String aiAssistant = '/ai-assistant';
  static const String financialHub = '/financial-hub';
  static const String accountList = '/financial-hub/accounts';
  static const String connectAccount = '/financial-hub/connect';
  static const String consentManagement = '/financial-hub/consents';
  static const String consentScreen = '/financial-hub/consent';
  static const String mockBankApproval = '/financial-hub/mock-approval';
  static const String financialTransactions = '/financial-hub/transactions';
  static const String recurringTransactions = '/financial-hub/recurring';
  static const String spendingSummary = '/analytics';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const EventTreasuryDashboard(),
      ),
      GoRoute(
        path: homeAlias,
        builder: (context, state) => const EventTreasuryDashboard(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: eventList,
        builder: (context, state) => const EventTreasuryListScreen(),
      ),
      GoRoute(
        path: createEvent,
        builder: (context, state) => const CreateEventTreasuryScreen(),
      ),
      GoRoute(
        path: eventDetail,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'evt-paypal-001';
          return EventDetailTreasuryScreen(eventId: id);
        },
      ),
      GoRoute(
        path: publicRegistration,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? 'evt-paypal-001';
          return PublicEventRegistrationScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: unifiedCheckout,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? 'ord-latest';
          return UnifiedCheckoutScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: sendReminders,
        builder: (context, state) {
          final eventId = state.uri.queryParameters['id'];
          return SendRemindersTreasuryScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: aiAssistant,
        builder: (context, state) => const EventTreasuryAIAssistantScreen(),
      ),
      GoRoute(
        path: financialHub,
        builder: (context, state) => const FinancialHubScreen(),
      ),
      GoRoute(
        path: accountList,
        builder: (context, state) => const AccountListScreen(),
      ),
      GoRoute(
        path: connectAccount,
        builder: (context, state) => const ConnectAccountScreen(),
      ),
      GoRoute(
        path: consentManagement,
        builder: (context, state) => const ConsentManagementScreen(),
      ),
      GoRoute(
        path: consentScreen,
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        path: mockBankApproval,
        builder: (context, state) => const MockBankApprovalScreen(),
      ),
      GoRoute(
        path: financialTransactions,
        builder: (context, state) => const TransactionListScreen(),
      ),
      GoRoute(
        path: recurringTransactions,
        builder: (context, state) => const RecurringTransactionsScreen(),
      ),
      GoRoute(
        path: spendingSummary,
        builder: (context, state) => const SpendingSummaryScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
