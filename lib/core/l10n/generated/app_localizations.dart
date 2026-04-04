import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'سند'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @markets.
  ///
  /// In ar, this message translates to:
  /// **'الأسواق'**
  String get markets;

  /// No description provided for @trade.
  ///
  /// In ar, this message translates to:
  /// **'تداول'**
  String get trade;

  /// No description provided for @portfolio.
  ///
  /// In ar, this message translates to:
  /// **'محفظتي'**
  String get portfolio;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get account;

  /// No description provided for @murabaha.
  ///
  /// In ar, this message translates to:
  /// **'المرابحة'**
  String get murabaha;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك 👋'**
  String get welcomeBack;

  /// No description provided for @totalPortfolio.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المحفظة'**
  String get totalPortfolio;

  /// No description provided for @usStocks.
  ///
  /// In ar, this message translates to:
  /// **'أسهم أمريكية'**
  String get usStocks;

  /// No description provided for @saudiMarket.
  ///
  /// In ar, this message translates to:
  /// **'السوق السعودي'**
  String get saudiMarket;

  /// No description provided for @cash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get cash;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @deposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In ar, this message translates to:
  /// **'سحب'**
  String get withdraw;

  /// No description provided for @orders.
  ///
  /// In ar, this message translates to:
  /// **'أوامر'**
  String get orders;

  /// No description provided for @statement.
  ///
  /// In ar, this message translates to:
  /// **'كشف'**
  String get statement;

  /// No description provided for @watchlist.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المتابعة'**
  String get watchlist;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @shariaCompliant.
  ///
  /// In ar, this message translates to:
  /// **'متوافق مع الشريعة'**
  String get shariaCompliant;

  /// No description provided for @shariaCompliantChip.
  ///
  /// In ar, this message translates to:
  /// **'☽ متوافق'**
  String get shariaCompliantChip;

  /// No description provided for @investInMurabaha.
  ///
  /// In ar, this message translates to:
  /// **'استثمر في المرابحة'**
  String get investInMurabaha;

  /// No description provided for @returnsFrom.
  ///
  /// In ar, this message translates to:
  /// **'عوائد من 100 ر.س · 4.8% سنوياً'**
  String get returnsFrom;

  /// No description provided for @annualReturn.
  ///
  /// In ar, this message translates to:
  /// **'سنوياً'**
  String get annualReturn;

  /// No description provided for @islamicInvestments.
  ///
  /// In ar, this message translates to:
  /// **'استثمارات المرابحة'**
  String get islamicInvestments;

  /// No description provided for @islamicInvestmentsDesc.
  ///
  /// In ar, this message translates to:
  /// **'استثمر بما يتوافق مع الشريعة الإسلامية واحصل على عوائد ثابتة ومعروفة مسبقاً بدون فوائد'**
  String get islamicInvestmentsDesc;

  /// No description provided for @choosePlan.
  ///
  /// In ar, this message translates to:
  /// **'اختر خطة الاستثمار'**
  String get choosePlan;

  /// No description provided for @weekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get monthly;

  /// No description provided for @quarterly.
  ///
  /// In ar, this message translates to:
  /// **'ربع سنوي'**
  String get quarterly;

  /// No description provided for @investmentAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الاستثمار'**
  String get investmentAmount;

  /// No description provided for @expectedReturn.
  ///
  /// In ar, this message translates to:
  /// **'العائد المتوقع'**
  String get expectedReturn;

  /// No description provided for @monthlyReturn.
  ///
  /// In ar, this message translates to:
  /// **'العائد الشهري'**
  String get monthlyReturn;

  /// No description provided for @annualReturnLabel.
  ///
  /// In ar, this message translates to:
  /// **'العائد السنوي'**
  String get annualReturnLabel;

  /// No description provided for @startInvesting.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الاستثمار'**
  String get startInvesting;

  /// No description provided for @buy.
  ///
  /// In ar, this message translates to:
  /// **'شراء'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get sell;

  /// No description provided for @amountSar.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ (ر.س)'**
  String get amountSar;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @orderType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الأمر'**
  String get orderType;

  /// No description provided for @fees.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم'**
  String get fees;

  /// No description provided for @settlement.
  ///
  /// In ar, this message translates to:
  /// **'التسوية'**
  String get settlement;

  /// No description provided for @noCommission.
  ///
  /// In ar, this message translates to:
  /// **'بدون عمولة ✓'**
  String get noCommission;

  /// No description provided for @confirmBuy.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الشراء'**
  String get confirmBuy;

  /// No description provided for @confirmSell.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد البيع'**
  String get confirmSell;

  /// No description provided for @marketOrder.
  ///
  /// In ar, this message translates to:
  /// **'سوق'**
  String get marketOrder;

  /// No description provided for @myPortfolio.
  ///
  /// In ar, this message translates to:
  /// **'محفظتي'**
  String get myPortfolio;

  /// No description provided for @totalValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الإجمالية'**
  String get totalValue;

  /// No description provided for @totalProfits.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح'**
  String get totalProfits;

  /// No description provided for @assetAllocation.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الأصول'**
  String get assetAllocation;

  /// No description provided for @investments.
  ///
  /// In ar, this message translates to:
  /// **'الاستثمارات'**
  String get investments;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب ↕'**
  String get sort;

  /// No description provided for @hide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get hide;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @saudi.
  ///
  /// In ar, this message translates to:
  /// **'السعودي'**
  String get saudi;

  /// No description provided for @american.
  ///
  /// In ar, this message translates to:
  /// **'أمريكي'**
  String get american;

  /// No description provided for @sharia.
  ///
  /// In ar, this message translates to:
  /// **'☽ الشريعة'**
  String get sharia;

  /// No description provided for @etf.
  ///
  /// In ar, this message translates to:
  /// **'ETF'**
  String get etf;

  /// No description provided for @mostTraded.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر تداولاً'**
  String get mostTraded;

  /// No description provided for @topGainers.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر ارتفاعاً'**
  String get topGainers;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سهم أو ETF...'**
  String get search;

  /// No description provided for @preMarket.
  ///
  /// In ar, this message translates to:
  /// **'السوق الأمريكي قبل الافتتاح'**
  String get preMarket;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @shariaFilter.
  ///
  /// In ar, this message translates to:
  /// **'☽ الشريعة'**
  String get shariaFilter;

  /// No description provided for @annualRate.
  ///
  /// In ar, this message translates to:
  /// **'عائد سنوي متوقع'**
  String get annualRate;

  /// No description provided for @murabahaDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'مرابحة مرخصة من هيئة سوق المالية · 03-22247\nالعوائد المذكورة تقديرية وليست ضماناً للعائد'**
  String get murabahaDisclaimer;

  /// No description provided for @islamicCompliantBadge.
  ///
  /// In ar, this message translates to:
  /// **'☽ متوافق مع أحكام الشريعة الإسلامية'**
  String get islamicCompliantBadge;

  /// No description provided for @sarCurrency.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get sarCurrency;

  /// No description provided for @usdCurrency.
  ///
  /// In ar, this message translates to:
  /// **'\$'**
  String get usdCurrency;

  /// No description provided for @shares.
  ///
  /// In ar, this message translates to:
  /// **'سهم'**
  String get shares;

  /// No description provided for @avgCost.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get avgCost;

  /// No description provided for @totalReturn.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العائد'**
  String get totalReturn;

  /// No description provided for @todayChange.
  ///
  /// In ar, this message translates to:
  /// **'التغيير اليوم'**
  String get todayChange;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @confirmOrder.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الأمر'**
  String get confirmOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم الأمر بنجاح'**
  String get orderPlaced;

  /// No description provided for @technicalAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'التحليل الفني'**
  String get technicalAnalysis;

  /// No description provided for @shariaDetails.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الدين {debtRatio}% · إيرادات محظورة {prohibitedRevenue}%'**
  String shariaDetails(String debtRatio, String prohibitedRevenue);

  /// No description provided for @openAfter.
  ///
  /// In ar, this message translates to:
  /// **'يفتح بعد {time}'**
  String openAfter(String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
