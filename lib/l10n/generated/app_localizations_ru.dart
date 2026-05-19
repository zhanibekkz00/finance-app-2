// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Финансы';

  @override
  String get dashboard => 'Главная';

  @override
  String get transactions => 'Транзакции';

  @override
  String get settings => 'Настройки';

  @override
  String get darkMode => 'Темная тема';

  @override
  String get language => 'Язык';

  @override
  String get exportData => 'Экспорт данных';

  @override
  String get scheduleReminder => 'Напоминание';

  @override
  String get exportSuccess => 'Экспорт выполнен';

  @override
  String get reminderSet => 'Напоминание установлено на 9:00';

  @override
  String get totalBalance => 'Общий баланс';

  @override
  String get income => 'Доходы';

  @override
  String get expense => 'Расходы';

  @override
  String get addTransaction => 'Добавить операцию';

  @override
  String get category => 'Категория';

  @override
  String get amount => 'Сумма';

  @override
  String get note => 'Заметка';

  @override
  String get date => 'Дата';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get login => 'Вход';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get recurring => 'Повторяющийся?';

  @override
  String get search => 'Поиск...';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get share => 'Поделиться';

  @override
  String get changeCategory => 'Изменить категорию';

  @override
  String get pin => 'Закрепить';

  @override
  String get unpin => 'Открепить';

  @override
  String get viewCategoryStats => 'Статистика категории';

  @override
  String get deleteConfirmTitle => 'Удалить транзакцию?';

  @override
  String get deleteConfirmMessage =>
      'Вы уверены, что хотите удалить эту транзакцию?';

  @override
  String get transactionDeleted => 'Транзакция удалена';

  @override
  String get transactionUpdated => 'Транзакция обновлена';

  @override
  String get categoryChanged => 'Категория изменена';

  @override
  String get categoryStats => 'Статистика категории';

  @override
  String get totalSpent => 'Всего потрачено';

  @override
  String get totalEarned => 'Всего заработано';

  @override
  String get transactionCount => 'Количество транзакций';

  @override
  String get averageAmount => 'Средняя сумма';

  @override
  String get monthlyStats => 'Статистика по месяцам';

  @override
  String get yearlyStats => 'Статистика по годам';

  @override
  String get editTransaction => 'Редактировать транзакцию';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categoryTrips => 'Поездки';

  @override
  String get categorySalary => 'Зарплата';

  @override
  String get jointBudget => 'Общий бюджет';

  @override
  String get shareGroupCode => 'Поделиться кодом группы';

  @override
  String get joinGroup => 'Присоединиться к группе';

  @override
  String get logout => 'Выход';

  @override
  String get notifications => 'Уведомления';

  @override
  String get noNotifications => 'Уведомлений пока нет';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get jointBudgetGroup => 'Группа совместного бюджета';

  @override
  String get yourGroupCode => 'Код вашей группы';

  @override
  String get copy => 'Копировать';

  @override
  String get codeCopied => 'Код скопирован!';

  @override
  String shareMessage(String code) {
    return 'Присоединяйтесь к моей бюджетной группе по коду: $code';
  }

  @override
  String get shareCodeInstruction =>
      'Поделитесь этим кодом со своим партнером, чтобы синхронизировать ваши бюджеты.';

  @override
  String get createJointGroup => 'Создать совместную группу';

  @override
  String get createGroupInstruction =>
      'Создайте группу для совместных расходов и отслеживания бюджета.';

  @override
  String get createGroup => 'Создать группу';

  @override
  String get failedToCreateGroup => 'Не удалось создать группу.';

  @override
  String get enterInviteCode => 'Введите код приглашения';

  @override
  String get enterCodeInstruction =>
      'Введите код приглашения, отправленный вашим партнером, чтобы объединить бюджет.';

  @override
  String get pleaseEnterCode => 'Пожалуйста, введите код';

  @override
  String get joinedGroupSuccess => 'Вы успешно присоединились к группе!';

  @override
  String get invalidCodeError => 'Неверный код или группа не найдена';

  @override
  String get sharedWallet => 'Совместный кошелек';

  @override
  String get week => 'Неделя';

  @override
  String get month => 'Месяц';

  @override
  String get year => 'Год';

  @override
  String get allTime => 'За всё время';

  @override
  String get totalGroupSpend => 'Общие расходы группы';

  @override
  String get noDataForPeriod => 'Нет данных за этот период';

  @override
  String get whoOwesWhom => 'Кто кому должен';

  @override
  String get allSettledUp => 'Все расчеты произведены!';

  @override
  String get owes => 'должен';

  @override
  String get ok => 'ОК';

  @override
  String amountDetails(String amount) {
    return 'Сумма: $amount';
  }

  @override
  String inGroupWith(String partner) {
    return 'Вы в группе с: $partner';
  }

  @override
  String get personalAccount => 'Личный аккаунт';

  @override
  String get leaveGroup => 'Выйти из группы';

  @override
  String get leaveGroupConfirmTitle => 'Выход из группы';

  @override
  String get leaveGroupConfirmMessage =>
      'Вы уверены, что хотите выйти? Вы потеряете доступ к общему балансу, истории совместных транзакций и статистике группы.';

  @override
  String get leave => 'Выйти';

  @override
  String get setupGroup => 'Создать или подключиться к группе';

  @override
  String get profile => 'Профиль';

  @override
  String get personalData => 'Личные данные';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get profileUpdated => 'Профиль обновлен';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get account => 'Аккаунт';

  @override
  String get role => 'Роль';

  @override
  String get logoutAccount => 'Выйти из аккаунта';

  @override
  String get waitingForPartner => 'Ожидание партнера...';

  @override
  String inGroupWithMultiple(String partner, String count) {
    return 'Вы в группе с: $partner и еще $count';
  }

  @override
  String debtTo(String name) {
    return 'Долг: $name';
  }

  @override
  String creditFrom(String bank) {
    return '$bank (Кредит)';
  }

  @override
  String get debtMortgage => 'Ипотека';

  @override
  String get debtInstallment => 'Рассрочка';

  @override
  String get debtPrivate => 'Частный долг';

  @override
  String get debtBankLoan => 'Кредит';

  @override
  String get paymentOfDebt => 'Погашение долга';

  @override
  String get gettingLoan => 'Получение займа';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get passwordRecovery => 'Восстановление пароля';

  @override
  String get enterYourEmail => 'Введите ваш email';

  @override
  String get codeSentToEmail => 'Код отправлен на почту';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordResetSuccess => 'Пароль успешно изменен!';

  @override
  String get enterOtp => 'Введите OTP-код';

  @override
  String get confirmNewPassword => 'Подтвердите новый пароль';

  @override
  String get send => 'Отправить';

  @override
  String get reset => 'Сбросить пароль';

  @override
  String get invalidCode => 'Неверный или просроченный код';

  @override
  String get emailNotFound => 'Email не найден';

  @override
  String get checkConnection => 'Проверьте соединение';

  @override
  String get failedToSendCode => 'Ошибка отправки, попробуйте позже';
}
