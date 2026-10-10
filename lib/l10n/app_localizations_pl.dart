// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Kurs żeglarski';

  @override
  String get cancel => 'Anuluj';

  @override
  String get homeLearn => 'Nauka';

  @override
  String get homeLearnSubtitle => 'Przeglądaj moduły i ćwicz dowolnie';

  @override
  String get homeExamInland => 'Egzamin – Patent żeglarza śródlądowego';

  @override
  String get homeExamSea => 'Egzamin – Sternik morski';

  @override
  String get comingSoon => 'Wkrótce';

  @override
  String get moduleMpdmTitle => 'MPDM – Światła i znaki';

  @override
  String get moduleMpdmSubtitle =>
      'Międzynarodowe Prawo Drogi Morskiej (Prawidła 20–31)';

  @override
  String get moduleNavigationTitle => 'Nawigacja';

  @override
  String get moduleNavigationSubtitle =>
      'Poprawki kompasu, namiary i pozycja, zliczanie drogi, prąd i znos';

  @override
  String get moduleMeteoTitle => 'Meteorologia';

  @override
  String get moduleMeteoSubtitle =>
      'Skala Beauforta, ciśnienie i fronty, chmury, bryza lądowa i morska';

  @override
  String get moduleRescueTitle => 'Ratownictwo';

  @override
  String get moduleRescueSubtitle =>
      'SART, ewakuacja helikopterem, MOB, tratwa, sygnały wzywania pomocy';

  @override
  String get moduleLocjaTitle => 'Locja';

  @override
  String get moduleLocjaSubtitle =>
      'Oznakowanie IALA, znaki kardynalne, światła, symbole mapowe, pływy';

  @override
  String get chooseLearnScope => 'Wybierz zakres nauki';

  @override
  String scopeAll(int count) {
    return 'Wszystko ($count)';
  }

  @override
  String scopeLights(int count) {
    return 'Światła ($count)';
  }

  @override
  String scopeShapes(int count) {
    return 'Znaki dzienne ($count)';
  }

  @override
  String get learn => 'Nauka';

  @override
  String get learnLights => 'Nauka – światła';

  @override
  String get learnShapes => 'Nauka – znaki';

  @override
  String get statistics => 'Statystyki';

  @override
  String get learnSubtitle => 'Ucz się z podpowiedziami i wyjaśnieniami';

  @override
  String get exam => 'Egzamin';

  @override
  String examSubtitle(int score) {
    return 'Wszystkie karty, bez podpowiedzi. Rekord: $score%';
  }

  @override
  String cardCounter(int current, int total) {
    return 'Karta $current / $total';
  }

  @override
  String get next => 'Dalej';

  @override
  String get finish => 'Zakończ';

  @override
  String get correctTitle => 'Dobrze!';

  @override
  String get result => 'Wynik';

  @override
  String get examPassed => 'Zdane! (próg 75%)';

  @override
  String get examFailed => 'Nie zdane (próg 75%)';

  @override
  String get correctFirstTry => 'poprawne odpowiedzi za pierwszym razem';

  @override
  String get backToMenu => 'Powrót do menu';

  @override
  String get statSeen => 'Poznane karty';

  @override
  String get statAccuracy => 'Łączna skuteczność';

  @override
  String get statOverall => 'Łącznie';

  @override
  String get statByModule => 'Według modułu';

  @override
  String accuracyValue(int percent, int correct, int total) {
    return '$percent%  ($correct/$total)';
  }

  @override
  String get statBestExam => 'Najlepszy wynik egzaminu';

  @override
  String fraction(int part, int whole) {
    return '$part / $whole';
  }

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get resetConfirmTitle => 'Zresetować postępy?';

  @override
  String get resetConfirmBody =>
      'Usunie to wszystkie dane nauki i rekord egzaminu.';

  @override
  String get reset => 'Resetuj';

  @override
  String get resetProgress => 'Resetuj postępy';

  @override
  String get language => 'Język';

  @override
  String get systemDefault => 'Domyślny systemu';
}
