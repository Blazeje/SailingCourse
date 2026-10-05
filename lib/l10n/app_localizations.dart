import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

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
    Locale('pl'),
  ];

  /// Application name shown in the OS and home app bar.
  ///
  /// In en, this message translates to:
  /// **'Sailing Course'**
  String get appTitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @moduleMpdmTitle.
  ///
  /// In en, this message translates to:
  /// **'MPDM – Lights & shapes'**
  String get moduleMpdmTitle;

  /// No description provided for @moduleMpdmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'International Regulations for Preventing Collisions at Sea (Rules 20–31)'**
  String get moduleMpdmSubtitle;

  /// No description provided for @moduleKnotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sailing knots'**
  String get moduleKnotsTitle;

  /// No description provided for @moduleNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get moduleNavigationTitle;

  /// No description provided for @chooseLearnScope.
  ///
  /// In en, this message translates to:
  /// **'Choose a study scope'**
  String get chooseLearnScope;

  /// No description provided for @scopeAll.
  ///
  /// In en, this message translates to:
  /// **'Everything ({count})'**
  String scopeAll(int count);

  /// No description provided for @scopeLights.
  ///
  /// In en, this message translates to:
  /// **'Lights ({count})'**
  String scopeLights(int count);

  /// No description provided for @scopeShapes.
  ///
  /// In en, this message translates to:
  /// **'Day shapes ({count})'**
  String scopeShapes(int count);

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @learnLights.
  ///
  /// In en, this message translates to:
  /// **'Learn – lights'**
  String get learnLights;

  /// No description provided for @learnShapes.
  ///
  /// In en, this message translates to:
  /// **'Learn – shapes'**
  String get learnShapes;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @learnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Study with hints and explanations'**
  String get learnSubtitle;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews (SRS)'**
  String get reviews;

  /// No description provided for @reviewsShort.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsShort;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today: {count}'**
  String dueToday(int count);

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No cards to review – come back later'**
  String get noReviews;

  /// No description provided for @exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get exam;

  /// No description provided for @examSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All cards, no hints. Best: {score}%'**
  String examSubtitle(int score);

  /// No description provided for @cardCounter.
  ///
  /// In en, this message translates to:
  /// **'Card {current} / {total}'**
  String cardCounter(int current, int total);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @examPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed! (threshold 75%)'**
  String get examPassed;

  /// No description provided for @examFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed (threshold 75%)'**
  String get examFailed;

  /// No description provided for @correctFirstTry.
  ///
  /// In en, this message translates to:
  /// **'correct answers on the first try'**
  String get correctFirstTry;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToMenu;

  /// No description provided for @statSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen cards'**
  String get statSeen;

  /// No description provided for @statMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered (interval ≥ 7 days)'**
  String get statMastered;

  /// No description provided for @statAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Overall accuracy'**
  String get statAccuracy;

  /// No description provided for @accuracyValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%  ({correct}/{total})'**
  String accuracyValue(int percent, int correct, int total);

  /// No description provided for @statBestExam.
  ///
  /// In en, this message translates to:
  /// **'Best exam score'**
  String get statBestExam;

  /// No description provided for @fraction.
  ///
  /// In en, this message translates to:
  /// **'{part} / {whole}'**
  String fraction(int part, int whole);

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(int value);

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all learning, review and exam-record data.'**
  String get resetConfirmBody;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgress;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
