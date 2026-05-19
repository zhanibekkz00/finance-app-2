// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance App';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get exportData => 'Export Data';

  @override
  String get scheduleReminder => 'Schedule Reminder';

  @override
  String get exportSuccess => 'Export Success';

  @override
  String get reminderSet => 'Reminder set for 9:00';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note';

  @override
  String get date => 'Date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get login => 'Login';

  @override
  String get welcome => 'Welcome';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get recurring => 'Recurring?';

  @override
  String get search => 'Search...';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get share => 'Share';

  @override
  String get changeCategory => 'Change Category';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get viewCategoryStats => 'View Category Stats';

  @override
  String get deleteConfirmTitle => 'Delete Transaction?';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get categoryChanged => 'Category changed';

  @override
  String get categoryStats => 'Category Statistics';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get transactionCount => 'Transaction Count';

  @override
  String get averageAmount => 'Average Amount';

  @override
  String get monthlyStats => 'Monthly Statistics';

  @override
  String get yearlyStats => 'Yearly Statistics';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get confirm => 'Confirm';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryTrips => 'Trips';

  @override
  String get categorySalary => 'Salary';

  @override
  String get jointBudget => 'Joint Budget';

  @override
  String get shareGroupCode => 'Share Group Code';

  @override
  String get joinGroup => 'Join Group';

  @override
  String get logout => 'Logout';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get unknown => 'Unknown';

  @override
  String get jointBudgetGroup => 'Joint Budget Group';

  @override
  String get yourGroupCode => 'Your Group Code';

  @override
  String get copy => 'Copy';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String shareMessage(String code) {
    return 'Join my budget group using code: $code';
  }

  @override
  String get shareCodeInstruction =>
      'Share this code with your partner correctly to sync your budgets.';

  @override
  String get createJointGroup => 'Create a Joint Group';

  @override
  String get createGroupInstruction =>
      'Create a group to share expenses and track budget together.';

  @override
  String get createGroup => 'Create Group';

  @override
  String get failedToCreateGroup => 'Failed to create group.';

  @override
  String get enterInviteCode => 'Enter Invite Code';

  @override
  String get enterCodeInstruction =>
      'Enter the invite code shared by your partner to join their budget.';

  @override
  String get pleaseEnterCode => 'Please enter a code';

  @override
  String get joinedGroupSuccess => 'Successfully joined group!';

  @override
  String get invalidCodeError => 'Invalid code or group not found';

  @override
  String get sharedWallet => 'Shared Wallet';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get allTime => 'All Time';

  @override
  String get totalGroupSpend => 'Total Group Spend';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get whoOwesWhom => 'Who owes whom';

  @override
  String get allSettledUp => 'All settled up!';

  @override
  String get owes => 'owes';

  @override
  String get ok => 'OK';

  @override
  String amountDetails(String amount) {
    return 'Amount: $amount';
  }

  @override
  String inGroupWith(String partner) {
    return 'You are in a group with: $partner';
  }

  @override
  String get personalAccount => 'Personal Account';

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get leaveGroupConfirmTitle => 'Leave Group';

  @override
  String get leaveGroupConfirmMessage =>
      'Are you sure you want to leave? You will lose access to the shared balance, joint transactions history, and group statistics.';

  @override
  String get leave => 'Leave';

  @override
  String get setupGroup => 'Setup Group';

  @override
  String get profile => 'Profile';

  @override
  String get personalData => 'Personal Data';

  @override
  String get yourName => 'Your Name';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get displayName => 'Display Name';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get account => 'Account';

  @override
  String get role => 'Role';

  @override
  String get logoutAccount => 'Log Out';
}
