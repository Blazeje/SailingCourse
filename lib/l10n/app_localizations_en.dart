// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sailing Course';

  @override
  String get cancel => 'Cancel';

  @override
  String get homeLearn => 'Learn';

  @override
  String get homeLearnSubtitle =>
      'Browse the study modules and practise freely';

  @override
  String get homeExamInland => 'Exam – Inland sailing licence';

  @override
  String get homeExamSea => 'Exam – Offshore skipper';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get moduleMpdmTitle => 'MPDM – Lights & shapes';

  @override
  String get moduleMpdmSubtitle =>
      'International Regulations for Preventing Collisions at Sea (Rules 20–31)';

  @override
  String get moduleNavigationTitle => 'Navigation';

  @override
  String get moduleNavigationSubtitle =>
      'Compass corrections, bearings & fixes, dead reckoning, set & drift';

  @override
  String get moduleRescueTitle => 'Rescue & safety';

  @override
  String get moduleRescueSubtitle =>
      'SART, helicopter rescue, MOB, liferaft, distress signals';

  @override
  String get moduleLocjaTitle => 'Pilotage & marks';

  @override
  String get moduleLocjaSubtitle =>
      'IALA buoyage, cardinal marks, lights, chart symbols, tides';

  @override
  String get chooseLearnScope => 'Choose a study scope';

  @override
  String scopeAll(int count) {
    return 'Everything ($count)';
  }

  @override
  String scopeLights(int count) {
    return 'Lights ($count)';
  }

  @override
  String scopeShapes(int count) {
    return 'Day shapes ($count)';
  }

  @override
  String get learn => 'Learn';

  @override
  String get learnLights => 'Learn – lights';

  @override
  String get learnShapes => 'Learn – shapes';

  @override
  String get statistics => 'Statistics';

  @override
  String get learnSubtitle => 'Study with hints and explanations';

  @override
  String get exam => 'Exam';

  @override
  String examSubtitle(int score) {
    return 'All cards, no hints. Best: $score%';
  }

  @override
  String cardCounter(int current, int total) {
    return 'Card $current / $total';
  }

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get correctTitle => 'Correct!';

  @override
  String get result => 'Result';

  @override
  String get examPassed => 'Passed! (threshold 75%)';

  @override
  String get examFailed => 'Failed (threshold 75%)';

  @override
  String get correctFirstTry => 'correct answers on the first try';

  @override
  String get backToMenu => 'Back to menu';

  @override
  String get statSeen => 'Seen cards';

  @override
  String get statAccuracy => 'Overall accuracy';

  @override
  String get statOverall => 'Overall';

  @override
  String get statByModule => 'By module';

  @override
  String accuracyValue(int percent, int correct, int total) {
    return '$percent%  ($correct/$total)';
  }

  @override
  String get statBestExam => 'Best exam score';

  @override
  String fraction(int part, int whole) {
    return '$part / $whole';
  }

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get resetConfirmTitle => 'Reset progress?';

  @override
  String get resetConfirmBody =>
      'This will delete all learning and exam-record data.';

  @override
  String get reset => 'Reset';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';
}
