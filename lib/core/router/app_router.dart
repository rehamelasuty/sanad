import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/feature_shariah_screen.dart';
import '../../features/market_feed/presentation/cubit/market_feed_cubit.dart';
import '../../features/market_feed/presentation/screens/market_feed_screen.dart';
import '../../features/dca/presentation/cubit/dca_cubit.dart';
import '../../features/dca/presentation/screens/dca_screen.dart';
import '../../features/price_alerts/presentation/cubit/price_alerts_cubit.dart';
import '../../features/price_alerts/presentation/screens/price_alerts_screen.dart';
import '../../features/auth/presentation/screens/feature_zero_commission_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/funds/presentation/cubit/funds_cubit.dart';
import '../../features/funds/presentation/screens/funds_screen.dart';
import '../../features/investments/presentation/screens/investments_funds_screen.dart';
import '../../features/investments/presentation/screens/investments_holdings_screen.dart';
import '../../features/investments/presentation/screens/investments_ipo_screen.dart';
import '../../features/investments/presentation/screens/investments_murabaha_screen.dart';
import '../../features/investments/presentation/screens/investments_stocks_screen.dart';
import '../../features/investments/presentation/shell/investments_shell.dart';
import '../../features/ipo/presentation/cubit/ipo_cubit.dart';
import '../../features/ipo/presentation/screens/ipo_screen.dart';
import '../../features/kyc/presentation/screens/kyc_approved_screen.dart';
import '../../features/kyc/presentation/screens/kyc_bank_link_screen.dart';
import '../../features/kyc/presentation/screens/kyc_id_upload_screen.dart';
import '../../features/kyc/presentation/screens/kyc_review_screen.dart';
import '../../features/kyc/presentation/screens/kyc_selfie_screen.dart';
import '../../features/kyc/presentation/screens/kyc_submitted_screen.dart';

import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';

