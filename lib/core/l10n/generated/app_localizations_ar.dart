// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سند';

  @override
  String get home => 'الرئيسية';

  @override
  String get markets => 'الأسواق';

  @override
  String get trade => 'تداول';

  @override
  String get portfolio => 'محفظتي';

  @override
  String get account => 'حسابي';

  @override
  String get murabaha => 'المرابحة';

  @override
  String get welcomeBack => 'مرحباً بعودتك 👋';

  @override
  String get totalPortfolio => 'إجمالي المحفظة';

  @override
  String get usStocks => 'أسهم أمريكية';

  @override
  String get saudiMarket => 'السوق السعودي';

  @override
  String get cash => 'نقدي';

  @override
  String get today => 'اليوم';

  @override
  String get deposit => 'إيداع';

  @override
  String get withdraw => 'سحب';

  @override
  String get orders => 'أوامر';

  @override
  String get statement => 'كشف';

  @override
  String get watchlist => 'قائمة المتابعة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get shariaCompliant => 'متوافق مع الشريعة';

  @override
  String get shariaCompliantChip => '☽ متوافق';

  @override
  String get investInMurabaha => 'استثمر في المرابحة';

  @override
  String get returnsFrom => 'عوائد من 100 ر.س · 4.8% سنوياً';

  @override
  String get annualReturn => 'سنوياً';

  @override
  String get islamicInvestments => 'استثمارات المرابحة';

  @override
  String get islamicInvestmentsDesc =>
      'استثمر بما يتوافق مع الشريعة الإسلامية واحصل على عوائد ثابتة ومعروفة مسبقاً بدون فوائد';

  @override
  String get choosePlan => 'اختر خطة الاستثمار';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get quarterly => 'ربع سنوي';

  @override
  String get investmentAmount => 'مبلغ الاستثمار';

  @override
  String get expectedReturn => 'العائد المتوقع';

  @override
  String get monthlyReturn => 'العائد الشهري';

  @override
  String get annualReturnLabel => 'العائد السنوي';

  @override
  String get startInvesting => 'ابدأ الاستثمار';

  @override
  String get buy => 'شراء';

  @override
  String get sell => 'بيع';

  @override
  String get amountSar => 'المبلغ (ر.س)';

  @override
  String get quantity => 'الكمية';

  @override
  String get orderType => 'نوع الأمر';

  @override
  String get fees => 'الرسوم';

  @override
  String get settlement => 'التسوية';

  @override
  String get noCommission => 'بدون عمولة ✓';

  @override
  String get confirmBuy => 'تأكيد الشراء';

  @override
  String get confirmSell => 'تأكيد البيع';

  @override
  String get marketOrder => 'سوق';

  @override
  String get myPortfolio => 'محفظتي';

  @override
  String get totalValue => 'القيمة الإجمالية';

  @override
  String get totalProfits => 'إجمالي الأرباح';

  @override
  String get assetAllocation => 'توزيع الأصول';

  @override
  String get investments => 'الاستثمارات';

  @override
  String get sort => 'ترتيب ↕';

  @override
  String get hide => 'إخفاء';

  @override
  String get all => 'الكل';

  @override
  String get saudi => 'السعودي';

  @override
  String get american => 'أمريكي';

  @override
  String get sharia => '☽ الشريعة';

  @override
  String get etf => 'ETF';

  @override
  String get mostTraded => 'الأكثر تداولاً';

  @override
  String get topGainers => 'الأكثر ارتفاعاً';

  @override
  String get search => 'ابحث عن سهم أو ETF...';

  @override
  String get preMarket => 'السوق الأمريكي قبل الافتتاح';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get error => 'حدث خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get shariaFilter => '☽ الشريعة';

  @override
  String get annualRate => 'عائد سنوي متوقع';

  @override
  String get murabahaDisclaimer =>
      'مرابحة مرخصة من هيئة سوق المالية · 03-22247\nالعوائد المذكورة تقديرية وليست ضماناً للعائد';

  @override
  String get islamicCompliantBadge => '☽ متوافق مع أحكام الشريعة الإسلامية';

  @override
  String get sarCurrency => 'ر.س';

  @override
  String get usdCurrency => '\$';

  @override
  String get shares => 'سهم';

  @override
  String get avgCost => 'متوسط';

  @override
  String get totalReturn => 'إجمالي العائد';

  @override
  String get todayChange => 'التغيير اليوم';

  @override
  String get back => 'رجوع';

  @override
  String get confirmOrder => 'تأكيد الأمر';

  @override
  String get orderPlaced => 'تم تقديم الأمر بنجاح';

  @override
  String get technicalAnalysis => 'التحليل الفني';

  @override
  String shariaDetails(String debtRatio, String prohibitedRevenue) {
    return 'نسبة الدين $debtRatio% · إيرادات محظورة $prohibitedRevenue%';
  }

  @override
  String openAfter(String time) {
    return 'يفتح بعد $time';
  }
}
