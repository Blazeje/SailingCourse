import 'package:flutter_test/flutter_test.dart';

import 'package:sailing_course/shared/quiz/data/card_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GIVEN Polish locale WHEN loadCards THEN 30 Polish cards are returned',
      () async {
    // GIVEN: a repository set to Polish.
    final repo = CardRepository(languageCode: 'pl');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full deck loads and content is Polish.
    expect(cards.length, 30);
    expect(cards.first.question, contains('statek'));
  });

  test('GIVEN English locale WHEN loadCards THEN 30 English cards are returned',
      () async {
    // GIVEN: a repository set to English.
    final repo = CardRepository(languageCode: 'en');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full deck loads and content is English.
    expect(cards.length, 30);
    expect(cards.first.question, contains('vessel'));
  });

  test('GIVEN an unsupported locale WHEN loadCards THEN it falls back to Polish',
      () async {
    // GIVEN: a repository with an unsupported language.
    final repo = CardRepository(languageCode: 'de');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: Polish deck is used as the fallback.
    expect(cards.length, 30);
    expect(cards.first.question, contains('statek'));
  });
}
