import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/quiz_card.dart';

/// Loads quiz cards from a local, per-language JSON file (offline-first).
///
/// The active [languageCode] selects the asset (e.g. `cards_en.json`).
/// Unsupported codes fall back to Polish. Results are cached per language.
class CardRepository {
  static const _supported = {'pl', 'en'};
  static const _fallback = 'pl';

  String languageCode;
  final Map<String, List<QuizCard>> _cache = {};

  CardRepository({this.languageCode = _fallback});

  String get _resolvedLanguage =>
      _supported.contains(languageCode) ? languageCode : _fallback;

  Future<List<QuizCard>> loadCards() async {
    final lang = _resolvedLanguage;
    final cached = _cache[lang];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/mpdm/cards_$lang.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final cards = (data['cards'] as List)
        .map((e) => QuizCard.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache[lang] = cards;
    return cards;
  }

  Future<List<QuizCard>> loadByCategory(CardCategory? category) async {
    final all = await loadCards();
    if (category == null) return all;
    return all.where((c) => c.category == category).toList();
  }
}
