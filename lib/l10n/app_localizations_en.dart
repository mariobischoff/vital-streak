// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to Vital Streak!';

  @override
  String get welcomeSubtitle => 'Start your vital journey today.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get noAccountText => 'Don\'t have an account? ';

  @override
  String get signUpText => 'Sign Up';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get createAccountSubtitle =>
      'Join Vital Streak and start monitoring your health.';

  @override
  String get haveAccountText => 'Already have an account? ';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get dashboardChallengeStarted => 'CHALLENGE STARTED';

  @override
  String get dashboardDays => 'Days';

  @override
  String get dashboardAvg => 'AVG';

  @override
  String get dashboardTrend => 'LAST 30 DAYS TREND';

  @override
  String get dashboardScanNow => 'Scan Now';

  @override
  String get dashboardConstancy => 'Last 30 Days Constancy';

  @override
  String get dashboardEnterManually => 'Enter Manually';

  @override
  String get manualEntryTitle => 'MANUAL ENTRY';

  @override
  String get manualEntryRecord => 'Record a measurement';

  @override
  String get manualEntryFillDetails =>
      'Fill in the details from your manual device.';

  @override
  String get manualEntryDate => 'Measurement Date';

  @override
  String get manualEntrySys => 'SYSTOLIC';

  @override
  String get manualEntryDia => 'DIASTOLIC';

  @override
  String get manualEntrySave => 'Save Reading';

  @override
  String get manualEntryErrorInvalid =>
      'Please enter valid values for SYS and DIA.';

  @override
  String get manualEntryErrorSysDia =>
      'Systolic pressure (SYS) must be greater than Diastolic (DIA).';

  @override
  String get dashboardRecentActivity => 'RECENT ACTIVITY';

  @override
  String get dashboardEmptyTitle => 'No records found.';

  @override
  String get dashboardEmptySubtitle =>
      'Take your first reading to start your streak!';

  @override
  String get dashboardCalculating => 'Calculating...';

  @override
  String get dashboardStatus => 'STATUS';

  @override
  String get dashboardAvgBP => 'AVG BP';
}
