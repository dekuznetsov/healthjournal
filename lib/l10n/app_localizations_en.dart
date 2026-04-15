// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Health Diary';

  @override
  String get appBarTitle => 'Hypertension & Diabetes Journal';

  @override
  String get tabAdd => 'Add';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabChart => 'Chart';

  @override
  String get drawerTitle => 'Health Diary';

  @override
  String get drawerSubtitle => 'Data Management';

  @override
  String get drawerReminders => 'Reminder Settings';

  @override
  String get drawerReports => 'Reports';

  @override
  String get drawerDev => 'Development';

  @override
  String get menuGenerateReport => 'Generate Report';

  @override
  String get menuReportSubtitle => 'Last 30 days';

  @override
  String get menuClearDb => 'Clear Database';

  @override
  String get menuSeedDb => 'Seed Database (1 year)';

  @override
  String get menuSeedDbSubtitle => 'Random values (DEBUG)';

  @override
  String get dialogConfirmTitle => 'Confirmation';

  @override
  String get dialogConfirmDelete =>
      'Are you sure you want to delete all records?';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnSave => 'Save';

  @override
  String get btnDone => 'Done';

  @override
  String get btnReset => 'Reset';

  @override
  String get periodMorning => 'Morning';

  @override
  String get periodEvening => 'Evening';

  @override
  String get fieldSystolic => 'Systolic pressure (SYS)';

  @override
  String get fieldSystolicHint => '70-250';

  @override
  String get fieldDiastolic => 'Diastolic pressure (DIA)';

  @override
  String get fieldDiastolicHint => '40-150';

  @override
  String get fieldPulse => 'Pulse';

  @override
  String get fieldPulseHint => '30-200';

  @override
  String get fieldSugar => 'Blood sugar level';

  @override
  String get fieldSugarHint => '1.0-30.0';

  @override
  String get validRequired => 'Required';

  @override
  String get validNumbersOnly => 'Numbers only';

  @override
  String get validInvalidFormat => 'Invalid format';

  @override
  String get validSugarRange => 'Sugar must be between 1.0 and 30.0';

  @override
  String validRangeError(String label, int min, int max) {
    return '$label must be between $min and $max';
  }

  @override
  String get warningSeeDoctor => '⚠️ Please consult a doctor!';

  @override
  String get warningLessCarbs =>
      '💡 Recommended to reduce carbohydrate intake.';

  @override
  String get snackSaved => 'Data saved';

  @override
  String get snackWarnDoctor => '\nWARNING: Please consult a doctor!';

  @override
  String get snackWarnCarbs =>
      '\nTip: Recommended to reduce carbohydrate intake.';

  @override
  String get journalEmpty => 'Journal is empty';

  @override
  String get journalPulse => 'pulse';

  @override
  String get journalSugar => 'Sugar';

  @override
  String get chartNoData => 'No data for charts';

  @override
  String get chartPressureTitle => 'Blood Pressure Chart';

  @override
  String get chartSugarTitle => 'Blood Sugar Chart';

  @override
  String get chartNoSugarData => 'No blood sugar data';

  @override
  String get chartNoDataForPeriod => 'No data for selected period';

  @override
  String get chart7d => '7d';

  @override
  String get chart30d => '30d';

  @override
  String get chartYear => 'Year';

  @override
  String get chartAll => 'All';

  @override
  String get chartSelectPeriod => 'Select period';

  @override
  String chartPeriodLabel(String start, String end) {
    return 'Period: $start - $end';
  }

  @override
  String get remindersLoading => 'Loading settings...';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String remindersSubtitle(String morning, String evening) {
    return '$morning and $evening (with repeats)';
  }

  @override
  String get remindersChangeTime => 'Change reminder time';

  @override
  String get remindersDialogTitle => 'Reminder Time';

  @override
  String get notifMorningTitle => 'Morning Measurement';

  @override
  String get notifMorningBody => 'Time to measure blood pressure and sugar';

  @override
  String get notifEveningTitle => 'Evening Measurement';

  @override
  String get notifEveningBody => 'Time to measure blood pressure and sugar';

  @override
  String get notifChannelName => 'Health Reminders';

  @override
  String get notifChannelDesc =>
      'Reminders to measure blood pressure and blood sugar';

  @override
  String get reportTitle => 'Health Report (last 30 days)';

  @override
  String reportPeriod(String start, String end) {
    return 'Period: $start - $end';
  }

  @override
  String get reportNoRecords => 'No records found for the selected period.';

  @override
  String reportErrorCreating(String error) {
    return 'Error creating report: $error';
  }

  @override
  String get reportColDate => 'Date';

  @override
  String get reportColTime => 'Time';

  @override
  String get reportColPeriod => 'Period';

  @override
  String get reportColPressure => 'Pressure (SYS/DIA)';

  @override
  String get reportColPulse => 'Pulse';

  @override
  String get reportColSugar => 'Sugar';
}
