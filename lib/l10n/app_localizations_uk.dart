// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Щоденник здоров\'я';

  @override
  String get appBarTitle => 'Щоденник Гіпертоніка та Діабетика';

  @override
  String get tabAdd => 'Додати';

  @override
  String get tabJournal => 'Журнал';

  @override
  String get tabChart => 'Графік';

  @override
  String get drawerTitle => 'Щоденник здоров\'я';

  @override
  String get drawerSubtitle => 'Керування даними';

  @override
  String get drawerReminders => 'Налаштування нагадувань';

  @override
  String get drawerReports => 'Звітність';

  @override
  String get drawerDev => 'Розробка';

  @override
  String get menuGenerateReport => 'Сформувати звіт';

  @override
  String get menuReportSubtitle => 'За останні 30 днів';

  @override
  String get menuClearDb => 'Очистити базу';

  @override
  String get menuSeedDb => 'Заповнити базу (1 рік)';

  @override
  String get menuSeedDbSubtitle => 'Довільні значення (DEBUG)';

  @override
  String get dialogConfirmTitle => 'Підтвердження';

  @override
  String get dialogConfirmDelete =>
      'Ви впевнені, що хочете видалити всі записи?';

  @override
  String get btnCancel => 'Скасувати';

  @override
  String get btnDelete => 'Видалити';

  @override
  String get btnSave => 'Зберегти';

  @override
  String get btnDone => 'Готово';

  @override
  String get btnReset => 'Скинути';

  @override
  String get periodMorning => 'Ранок';

  @override
  String get periodEvening => 'Вечір';

  @override
  String get fieldSystolic => 'Верхній тиск (SYS)';

  @override
  String get fieldSystolicHint => '70-250';

  @override
  String get fieldDiastolic => 'Нижній тиск (DIA)';

  @override
  String get fieldDiastolicHint => '40-150';

  @override
  String get fieldPulse => 'Пульс';

  @override
  String get fieldPulseHint => '30-200';

  @override
  String get fieldSugar => 'Рівень цукру';

  @override
  String get fieldSugarHint => '1.0-30.0';

  @override
  String get validRequired => 'Обов\'язково';

  @override
  String get validNumbersOnly => 'Тільки цифри';

  @override
  String get validInvalidFormat => 'Некоректний формат';

  @override
  String get validSugarRange => 'Цукор має бути від 1.0 до 30.0';

  @override
  String validRangeError(String label, int min, int max) {
    return '$label має бути від $min до $max';
  }

  @override
  String get warningSeeDoctor => '⚠️ Необхідно звернутись до лікаря!';

  @override
  String get warningLessCarbs => '💡 Рекомендовано вживати менше вуглеводів.';

  @override
  String get snackSaved => 'Дані збережено';

  @override
  String get snackWarnDoctor => '\nУВАГА: Необхідно звернутись до лікаря!';

  @override
  String get snackWarnCarbs =>
      '\nПорада: Рекомендовано вживати менше вуглеводів.';

  @override
  String get journalEmpty => 'Журнал порожній';

  @override
  String get journalPulse => 'пульс';

  @override
  String get journalSugar => 'Цукор';

  @override
  String get chartNoData => 'Немає даних для графіків';

  @override
  String get chartPressureTitle => 'Графік тиску';

  @override
  String get chartSugarTitle => 'Графік цукру';

  @override
  String get chartNoSugarData => 'Немає даних про цукор';

  @override
  String get chartNoDataForPeriod => 'За вибраний період даних немає';

  @override
  String get chart7d => '7д';

  @override
  String get chart30d => '30д';

  @override
  String get chartYear => 'Рік';

  @override
  String get chartAll => 'Все';

  @override
  String get chartSelectPeriod => 'Вибрати період';

  @override
  String chartPeriodLabel(String start, String end) {
    return 'Період: $start - $end';
  }

  @override
  String get remindersLoading => 'Завантаження налаштувань...';

  @override
  String get remindersTitle => 'Нагадування';

  @override
  String remindersSubtitle(String morning, String evening) {
    return '$morning та $evening (з повторами)';
  }

  @override
  String get remindersChangeTime => 'Змінити час нагадувань';

  @override
  String get remindersDialogTitle => 'Час нагадувань';

  @override
  String get notifMorningTitle => 'Ранкове вимірювання';

  @override
  String get notifMorningBody => 'Пора поміряти тиск та цукор';

  @override
  String get notifEveningTitle => 'Вечірнє вимірювання';

  @override
  String get notifEveningBody => 'Пора поміряти тиск та цукор';

  @override
  String get notifChannelName => 'Нагадування про здоров\'я';

  @override
  String get notifChannelDesc => 'Нагадування про вимірювання тиску та цукру';

  @override
  String get reportTitle => 'Звіт про стан здоров\'я (останні 30 днів)';

  @override
  String reportPeriod(String start, String end) {
    return 'Період: $start - $end';
  }

  @override
  String get reportNoRecords => 'Записів за вказаний період не знайдено.';

  @override
  String reportErrorCreating(String error) {
    return 'Помилка при створенні звіту: $error';
  }

  @override
  String get reportColDate => 'Дата';

  @override
  String get reportColTime => 'Час';

  @override
  String get reportColPeriod => 'Період';

  @override
  String get reportColPressure => 'Тиск (SYS/DIA)';

  @override
  String get reportColPulse => 'Пульс';

  @override
  String get reportColSugar => 'Цукор';
}