import '../../features/statement/presentation/cubit/statement_cubit.dart';
import '../../features/statement/presentation/screens/statement_screen.dart';
import '../../features/trade/presentation/screens/trade_screen.dart';
import '../../features/trade/presentation/screens/order_receipt_screen.dart';
import '../../features/trade/domain/entities/order.dart';
import '../../features/trade/presentation/cubit/trade_cubit.dart';
import '../../features/investments/presentation/screens/stock_search_screen.dart';
import '../../features/wallet/presentation/screens/deposit_screen.dart';
import '../di/injection.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // ── Investments shell branch keys ──────────────────────────
  static final _invHoldingsKey =
      GlobalKey<NavigatorState>(debugLabel: 'inv_holdings');
  static final _invIpoKey =
      GlobalKey<NavigatorState>(debugLabel: 'inv_ipo');
  static final _invMurabahaKey =
      GlobalKey<NavigatorState>(debugLabel: 'inv_murabaha');
  static final _invFundsKey =
      GlobalKey<NavigatorState>(debugLabel: 'inv_funds');
  static final _invStocksKey =
      GlobalKey<NavigatorState>(debugLabel: 'inv_stocks');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.investments,
    routes: [
      // ── Investments Shell (StatefulShellRoute – 5 tabs) ───
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            InvestmentsShell(navigationShell: navigationShell),
        branches: [
          // 0 · المحفظة (holdings overview)
          StatefulShellBranch(
            navigatorKey: _invHoldingsKey,
            routes: [
              GoRoute(
                path: AppRoutes.investments,
                pageBuilder: (context, state) => _noTransition(
                  state,
                  const InvestmentsHoldingsScreen(),
                ),
              ),
            ],
          ),

          // 1 · الاكتتابات (IPO subscriptions)
          StatefulShellBranch(
            navigatorKey: _invIpoKey,
            routes: [
              GoRoute(
                path: AppRoutes.investmentsIpo,
                pageBuilder: (context, state) => _noTransition(
                  state,
                  const InvestmentsIpoScreen(),
                ),
              ),
            ],
          ),

          // 2 · المرابحات (Murabaha plans)
          StatefulShellBranch(
            navigatorKey: _invMurabahaKey,
            routes: [
              GoRoute(
                path: AppRoutes.investmentsMurabaha,
                pageBuilder: (context, state) => _noTransition(
                  state,
                  const InvestmentsMurabahaScreen(),
                ),
              ),
            ],
          ),

          // 3 · الصناديق (Funds)
          StatefulShellBranch(
            navigatorKey: _invFundsKey,
            routes: [
              GoRoute(
                path: AppRoutes.investmentsFunds,
                pageBuilder: (context, state) => _noTransition(
                  state,
                  const InvestmentsFundsScreen(),
                ),
              ),
            ],
          ),

          // 4 · الأسهم (Stocks browser)
          StatefulShellBranch(
            navigatorKey: _invStocksKey,
            routes: [
              GoRoute(
                path: AppRoutes.investmentsStocks,
                pageBuilder: (context, state) => _noTransition(
                  state,
                  const InvestmentsStocksScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen push routes ────────────────────────────
      GoRoute(
        path: AppRoutes.trade,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<TradeCubit>()..loadStock(
              state.pathParameters['symbol']!),
          child: TradeScreen(
            symbol: state.pathParameters['symbol']!,
          ),
        ),
      ),

      // Order receipt (shown after trade execution)
      GoRoute(
        path: AppRoutes.orderReceipt,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OrderReceiptScreen(
            order: extra['order'] as Order,
            stockName: extra['stockName'] as String,
          );
        },
      ),

      // Stock search screen
      GoRoute(
        path: AppRoutes.stockSearch,
        builder: (_, __) => const StockSearchScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, __) => const OtpScreen(),
      ),

      // KYC
      GoRoute(
        path: AppRoutes.kycId,
        builder: (_, __) => const KycIdUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.kycSelfie,
        builder: (_, __) => const KycSelfieScreen(),
      ),
      GoRoute(
        path: AppRoutes.kycBank,
        builder: (_, __) => const KycBankLinkScreen(),
      ),
      GoRoute(
        path: AppRoutes.kycReview,
        builder: (_, __) => const KycReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.kycSubmitted,
        builder: (_, __) => const KycSubmittedScreen(),
      ),
      GoRoute(
        path: AppRoutes.kycApproved,
        builder: (_, __) => const KycApprovedScreen(),
      ),

      // Feature screens with BLoC providers
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<OrdersCubit>()..loadOrders(),
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<NotificationsCubit>()..loadNotifications(),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.statement,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<StatementCubit>()..loadTransactions(),
          child: const StatementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ipo,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<IpoCubit>()..loadListings(),
          child: const IpoScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.funds,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<FundsCubit>()..loadFunds(),
          child: const FundsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.deposit,
        builder: (_, __) => const DepositScreen(),
      ),

      // DCA
      GoRoute(
        path: AppRoutes.dca,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DcaCubit>()..loadPlans(),
          child: const DcaScreen(),
        ),
      ),

      // Price Alerts
      GoRoute(
        path: AppRoutes.priceAlerts,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<PriceAlertsCubit>()..loadAlerts(),
          child: const PriceAlertsScreen(),
        ),
      ),

      // Real-time market feed
      GoRoute(
        path: AppRoutes.marketFeed,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<MarketFeedCubit>(),
          child: const MarketFeedScreen(),
        ),
      ),

      // Onboarding feature highlights
      GoRoute(
        path: AppRoutes.featureZeroCommission,
        builder: (_, __) => const FeatureZeroCommissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.featureShariah,
        builder: (_, __) => const FeatureShariahScreen(),
      ),
    ],
  );

  static CustomTransitionPage<void> _noTransition(
    GoRouterState state,
    Widget child,
  ) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, c) => c,
      );
}
