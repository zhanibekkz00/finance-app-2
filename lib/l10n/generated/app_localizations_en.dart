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
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionDataNotifications => 'Data & Notifications';

  @override
  String get language => 'Language';

  @override
  String get exportData => 'Export Data';

  @override
  String get scheduleReminder => 'Contact admin';

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
  String get summary => 'Summary';

  @override
  String get noNote => 'No note';

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

  @override
  String get waitingForPartner => 'Waiting for partner...';

  @override
  String inGroupWithMultiple(String partner, String count) {
    return 'You are in a group with: $partner and $count more';
  }

  @override
  String debtTo(String name) {
    return 'Debt: $name';
  }

  @override
  String creditFrom(String bank) {
    return '$bank (Credit)';
  }

  @override
  String get debtMortgage => 'Mortgage';

  @override
  String get debtInstallment => 'Installment';

  @override
  String get debtPrivate => 'Private Debt';

  @override
  String get debtBankLoan => 'Bank Loan';

  @override
  String get paymentOfDebt => 'Payment of Debt';

  @override
  String get gettingLoan => 'Getting a Loan';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get passwordRecovery => 'Password Recovery';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get codeSentToEmail => 'Reset code sent to email';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordResetSuccess => 'Password successfully changed!';

  @override
  String get enterOtp => 'Enter OTP Code';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get send => 'Send';

  @override
  String get reset => 'Reset Password';

  @override
  String get invalidCode => 'Invalid or expired reset code';

  @override
  String get emailNotFound => 'Email not found';

  @override
  String get checkConnection => 'Check your connection';

  @override
  String get failedToSendCode => 'Failed to send code, try again later';

  @override
  String get budgets => 'Budgets';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String exceedsBudgetBy(String amount) {
    return '⚠️ Exceeds budget by $amount';
  }

  @override
  String remainingBudget(String amount) {
    return 'Remaining budget: $amount';
  }

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get budgetSaved => 'Budget saved!';

  @override
  String get adminAnnouncement => 'Admin Announcement';

  @override
  String get viewDetails => 'Read';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get registration => 'Registration';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get createAccount => 'Create Account';

  @override
  String get enterLoginDetails => 'Enter your login details';

  @override
  String get fillRegistrationForm => 'Fill out the registration form';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get register => 'Register';

  @override
  String get noAccountRegister => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get onboardingTrackExpenses => 'Track your expenses easily.';

  @override
  String get onboardingAnalyze => 'Analyze';

  @override
  String get onboardingSeeMoney => 'See where your money goes.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get contactAdmin => 'Contact Administrator';

  @override
  String get supportMessage => 'Message';

  @override
  String get messageSent => 'Message sent successfully!';

  @override
  String get adminMessages => 'Messages';

  @override
  String get noMessages => 'No messages found';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get savingsGoalsManage => 'Manage Goals';

  @override
  String get addSavingsGoal => 'Add Savings Goal';

  @override
  String get savingsGoalName => 'Goal Name (e.g., Car)';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get currentAmount => 'Initial Savings';

  @override
  String get targetDate => 'Target Date';

  @override
  String get addMoney => 'Add Money';

  @override
  String get amountToAdd => 'Amount to Add';

  @override
  String get goalCompleted => 'Goal Completed!';

  @override
  String get noGoalsYet => 'No active savings goals yet';

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get savingGoalSaved => 'Goal saved!';

  @override
  String get debts => 'Debts';

  @override
  String get noDebts => 'No active debts';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get creditor => 'Creditor (Bank/Person)';

  @override
  String get debtType => 'Debt Type';

  @override
  String get currency => 'Currency';

  @override
  String get total => 'Total';

  @override
  String get makePayment => 'Make Payment';

  @override
  String get invalidPaymentAmount => 'Invalid payment amount';

  @override
  String get invalidInputData => 'Please enter valid data';

  @override
  String get addDebtError => 'Error adding debt';

  @override
  String get kaspiCalculator => 'Kaspi Calculator';

  @override
  String get earlyRepaymentSavings =>
      'If repaid early today, you will save on interest:';

  @override
  String get earlyRepaymentNote =>
      'The entire amount will go towards reducing the principal debt, canceling future interest.';

  @override
  String get close => 'Close';

  @override
  String get earlyRepayment => 'Early Repayment';

  @override
  String get kaspiProduct => 'Kaspi Product';

  @override
  String get kaspiCredit => 'Credit / Kaspi Red';

  @override
  String get kaspiInstallment => 'Installment (Friday)';

  @override
  String get annualRateLabel => 'Annual Rate (%)';

  @override
  String get rateHint => 'e.g., 24';

  @override
  String get termLabel => 'Term';

  @override
  String monthsCount(String count) {
    return '$count months';
  }

  @override
  String get dateOfIssue => 'Date of Issue';

  @override
  String kaspiInstallmentInfo(String months) {
    return 'Kaspi Installment • $months mo.';
  }

  @override
  String kaspiCreditInfo(String rate, String months) {
    return 'Kaspi Credit • $rate% • $months mo.';
  }

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get activeSubscriptions => 'Active Subscriptions';

  @override
  String get upcomingPayments => 'Upcoming Payments';

  @override
  String get totalMonthlySpend => 'Monthly Spend';

  @override
  String get payNow => 'Pay Now';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get billingCycle => 'Billing Cycle';

  @override
  String get reminder => 'Reminder';

  @override
  String get daysBefore => 'days before';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get noSubscriptions => 'No subscriptions';

  @override
  String get subscriptionAdded => 'Subscription added successfully';

  @override
  String get subscriptionDeleted => 'Subscription deleted';

  @override
  String get subscriptionPaid => 'Subscription paid';

  @override
  String get name => 'Name';

  @override
  String get daily => 'Daily';

  @override
  String get reminderToday => 'On the day of payment';

  @override
  String get reminder1Day => '1 day before';

  @override
  String get reminder2Days => '2 days before';

  @override
  String get reminder3Days => '3 days before';

  @override
  String get splitTransaction => 'Split Transaction';

  @override
  String splitRemaining(String amount) {
    return 'Remaining to allocate: $amount';
  }

  @override
  String splitOverallocated(String amount) {
    return 'Overallocated: $amount';
  }

  @override
  String get splitSuccess => 'Transaction successfully split!';

  @override
  String get addSplitPart => 'Add part';

  @override
  String splitPartTitle(int index) {
    return 'Part $index';
  }

  @override
  String get splitValidationError =>
      'Total sum of parts must equal original transaction amount';

  @override
  String get selectCategoryError => 'Please select categories for all parts';
}
