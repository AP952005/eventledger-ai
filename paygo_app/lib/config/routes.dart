/// PayGo — GoRouter navigation configuration
/// All app routes defined here with transitions.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/phone_entry_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/pin_setup_screen.dart';
import '../screens/home/home_dashboard.dart';
import '../screens/bills/bills_recharges.dart';
import '../screens/financial/financial_services.dart';
import '../screens/qr/my_qr_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/messages/chat_thread.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/upi_transfer/scan_and_pay.dart';
import '../screens/upi_transfer/to_mobile_contact.dart';
import '../screens/upi_transfer/to_bank_account.dart';
import '../screens/upi_transfer/confirm_payment.dart';
import '../screens/upi_transfer/balance_history.dart';
import '../screens/events/event_alias_setup.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/events/event_list_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/unmatched_payments_screen.dart';
import '../screens/events/send_reminders_screen.dart';
import '../screens/events/settlement_proof_screen.dart';
import '../screens/events/public_verify_screen.dart';
import '../screens/financial_hub/financial_hub_screen.dart';
import '../screens/financial_hub/connect_account_screen.dart';
import '../screens/financial_hub/consent_screen.dart';
import '../screens/financial_hub/mock_bank_approval_screen.dart';
import '../screens/financial_hub/account_list_screen.dart';
import '../screens/financial_hub/transaction_list_screen.dart';
import '../screens/financial_hub/spending_summary_screen.dart';
import '../screens/financial_hub/consent_management_screen.dart';
import '../screens/financial_hub/recurring_transactions_screen.dart';
import '../screens/ai_assistant/paygo_ai_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String phoneEntry = '/auth/phone';
  static const String otpVerification = '/auth/otp';
  static const String pinSetup = '/auth/pin-setup';
  static const String home = '/home';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String scanQR = '/scan-qr';
  static const String myQR = '/my-qr';
  static const String billsAndRecharges = '/bills';
  static const String financialServices = '/financial';
  static const String settings = '/settings';
  static const String messages = '/messages';
  static const String chatThread = '/messages/chat';
  static const String aiAssistant = '/ai-assistant';
  static const String scanAndPay = '/upi/scan-pay';
  static const String toMobileContact = '/upi/to-contact';
  static const String toBankAccount = '/upi/to-bank';
  static const String confirmPayment = '/upi/confirm';
  static const String balanceHistory = '/upi/balance-history';
  
  // Event Pay
  static const String eventAliasSetup = '/events/alias-setup';
  static const String createEvent = '/events/create';
  static const String eventList = '/events';
  static const String eventDetail = '/events/detail';
  static const String unmatchedPayments = '/events/unmatched';
  static const String sendReminders = '/events/reminders';
  static const String settlementProof = '/events/proof';
  static const String publicVerify = '/verify/:eventId';

  // Financial Hub
  static const String financialHub = '/financial-hub';
  static const String connectAccount = '/financial-hub/connect';
  static const String consentScreen = '/financial-hub/consent';
  static const String mockBankApproval = '/financial-hub/bank-approval';
  static const String accountList = '/financial-hub/accounts';
  static const String financialTransactions = '/financial-hub/transactions';
  static const String spendingSummary = '/financial-hub/spending';
  static const String consentManagement = '/financial-hub/consents';
  static const String recurringTransactions = '/financial-hub/recurring';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: phoneEntry,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const PhoneEntryScreen(),
        ),
      ),
      GoRoute(
        path: otpVerification,
        pageBuilder: (context, state) => _slideTransition(
          state,
          OTPVerificationScreen(
            phone: state.uri.queryParameters['phone'] ?? '',
            sessionId: state.uri.queryParameters['sessionId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: pinSetup,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const PinSetupScreen(),
        ),
      ),
      GoRoute(
        path: home,
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const HomeDashboard(),
        ),
      ),
      GoRoute(
        path: search,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const SearchScreen(),
        ),
      ),
      GoRoute(
        path: notifications,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: scanQR,
        pageBuilder: (context, state) => _slideUpTransition(
          state,
          const ScanAndPayScreen(),
        ),
      ),
      GoRoute(
        path: myQR,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const MyQRScreen(),
        ),
      ),
      GoRoute(
        path: billsAndRecharges,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const BillsRechargesScreen(),
        ),
      ),
      GoRoute(
        path: financialServices,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const FinancialServicesScreen(),
        ),
      ),
      GoRoute(
        path: settings,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: messages,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const MessagesScreen(),
        ),
      ),
      GoRoute(
        path: chatThread,
        pageBuilder: (context, state) => _slideTransition(
          state,
          ChatThreadScreen(
            contactId: state.uri.queryParameters['contactId'] ?? '',
            contactName: state.uri.queryParameters['name'] ?? 'Unknown',
          ),
        ),
      ),
      GoRoute(
        path: scanAndPay,
        pageBuilder: (context, state) => _slideUpTransition(
          state,
          const ScanAndPayScreen(),
        ),
      ),
      GoRoute(
        path: toMobileContact,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const ToMobileContactScreen(),
        ),
      ),
      GoRoute(
        path: toBankAccount,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const ToBankAccountScreen(),
        ),
      ),
      GoRoute(
        path: confirmPayment,
        pageBuilder: (context, state) => _slideTransition(
          state,
          ConfirmPaymentScreen(
            payeeName: state.uri.queryParameters['name'] ?? '',
            payeeUpiId: state.uri.queryParameters['upiId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: balanceHistory,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const BalanceHistoryScreen(),
        ),
      ),
      GoRoute(
        path: eventAliasSetup,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const EventAliasSetupScreen(),
        ),
      ),
      GoRoute(
        path: createEvent,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const CreateEventScreen(),
        ),
      ),
      GoRoute(
        path: eventList,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const EventListScreen(),
        ),
      ),
      GoRoute(
        path: eventDetail,
        pageBuilder: (context, state) => _slideTransition(
          state,
          EventDetailScreen(
            eventId: state.uri.queryParameters['eventId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: unmatchedPayments,
        pageBuilder: (context, state) => _slideTransition(
          state,
          UnmatchedPaymentsScreen(
            eventId: state.uri.queryParameters['eventId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: sendReminders,
        pageBuilder: (context, state) => _slideTransition(
          state,
          SendRemindersScreen(
            eventId: state.uri.queryParameters['eventId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: settlementProof,
        pageBuilder: (context, state) => _slideTransition(
          state,
          SettlementProofScreen(
            eventId: state.uri.queryParameters['eventId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: publicVerify,
        pageBuilder: (context, state) => _slideTransition(
          state,
          PublicVerifyScreen(
            eventId: state.pathParameters['eventId'] ?? '',
          ),
        ),
      ),

      // ── Financial Hub Routes ──
      GoRoute(
        path: financialHub,
        pageBuilder: (context, state) => _slideTransition(state, const FinancialHubScreen()),
      ),
      GoRoute(
        path: connectAccount,
        pageBuilder: (context, state) => _slideTransition(state, const ConnectAccountScreen()),
      ),
      GoRoute(
        path: consentScreen,
        pageBuilder: (context, state) => _slideTransition(state, const ConsentScreen()),
      ),
      GoRoute(
        path: mockBankApproval,
        pageBuilder: (context, state) => _slideTransition(state, const MockBankApprovalScreen()),
      ),
      GoRoute(
        path: accountList,
        pageBuilder: (context, state) => _slideTransition(state, const AccountListScreen()),
      ),
      GoRoute(
        path: financialTransactions,
        pageBuilder: (context, state) => _slideTransition(state, const TransactionListScreen()),
      ),
      GoRoute(
        path: spendingSummary,
        pageBuilder: (context, state) => _slideTransition(state, const SpendingSummaryScreen()),
      ),
      GoRoute(
        path: consentManagement,
        pageBuilder: (context, state) => _slideTransition(state, const ConsentManagementScreen()),
      ),
      GoRoute(
        path: recurringTransactions,
        pageBuilder: (context, state) => _slideTransition(state, const RecurringTransactionsScreen()),
      ),
      GoRoute(
        path: aiAssistant,
        pageBuilder: (context, state) => _slideUpTransition(state, const PayGoAIScreen()),
      ),
    ],
  );

  // ── Transition Helpers ──

  static CustomTransitionPage<void> _slideTransition(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static CustomTransitionPage<void> _fadeTransition(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static CustomTransitionPage<void> _slideUpTransition(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
