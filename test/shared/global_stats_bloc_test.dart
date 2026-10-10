import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sailing_course/shared/modules.dart';
import 'package:sailing_course/shared/quiz/services/progress_service.dart';
import 'package:sailing_course/shared/stats/global_stats_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // GIVEN: a clean progress store.
    SharedPreferences.setMockInitialValues({});
  });

  blocTest<GlobalStatsBloc, GlobalStatsState>(
    'GIVEN a clean store WHEN GlobalStatsStarted THEN every module loads with its total and zero progress',
    build: () =>
        GlobalStatsBloc(modules: kCourseModules, languageCode: 'en'),
    act: (bloc) => bloc.add(const GlobalStatsStarted()),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      // THEN: all modules are present, totals summed, nothing seen yet.
      expect(bloc.state.loading, false);
      expect(bloc.state.modules.length, kCourseModules.length);
      expect(bloc.state.totalCards, 30 + 12 + 14 + 12);
      expect(bloc.state.seenCount, 0);
      expect(bloc.state.totalAnswered, 0);
      expect(bloc.state.accuracyPercent, 0);
    },
  );

  blocTest<GlobalStatsBloc, GlobalStatsState>(
    'GIVEN answers recorded in two modules WHEN GlobalStatsStarted THEN counters aggregate across modules',
    build: () =>
        GlobalStatsBloc(modules: kCourseModules, languageCode: 'en'),
    act: (bloc) async {
      // GIVEN: progress recorded in the mpdm and rescue namespaces.
      final mpdm = ProgressService(namespace: 'mpdm');
      await mpdm.init();
      await mpdm.recordAnswer('n01', true);
      await mpdm.recordAnswer('n02', false);
      final rescue = ProgressService(namespace: 'rescue');
      await rescue.init();
      await rescue.recordAnswer('r01', true);
      // WHEN: the global stats are requested.
      bloc.add(const GlobalStatsStarted());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      // THEN: aggregates cover both modules (3 answers, 2 correct, 3 seen).
      expect(bloc.state.seenCount, 3);
      expect(bloc.state.totalAnswered, 3);
      expect(bloc.state.totalCorrect, 2);
      expect(bloc.state.accuracyPercent, 67);
    },
  );

  blocTest<GlobalStatsBloc, GlobalStatsState>(
    'GIVEN existing progress WHEN GlobalStatsReset THEN every module is cleared',
    build: () =>
        GlobalStatsBloc(modules: kCourseModules, languageCode: 'en'),
    act: (bloc) async {
      final mpdm = ProgressService(namespace: 'mpdm');
      await mpdm.init();
      await mpdm.recordAnswer('n01', true);
      await mpdm.saveBestExamScore(80);
      bloc.add(const GlobalStatsReset());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      // THEN: all progress is wiped out.
      expect(bloc.state.seenCount, 0);
      expect(bloc.state.totalAnswered, 0);
      for (final m in bloc.state.modules) {
        expect(m.bestExamScore, 0);
      }
    },
  );
}
