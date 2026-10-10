import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Learning progress of a single card (answer counters for statistics).
class CardProgress {
  final String cardId;
  int timesSeen;
  int timesCorrect;

  CardProgress({
    required this.cardId,
    this.timesSeen = 0,
    this.timesCorrect = 0,
  });

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'timesSeen': timesSeen,
        'timesCorrect': timesCorrect,
      };

  factory CardProgress.fromJson(Map<String, dynamic> json) => CardProgress(
        cardId: json['cardId'] as String,
        timesSeen: json['timesSeen'] as int? ?? 0,
        timesCorrect: json['timesCorrect'] as int? ?? 0,
      );
}

/// Manages learning progress and statistics.
/// Data is stored locally in SharedPreferences (offline-first).
///
/// Each module uses its own [namespace] so progress is kept separate.
class ProgressService {
  final String namespace;

  ProgressService({this.namespace = 'mpdm'});

  String get _progressKey => '${namespace}_progress_v1';
  String get _bestScoreKey => '${namespace}_best_exam_v1';

  final Map<String, CardProgress> _progress = {};
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_progressKey);
    if (raw != null) {
      final map = json.decode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        _progress[entry.key] =
            CardProgress.fromJson(entry.value as Map<String, dynamic>);
      }
    }
  }

  CardProgress progressFor(String cardId) =>
      _progress[cardId] ?? CardProgress(cardId: cardId);

  int get seenCount => _progress.values.where((p) => p.timesSeen > 0).length;

  int get totalAnswered =>
      _progress.values.fold(0, (sum, p) => sum + p.timesSeen);

  int get totalCorrect =>
      _progress.values.fold(0, (sum, p) => sum + p.timesCorrect);

  double get accuracy =>
      totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

  int get bestExamScore => _prefs?.getInt(_bestScoreKey) ?? 0;

  Future<void> saveBestExamScore(int percent) async {
    if (percent > bestExamScore) {
      await _prefs?.setInt(_bestScoreKey, percent);
    }
  }

  /// Records an answer for statistics.
  /// [correctFirstTry] = whether the answer was correct on the first attempt.
  Future<void> recordAnswer(String cardId, bool correctFirstTry) async {
    final p = _progress.putIfAbsent(cardId, () => CardProgress(cardId: cardId));
    p.timesSeen++;
    if (correctFirstTry) p.timesCorrect++;
    await _save();
  }

  Future<void> resetAll() async {
    _progress.clear();
    await _prefs?.remove(_progressKey);
    await _prefs?.remove(_bestScoreKey);
  }

  Future<void> _save() async {
    final map = _progress.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs?.setString(_progressKey, json.encode(map));
  }
}
