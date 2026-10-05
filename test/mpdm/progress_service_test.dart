import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sailing_course/modules/mpdm/services/progress_service.dart';

void main() {
  late ProgressService progress;

  setUp(() async {
    // GIVEN: a fresh progress service.
    SharedPreferences.setMockInitialValues({});
    progress = ProgressService();
    await progress.init();
  });

  test('GIVEN a new card WHEN answered correctly THEN it is scheduled in the future',
      () async {
    // WHEN: a correct answer is recorded.
    await progress.recordAnswer('x', true);

    // THEN: the card is no longer due now (next review pushed out).
    final now = DateTime.now().millisecondsSinceEpoch;
    final p = progress.progressFor('x');
    expect(p.timesSeen, 1);
    expect(p.timesCorrect, 1);
    expect(p.isDue(now), false);
    expect(progress.dueCount(['x']), 0);
  });

  test('GIVEN a new card WHEN answered incorrectly THEN it stays due the same day',
      () async {
    // WHEN: a wrong answer is recorded.
    await progress.recordAnswer('y', false);

    // THEN: interval reset, card counted as seen, 0 correct.
    final p = progress.progressFor('y');
    expect(p.timesSeen, 1);
    expect(p.timesCorrect, 0);
    expect(p.repetitions, 0);
  });

  test('GIVEN several correct answers WHEN repeated THEN the interval grows (SM-2)',
      () async {
    // WHEN: three correct answers in a row.
    await progress.recordAnswer('z', true);
    final first = progress.progressFor('z').intervalDays;
    await progress.recordAnswer('z', true);
    final second = progress.progressFor('z').intervalDays;
    await progress.recordAnswer('z', true);
    final third = progress.progressFor('z').intervalDays;

    // THEN: intervals grow 1 -> 3 -> more.
    expect(first, 1);
    expect(second, 3);
    expect(third, greaterThan(second));
  });

  test('GIVEN saved progress WHEN resetAll THEN stats are cleared', () async {
    // GIVEN: some progress exists.
    await progress.recordAnswer('a', true);
    expect(progress.seenCount, 1);

    // WHEN: reset.
    await progress.resetAll();

    // THEN: no data left.
    expect(progress.seenCount, 0);
    expect(progress.totalAnswered, 0);
  });

  test('GIVEN an exam score WHEN saving a better one THEN record grows, worse ignored',
      () async {
    // WHEN: 80% is saved, then 60%.
    await progress.saveBestExamScore(80);
    await progress.saveBestExamScore(60);

    // THEN: the best score is kept.
    expect(progress.bestExamScore, 80);
  });
}
