import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

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
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Diary'**
  String get appTitle;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hypertension & Diabetes Journal'**
  String get appBarTitle;

  /// No description provided for @tabAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tabAdd;

  /// No description provided for @tabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get tabJournal;

  /// No description provided for @tabChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get tabChart;

  /// No description provided for @drawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Diary'**
  String get drawerTitle;

  /// No description provided for @drawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get drawerSubtitle;

  /// No description provided for @drawerReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get drawerReminders;

  /// No description provided for @drawerReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get drawerReports;

  /// No description provided for @drawerDev.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get drawerDev;

  /// No description provided for @menuGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get menuGenerateReport;

  /// No description provided for @menuReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get menuReportSubtitle;

  /// No description provided for @menuClearDb.
  ///
  /// In en, this message translates to:
  /// **'Clear Database'**
  String get menuClearDb;

  /// No description provided for @menuSeedDb.
  ///
  /// In en, this message translates to:
  /// **'Seed Database (1 year)'**
  String get menuSeedDb;

  /// No description provided for @menuSeedDbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Random values (DEBUG)'**
  String get menuSeedDbSubtitle;

  /// No description provided for @dialogConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get dialogConfirmTitle;

  /// No description provided for @dialogConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all records?'**
  String get dialogConfirmDelete;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

  /// No description provided for @btnReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get btnReset;

  /// No description provided for @periodMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get periodMorning;

  /// No description provided for @periodEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get periodEvening;

  /// No description provided for @fieldSystolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic pressure (SYS)'**
  String get fieldSystolic;

  /// No description provided for @fieldSystolicHint.
  ///
  /// In en, this message translates to:
  /// **'70-250'**
  String get fieldSystolicHint;

  /// No description provided for @fieldDiastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic pressure (DIA)'**
  String get fieldDiastolic;

  /// No description provided for @fieldDiastolicHint.
  ///
  /// In en, this message translates to:
  /// **'40-150'**
  String get fieldDiastolicHint;

  /// No description provided for @fieldPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get fieldPulse;

  /// No description provided for @fieldPulseHint.
  ///
  /// In en, this message translates to:
  /// **'30-200'**
  String get fieldPulseHint;

  /// No description provided for @fieldSugar.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar level'**
  String get fieldSugar;

  /// No description provided for @fieldSugarHint.
  ///
  /// In en, this message translates to:
  /// **'1.0-30.0'**
  String get fieldSugarHint;

  /// No description provided for @validRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validRequired;

  /// No description provided for @validNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Numbers only'**
  String get validNumbersOnly;

  /// No description provided for @validInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get validInvalidFormat;

  /// No description provided for @validSugarRange.
  ///
  /// In en, this message translates to:
  /// **'Sugar must be between 1.0 and 30.0'**
  String get validSugarRange;

  /// No description provided for @validRangeError.
  ///
  /// In en, this message translates to:
  /// **'{label} must be between {min} and {max}'**
  String validRangeError(String label, int min, int max);

  /// No description provided for @warningSeeDoctor.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Please consult a doctor!'**
  String get warningSeeDoctor;

  /// No description provided for @warningLessCarbs.
  ///
  /// In en, this message translates to:
  /// **'💡 Recommended to reduce carbohydrate intake.'**
  String get warningLessCarbs;

  /// No description provided for @snackSaved.
  ///
  /// In en, this message translates to:
  /// **'Data saved'**
  String get snackSaved;

  /// No description provided for @snackWarnDoctor.
  ///
  /// In en, this message translates to:
  /// **'\nWARNING: Please consult a doctor!'**
  String get snackWarnDoctor;

  /// No description provided for @snackWarnCarbs.
  ///
  /// In en, this message translates to:
  /// **'\nTip: Recommended to reduce carbohydrate intake.'**
  String get snackWarnCarbs;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Journal is empty'**
  String get journalEmpty;

  /// No description provided for @journalPulse.
  ///
  /// In en, this message translates to:
  /// **'pulse'**
  String get journalPulse;

  /// No description provided for @journalSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get journalSugar;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for charts'**
  String get chartNoData;

  /// No description provided for @chartPressureTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure Chart'**
  String get chartPressureTitle;

  /// No description provided for @chartSugarTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Chart'**
  String get chartSugarTitle;

  /// No description provided for @chartNoSugarData.
  ///
  /// In en, this message translates to:
  /// **'No blood sugar data'**
  String get chartNoSugarData;

  /// No description provided for @chartNoDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for selected period'**
  String get chartNoDataForPeriod;

  /// No description provided for @chart7d.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get chart7d;

  /// No description provided for @chart30d.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get chart30d;

  /// No description provided for @chartYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get chartYear;

  /// No description provided for @chartAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chartAll;

  /// No description provided for @chartSelectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get chartSelectPeriod;

  /// No description provided for @chartPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} - {end}'**
  String chartPeriodLabel(String start, String end);

  /// No description provided for @remindersLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get remindersLoading;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{morning} and {evening} (with repeats)'**
  String remindersSubtitle(String morning, String evening);

  /// No description provided for @remindersChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Change reminder time'**
  String get remindersChangeTime;

  /// No description provided for @remindersDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get remindersDialogTitle;

  /// No description provided for @notifMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Measurement'**
  String get notifMorningTitle;

  /// No description provided for @notifMorningBody.
  ///
  /// In en, this message translates to:
  /// **'Time to measure blood pressure and sugar'**
  String get notifMorningBody;

  /// No description provided for @notifEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening Measurement'**
  String get notifEveningTitle;

  /// No description provided for @notifEveningBody.
  ///
  /// In en, this message translates to:
  /// **'Time to measure blood pressure and sugar'**
  String get notifEveningBody;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Health Reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders to measure blood pressure and blood sugar'**
  String get notifChannelDesc;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Report (last 30 days)'**
  String get reportTitle;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} - {end}'**
  String reportPeriod(String start, String end);

  /// No description provided for @reportNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No records found for the selected period.'**
  String get reportNoRecords;

  /// No description provided for @reportErrorCreating.
  ///
  /// In en, this message translates to:
  /// **'Error creating report: {error}'**
  String reportErrorCreating(String error);

  /// No description provided for @reportColDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reportColDate;

  /// No description provided for @reportColTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reportColTime;

  /// No description provided for @reportColPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get reportColPeriod;

  /// No description provided for @reportColPressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure (SYS/DIA)'**
  String get reportColPressure;

  /// No description provided for @reportColPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get reportColPulse;

  /// No description provided for @reportColSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get reportColSugar;
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
