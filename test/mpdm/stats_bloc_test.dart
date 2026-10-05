import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sailing_course/modules/mpdm/bloc/stats_bloc.dart';
import 'package:sailing_course/modules/mpdm/services/progress_service.dart';

void main() {
  late ProgressService progress;

  setUp(() async {
    // GIVEN: a clean progress store.
    SharedPreferences.setMockInitialValues({});
    progress = ProgressService();
    await progress.init();
  });

  blocTest<StatsBloc, StatsState>(
    'GIVEN two answers (1 correct) WHEN StatsStarted THEN accuracy is 50%',
    build: () => StatsBloc(progress: progress),
    act: (bloc) async {
      await progress.recordAnswer('a', true);
      await progress.recordAnswer('b', false);
      bloc.add(const StatsStarted());
    },
    verify: (bloc) {
      // THEN: 2 answers, 1 correct, 50% accuracy.
      expect(bloc.state.totalAnswered, 2);
      expect(bloc.state.totalCorrect, 1);
      expect(bloc.state.accuracyPercent, 50);
    },
  );

  blocTest<StatsBloc, StatsState>(
    'GIVEN existing progress WHEN StatsReset THEN everything is cleared',
    build: () => StatsBloc(progress: progress),
    act: (bloc) async {
      await progress.recordAnswer('a', true);
      bloc.add(const StatsReset());
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      // THEN: stats are back to zero.
      expect(bloc.state.totalAnswered, 0);
      expect(bloc.state.seenCount, 0);
      expect(bloc.state.bestExamScore, 0);
    },
  );
}
