import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Learning progress of a single card (SM-2 compatible SRS model).
class CardProgress {
  final String cardId;
  int repetitions;
  int intervalDays;
  double ease;
  int dueDateMs;
  int timesSeen;
  int timesCorrect;

  CardProgress({
    required this.cardId,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.ease = 2.5,
    this.dueDateMs = 0,
    this.timesSeen = 0,
    this.timesCorrect = 0,
  });

  bool isDue(int nowMs) => dueDateMs <= nowMs;

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'ease': ease,
        'dueDateMs': dueDateMs,
        'timesSeen': timesSeen,
        'timesCorrect': timesCorrect,
      };

  factory CardProgress.fromJson(Map<String, dynamic> json) => CardProgress(
        cardId: json['cardId'] as String,
        repetitions: json['repetitions'] as int? ?? 0,
        intervalDays: json['intervalDays'] as int? ?? 0,
        ease: (json['ease'] as num?)?.toDouble() ?? 2.5,
        dueDateMs: json['dueDateMs'] as int? ?? 0,
        timesSeen: json['timesSeen'] as int? ?? 0,
        timesCorrect: json['timesCorrect'] as int? ?? 0,
      );
}

/// Manages progress, statistics and the review schedule (SRS).
/// Dane trzymane lokalnie w SharedPreferences (offline-first).
class ProgressService {
  static const _progressKey = 'mpdm_progress_v1';
  static const _bestScoreKey = 'mpdm_best_exam_v1';

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

  int get masteredCount =>
      _progress.values.where((p) => p.intervalDays >= 7).length;

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

  /// Returns the ids of cards due for review, including new ones.
  List<String> dueCardIds(List<String> allIds) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return allIds.where((id) {
      final p = _progress[id];
      return p == null || p.isDue(now);
    }).toList();
  }

  int dueCount(List<String> allIds) => dueCardIds(allIds).length;

  /// Records an answer and updates the SRS schedule (SM-2).
  /// [correctFirstTry] = whether the answer was correct on the first attempt.
  Future<void> recordAnswer(String cardId, bool correctFirstTry) async {
    final p = _progress.putIfAbsent(cardId, () => CardProgress(cardId: cardId));
    p.timesSeen++;
    if (correctFirstTry) p.timesCorrect++;

    final quality = correctFirstTry ? 5 : 2;

    if (quality < 3) {
      p.repetitions = 0;
      p.intervalDays = 1;
    } else {
      if (p.repetitions == 0) {
        p.intervalDays = 1;
      } else if (p.repetitions == 1) {
        p.intervalDays = 3;
      } else {
        p.intervalDays = (p.intervalDays * p.ease).round();
      }
      p.repetitions++;
    }

    p.ease += 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
    if (p.ease < 1.3) p.ease = 1.3;

    p.dueDateMs = DateTime.now()
        .add(Duration(days: p.intervalDays))
        .millisecondsSinceEpoch;

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
