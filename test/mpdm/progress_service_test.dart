import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sailing_course/shared/quiz/services/progress_service.dart';

void main() {
  late ProgressService progress;

  setUp(() async {
    // GIVEN: a fresh progress service.
    SharedPreferences.setMockInitialValues({});
    progress = ProgressService();
    await progress.init();
  });

  test('GIVEN a new card WHEN answered correctly THEN it is counted as seen and correct',
      () async {
    // WHEN: a correct answer is recorded.
    await progress.recordAnswer('x', true);

    // THEN: the card is counted as seen and correct.
    final p = progress.progressFor('x');
    expect(p.timesSeen, 1);
    expect(p.timesCorrect, 1);
  });

  test('GIVEN a new card WHEN answered incorrectly THEN it is seen but not correct',
      () async {
    // WHEN: a wrong answer is recorded.
    await progress.recordAnswer('y', false);

    // THEN: the card is counted as seen with zero correct.
    final p = progress.progressFor('y');
    expect(p.timesSeen, 1);
    expect(p.timesCorrect, 0);
  });

  test('GIVEN repeated answers WHEN recorded THEN counters and accuracy accumulate',
      () async {
    // WHEN: two correct and one wrong answer are recorded.
    await progress.recordAnswer('z', true);
    await progress.recordAnswer('z', true);
    await progress.recordAnswer('z', false);

    // THEN: totals and accuracy reflect every answer.
    expect(progress.totalAnswered, 3);
    expect(progress.totalCorrect, 2);
    expect(progress.accuracy, closeTo(2 / 3, 0.001));
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
