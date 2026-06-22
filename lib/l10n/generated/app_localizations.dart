import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

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
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance App'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionDataNotifications.
  ///
  /// In en, this message translates to:
  /// **'Data & Notifications'**
  String get sectionDataNotifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @scheduleReminder.
  ///
  /// In en, this message translates to:
  /// **'Contact admin'**
  String get scheduleReminder;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export Success'**
  String get exportSuccess;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for 9:00'**
  String get reminderSet;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring?'**
  String get recurring;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @changeCategory.
  ///
  /// In en, this message translates to:
  /// **'Change Category'**
  String get changeCategory;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @pinnedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinnedTransactions;

  /// No description provided for @viewCategoryStats.
  ///
  /// In en, this message translates to:
  /// **'View Category Stats'**
  String get viewCategoryStats;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteConfirmMessage;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionUpdated;

  /// No description provided for @categoryChanged.
  ///
  /// In en, this message translates to:
  /// **'Category changed'**
  String get categoryChanged;

  /// No description provided for @categoryStats.
  ///
  /// In en, this message translates to:
  /// **'Category Statistics'**
  String get categoryStats;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Count'**
  String get transactionCount;

  /// No description provided for @averageAmount.
  ///
  /// In en, this message translates to:
  /// **'Average Amount'**
  String get averageAmount;

  /// No description provided for @monthlyStats.
  ///
  /// In en, this message translates to:
  /// **'Monthly Statistics'**
  String get monthlyStats;

  /// No description provided for @yearlyStats.
  ///
  /// In en, this message translates to:
  /// **'Yearly Statistics'**
  String get yearlyStats;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get categoryTrips;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @jointBudget.
  ///
  /// In en, this message translates to:
  /// **'Joint Budget'**
  String get jointBudget;

  /// No description provided for @shareGroupCode.
  ///
  /// In en, this message translates to:
  /// **'Share Group Code'**
  String get shareGroupCode;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroup;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @noNote.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get noNote;

  /// No description provided for @jointBudgetGroup.
  ///
  /// In en, this message translates to:
  /// **'Joint Budget Group'**
  String get jointBudgetGroup;

  /// No description provided for @yourGroupCode.
  ///
  /// In en, this message translates to:
  /// **'Your Group Code'**
  String get yourGroupCode;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my budget group using code: {code}'**
  String shareMessage(String code);

  /// No description provided for @shareCodeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your partner correctly to sync your budgets.'**
  String get shareCodeInstruction;

  /// No description provided for @createJointGroup.
  ///
  /// In en, this message translates to:
  /// **'Create a Joint Group'**
  String get createJointGroup;

  /// No description provided for @createGroupInstruction.
  ///
  /// In en, this message translates to:
  /// **'Create a group to share expenses and track budget together.'**
  String get createGroupInstruction;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @failedToCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to create group.'**
  String get failedToCreateGroup;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Invite Code'**
  String get enterInviteCode;

  /// No description provided for @enterCodeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code shared by your partner to join their budget.'**
  String get enterCodeInstruction;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a code'**
  String get pleaseEnterCode;

  /// No description provided for @joinedGroupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined group!'**
  String get joinedGroupSuccess;

  /// No description provided for @invalidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid code or group not found'**
  String get invalidCodeError;

  /// No description provided for @sharedWallet.
  ///
  /// In en, this message translates to:
  /// **'Shared Wallet'**
  String get sharedWallet;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @totalGroupSpend.
  ///
  /// In en, this message translates to:
  /// **'Total Group Spend'**
  String get totalGroupSpend;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// No description provided for @whoOwesWhom.
  ///
  /// In en, this message translates to:
  /// **'Who owes whom'**
  String get whoOwesWhom;

  /// No description provided for @allSettledUp.
  ///
  /// In en, this message translates to:
  /// **'All settled up!'**
  String get allSettledUp;

  /// No description provided for @owes.
  ///
  /// In en, this message translates to:
  /// **'owes'**
  String get owes;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @amountDetails.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String amountDetails(String amount);

  /// No description provided for @inGroupWith.
  ///
  /// In en, this message translates to:
  /// **'You are in a group with: {partner}'**
  String inGroupWith(String partner);

  /// No description provided for @personalAccount.
  ///
  /// In en, this message translates to:
  /// **'Personal Account'**
  String get personalAccount;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @leaveGroupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroupConfirmTitle;

  /// No description provided for @leaveGroupConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave? You will lose access to the shared balance, joint transactions history, and group statistics.'**
  String get leaveGroupConfirmMessage;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @setupGroup.
  ///
  /// In en, this message translates to:
  /// **'Setup Group'**
  String get setupGroup;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @logoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutAccount;

  /// No description provided for @waitingForPartner.
  ///
  /// In en, this message translates to:
  /// **'Waiting for partner...'**
  String get waitingForPartner;

  /// No description provided for @inGroupWithMultiple.
  ///
  /// In en, this message translates to:
  /// **'You are in a group with: {partner} and {count} more'**
  String inGroupWithMultiple(String partner, String count);

  /// No description provided for @debtTo.
  ///
  /// In en, this message translates to:
  /// **'Debt: {name}'**
  String debtTo(String name);

  /// No description provided for @creditFrom.
  ///
  /// In en, this message translates to:
  /// **'{bank} (Credit)'**
  String creditFrom(String bank);

  /// No description provided for @debtMortgage.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get debtMortgage;

  /// No description provided for @debtInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get debtInstallment;

  /// No description provided for @debtPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private Debt'**
  String get debtPrivate;

  /// No description provided for @debtBankLoan.
  ///
  /// In en, this message translates to:
  /// **'Bank Loan'**
  String get debtBankLoan;

  /// No description provided for @paymentOfDebt.
  ///
  /// In en, this message translates to:
  /// **'Payment of Debt'**
  String get paymentOfDebt;

  /// No description provided for @gettingLoan.
  ///
  /// In en, this message translates to:
  /// **'Getting a Loan'**
  String get gettingLoan;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @passwordRecovery.
  ///
  /// In en, this message translates to:
  /// **'Password Recovery'**
  String get passwordRecovery;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @codeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Reset code sent to email'**
  String get codeSentToEmail;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed!'**
  String get passwordResetSuccess;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOtp;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired reset code'**
  String get invalidCode;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection'**
  String get checkConnection;

  /// No description provided for @failedToSendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code, try again later'**
  String get failedToSendCode;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimit;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @exceedsBudgetBy.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Exceeds budget by {amount}'**
  String exceedsBudgetBy(String amount);

  /// No description provided for @remainingBudget.
  ///
  /// In en, this message translates to:
  /// **'Remaining budget: {amount}'**
  String remainingBudget(String amount);

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved!'**
  String get budgetSaved;

  /// No description provided for @adminAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Admin Announcement'**
  String get adminAnnouncement;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get viewDetails;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterLoginDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your login details'**
  String get enterLoginDetails;

  /// No description provided for @fillRegistrationForm.
  ///
  /// In en, this message translates to:
  /// **'Fill out the registration form'**
  String get fillRegistrationForm;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccountRegister;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @onboardingTrackExpenses.
  ///
  /// In en, this message translates to:
  /// **'Track your expenses easily.'**
  String get onboardingTrackExpenses;

  /// No description provided for @onboardingAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get onboardingAnalyze;

  /// No description provided for @onboardingSeeMoney.
  ///
  /// In en, this message translates to:
  /// **'See where your money goes.'**
  String get onboardingSeeMoney;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Contact Administrator'**
  String get contactAdmin;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supportMessage;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully!'**
  String get messageSent;

  /// No description provided for @adminMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get adminMessages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages found'**
  String get noMessages;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @savingsGoalsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Goals'**
  String get savingsGoalsManage;

  /// No description provided for @addSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Savings Goal'**
  String get addSavingsGoal;

  /// No description provided for @savingsGoalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name (e.g., Car)'**
  String get savingsGoalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Initial Savings'**
  String get currentAmount;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @amountToAdd.
  ///
  /// In en, this message translates to:
  /// **'Amount to Add'**
  String get amountToAdd;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal Completed!'**
  String get goalCompleted;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No active savings goals yet'**
  String get noGoalsYet;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @savingGoalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved!'**
  String get savingGoalSaved;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @noDebts.
  ///
  /// In en, this message translates to:
  /// **'No active debts'**
  String get noDebts;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @creditor.
  ///
  /// In en, this message translates to:
  /// **'Creditor (Bank/Person)'**
  String get creditor;

  /// No description provided for @debtType.
  ///
  /// In en, this message translates to:
  /// **'Debt Type'**
  String get debtType;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @makePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get makePayment;

  /// No description provided for @invalidPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid payment amount'**
  String get invalidPaymentAmount;

  /// No description provided for @invalidInputData.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid data'**
  String get invalidInputData;

  /// No description provided for @addDebtError.
  ///
  /// In en, this message translates to:
  /// **'Error adding debt'**
  String get addDebtError;

  /// No description provided for @kaspiCalculator.
  ///
  /// In en, this message translates to:
  /// **'Kaspi Calculator'**
  String get kaspiCalculator;

  /// No description provided for @earlyRepaymentSavings.
  ///
  /// In en, this message translates to:
  /// **'If repaid early today, you will save on interest:'**
  String get earlyRepaymentSavings;

  /// No description provided for @earlyRepaymentNote.
  ///
  /// In en, this message translates to:
  /// **'The entire amount will go towards reducing the principal debt, canceling future interest.'**
  String get earlyRepaymentNote;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @earlyRepayment.
  ///
  /// In en, this message translates to:
  /// **'Early Repayment'**
  String get earlyRepayment;

  /// No description provided for @kaspiProduct.
  ///
  /// In en, this message translates to:
  /// **'Kaspi Product'**
  String get kaspiProduct;

  /// No description provided for @kaspiCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit / Kaspi Red'**
  String get kaspiCredit;

  /// No description provided for @kaspiInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment (Friday)'**
  String get kaspiInstallment;

  /// No description provided for @annualRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual Rate (%)'**
  String get annualRateLabel;

  /// No description provided for @rateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 24'**
  String get rateHint;

  /// No description provided for @termLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get termLabel;

  /// No description provided for @monthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsCount(String count);

  /// No description provided for @dateOfIssue.
  ///
  /// In en, this message translates to:
  /// **'Date of Issue'**
  String get dateOfIssue;

  /// No description provided for @kaspiInstallmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Kaspi Installment • {months} mo.'**
  String kaspiInstallmentInfo(String months);

  /// No description provided for @kaspiCreditInfo.
  ///
  /// In en, this message translates to:
  /// **'Kaspi Credit • {rate}% • {months} mo.'**
  String kaspiCreditInfo(String rate, String months);

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get activeSubscriptions;

  /// No description provided for @upcomingPayments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payments'**
  String get upcomingPayments;

  /// No description provided for @totalMonthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spend'**
  String get totalMonthlySpend;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscription;

  /// No description provided for @billingCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle'**
  String get billingCycle;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @daysBefore.
  ///
  /// In en, this message translates to:
  /// **'days before'**
  String get daysBefore;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions'**
  String get noSubscriptions;

  /// No description provided for @subscriptionAdded.
  ///
  /// In en, this message translates to:
  /// **'Subscription added successfully'**
  String get subscriptionAdded;

  /// No description provided for @subscriptionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Subscription deleted'**
  String get subscriptionDeleted;

  /// No description provided for @subscriptionPaid.
  ///
  /// In en, this message translates to:
  /// **'Subscription paid'**
  String get subscriptionPaid;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @reminderToday.
  ///
  /// In en, this message translates to:
  /// **'On the day of payment'**
  String get reminderToday;

  /// No description provided for @reminder1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminder1Day;

  /// No description provided for @reminder2Days.
  ///
  /// In en, this message translates to:
  /// **'2 days before'**
  String get reminder2Days;

  /// No description provided for @reminder3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days before'**
  String get reminder3Days;

  /// No description provided for @splitTransaction.
  ///
  /// In en, this message translates to:
  /// **'Split Transaction'**
  String get splitTransaction;

  /// No description provided for @splitRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining to allocate: {amount}'**
  String splitRemaining(String amount);

  /// No description provided for @splitOverallocated.
  ///
  /// In en, this message translates to:
  /// **'Overallocated: {amount}'**
  String splitOverallocated(String amount);

  /// No description provided for @splitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction successfully split!'**
  String get splitSuccess;

  /// No description provided for @addSplitPart.
  ///
  /// In en, this message translates to:
  /// **'Add part'**
  String get addSplitPart;

  /// No description provided for @splitPartTitle.
  ///
  /// In en, this message translates to:
  /// **'Part {index}'**
  String splitPartTitle(int index);

  /// No description provided for @splitValidationError.
  ///
  /// In en, this message translates to:
  /// **'Total sum of parts must equal original transaction amount'**
  String get splitValidationError;

  /// No description provided for @selectCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Please select categories for all parts'**
  String get selectCategoryError;
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
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
