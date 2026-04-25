import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vital Streak!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your vital journey today.'**
  String get welcomeSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountText;

  /// No description provided for @signUpText.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpText;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Vital Streak and start monitoring your health.'**
  String get createAccountSubtitle;

  /// No description provided for @haveAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccountText;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @dashboardChallengeStarted.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE STARTED'**
  String get dashboardChallengeStarted;

  /// No description provided for @dashboardDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get dashboardDays;

  /// No description provided for @dashboardAvg.
  ///
  /// In en, this message translates to:
  /// **'AVG'**
  String get dashboardAvg;

  /// No description provided for @dashboardTrend.
  ///
  /// In en, this message translates to:
  /// **'LAST 30 DAYS TREND'**
  String get dashboardTrend;

  /// No description provided for @dashboardScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get dashboardScanNow;

  /// No description provided for @dashboardConstancy.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days Constancy'**
  String get dashboardConstancy;

  /// No description provided for @dashboardEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get dashboardEnterManually;

  /// No description provided for @manualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'MANUAL ENTRY'**
  String get manualEntryTitle;

  /// No description provided for @manualEntryRecord.
  ///
  /// In en, this message translates to:
  /// **'Record a measurement'**
  String get manualEntryRecord;

  /// No description provided for @manualEntryFillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details from your manual device.'**
  String get manualEntryFillDetails;

  /// No description provided for @manualEntryDate.
  ///
  /// In en, this message translates to:
  /// **'Measurement Date'**
  String get manualEntryDate;

  /// No description provided for @manualEntrySys.
  ///
  /// In en, this message translates to:
  /// **'SYSTOLIC'**
  String get manualEntrySys;

  /// No description provided for @manualEntryDia.
  ///
  /// In en, this message translates to:
  /// **'DIASTOLIC'**
  String get manualEntryDia;

  /// No description provided for @manualEntrySave.
  ///
  /// In en, this message translates to:
  /// **'Save Reading'**
  String get manualEntrySave;

  /// No description provided for @manualEntryErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid values for SYS and DIA.'**
  String get manualEntryErrorInvalid;

  /// No description provided for @manualEntryErrorSysDia.
  ///
  /// In en, this message translates to:
  /// **'Systolic pressure (SYS) must be greater than Diastolic (DIA).'**
  String get manualEntryErrorSysDia;

  /// No description provided for @dashboardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'RECENT ACTIVITY'**
  String get dashboardRecentActivity;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No records found.'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take your first reading to start your streak!'**
  String get dashboardEmptySubtitle;

  /// No description provided for @dashboardCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get dashboardCalculating;

  /// No description provided for @dashboardStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get dashboardStatus;

  /// No description provided for @dashboardAvgBP.
  ///
  /// In en, this message translates to:
  /// **'AVG BP'**
  String get dashboardAvgBP;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
