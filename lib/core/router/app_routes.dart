abstract class AppRoutes {
  // Main tabs
  static const String home = '/';
  static const String markets = '/markets';
  static const String portfolio = '/portfolio';
  static const String murabaha = '/murabaha';
  static const String profile = '/profile';

  // Trade (full-screen push)
  static const String trade = '/trade/:symbol';
  static String tradeRoute(String symbol) => '/trade/$symbol';

  // Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';

  // KYC
  static const String kycId = '/kyc/id';
  static const String kycSelfie = '/kyc/selfie';
  static const String kycBank = '/kyc/bank';
  static const String kycReview = '/kyc/review';
  static const String kycSubmitted = '/kyc/submitted';
  static const String kycApproved = '/kyc/approved';

  // Onboarding feature highlights
  static const String featureZeroCommission = '/onboarding/zero-commission';
  static const String featureShariah = '/onboarding/shariah';

  // Features
  static const String dca = '/dca';
  static const String priceAlerts = '/price-alerts';
  static const String orders = '/orders';
  static const String notifications = '/notifications';
  static const String statement = '/statement';
  static const String ipo = '/ipo';
  static const String funds = '/funds';
  static const String deposit = '/deposit';

  // Real-time market feed
  static const String marketFeed = '/market-feed';

  // ── Investments Shell (nested navigation) ─────
  static const String investments          = '/investments';
  static const String investmentsIpo       = '/investments/ipo';
  static const String investmentsMurabaha  = '/investments/murabaha';
  static const String investmentsFunds     = '/investments/funds';
  static const String investmentsStocks    = '/investments/stocks';

  // ── Post-trade / search ────────────────────────
  static const String orderReceipt = '/order-receipt';
  static const String stockSearch  = '/stock-search';
}
