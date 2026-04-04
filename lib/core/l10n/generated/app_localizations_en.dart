// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sanad';

  @override
  String get home => 'Home';

  @override
  String get markets => 'Markets';

  @override
  String get trade => 'Trade';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get account => 'Account';

  @override
  String get murabaha => 'Murabaha';

  @override
  String get welcomeBack => 'Welcome back 👋';

  @override
  String get totalPortfolio => 'Total Portfolio';

  @override
  String get usStocks => 'US Stocks';

  @override
  String get saudiMarket => 'Saudi Market';

  @override
  String get cash => 'Cash';

  @override
  String get today => 'Today';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get orders => 'Orders';

  @override
  String get statement => 'Statement';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get viewAll => 'View All';

  @override
  String get shariaCompliant => 'Sharia Compliant';

  @override
  String get shariaCompliantChip => '☽ Compliant';

  @override
  String get investInMurabaha => 'Invest in Murabaha';

  @override
  String get returnsFrom => 'Returns from SAR 100 · 4.8% p.a.';

  @override
  String get annualReturn => 'p.a.';

  @override
  String get islamicInvestments => 'Murabaha Investments';

  @override
  String get islamicInvestmentsDesc =>
      'Invest in accordance with Islamic law and get fixed, pre-known returns without interest';

  @override
  String get choosePlan => 'Choose Investment Plan';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get investmentAmount => 'Investment Amount';

  @override
  String get expectedReturn => 'Expected Return';

  @override
  String get monthlyReturn => 'Monthly Return';

  @override
  String get annualReturnLabel => 'Annual Return';

  @override
  String get startInvesting => 'Start Investing';

  @override
  String get buy => 'Buy';

  @override
  String get sell => 'Sell';

  @override
  String get amountSar => 'Amount (SAR)';

  @override
  String get quantity => 'Quantity';

  @override
  String get orderType => 'Order Type';

  @override
  String get fees => 'Fees';

  @override
  String get settlement => 'Settlement';

  @override
  String get noCommission => 'No Commission ✓';

  @override
  String get confirmBuy => 'Confirm Buy';

  @override
  String get confirmSell => 'Confirm Sell';

  @override
  String get marketOrder => 'Market';

  @override
  String get myPortfolio => 'My Portfolio';

  @override
  String get totalValue => 'Total Value';

  @override
  String get totalProfits => 'Total Profits';

  @override
  String get assetAllocation => 'Asset Allocation';

  @override
  String get investments => 'Investments';

  @override
  String get sort => 'Sort ↕';

  @override
  String get hide => 'Hide';

  @override
  String get all => 'All';

  @override
  String get saudi => 'Saudi';

  @override
  String get american => 'US';

  @override
  String get sharia => '☽ Sharia';

  @override
  String get etf => 'ETF';

  @override
  String get mostTraded => 'Most Traded';

  @override
  String get topGainers => 'Top Gainers';

  @override
  String get search => 'Search stock or ETF...';

  @override
  String get preMarket => 'US Market Pre-Open';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get noData => 'No data available';

  @override
  String get shariaFilter => '☽ Sharia';

  @override
  String get annualRate => 'Expected annual yield';

  @override
  String get murabahaDisclaimer =>
      'Licensed Murabaha by CMA · 03-22247\nReturns mentioned are estimates and not a guarantee';

  @override
  String get islamicCompliantBadge => '☽ Compliant with Islamic Sharia';

  @override
  String get sarCurrency => 'SAR';

  @override
  String get usdCurrency => '\$';

  @override
  String get shares => 'shares';

  @override
  String get avgCost => 'Avg';

  @override
  String get totalReturn => 'Total Return';

  @override
  String get todayChange => 'Today\'s Change';

  @override
  String get back => 'Back';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get orderPlaced => 'Order placed successfully';

  @override
  String get technicalAnalysis => 'Technical Analysis';

  @override
  String shariaDetails(String debtRatio, String prohibitedRevenue) {
    return 'Debt ratio $debtRatio% · Prohibited revenue $prohibitedRevenue%';
  }

  @override
  String openAfter(String time) {
    return 'Opens in $time';
  }
}
