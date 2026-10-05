import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sailing_course/modules/mpdm/bloc/quiz_bloc.dart';
import 'package:sailing_course/modules/mpdm/services/progress_service.dart';

import 'helpers.dart';

void main() {
  late ProgressService progress;

  setUp(() async {
    // GIVEN: a clean progress store before each test.
    SharedPreferences.setMockInitialValues({});
    progress = ProgressService();
    await progress.init();
  });

  group('QuizBloc - exam mode', () {
    blocTest<QuizBloc, QuizState>(
      'GIVEN exam WHEN an option is selected THEN it becomes selected without locking',
      build: () => QuizBloc(
        progress: progress,
        deck: [buildCard()],
        mode: QuizMode.exam,
      ),
      act: (bloc) => bloc.add(const OptionSelected(1)),
      expect: () => [
        isA<QuizState>()
            .having((s) => s.selected, 'selected', 1)
            .having((s) => s.locked, 'locked', false)
            .having((s) => s.finished, 'finished', false),
      ],
    );

    blocTest<QuizBloc, QuizState>(
      'GIVEN exam WHEN Next is pressed without a selection THEN nothing happens',
      build: () => QuizBloc(
        progress: progress,
        deck: [buildCard()],
        mode: QuizMode.exam,
      ),
      act: (bloc) => bloc.add(const NextPressed()),
      expect: () => const <QuizState>[],
    );

    blocTest<QuizBloc, QuizState>(
      'GIVEN exam WHEN correct answer then Next THEN score increases and quiz finishes',
      build: () => QuizBloc(
        progress: progress,
        deck: [buildCard()],
        mode: QuizMode.exam,
      ),
      act: (bloc) {
        bloc.add(OptionSelected(bloc.state.card.correctIndex));
        bloc.add(const NextPressed());
      },
      verify: (bloc) {
        // THEN: a point is scored and the quiz is finished.
        expect(bloc.state.score, 1);
        expect(bloc.state.finished, true);
      },
    );

    blocTest<QuizBloc, QuizState>(
      'GIVEN exam WHEN wrong answer then Next THEN no point but quiz finishes',
      build: () => QuizBloc(
        progress: progress,
        deck: [buildCard()],
        mode: QuizMode.exam,
      ),
      act: (bloc) {
        final wrong = (bloc.state.card.correctIndex + 1) % 3;
        bloc.add(OptionSelected(wrong));
        bloc.add(const NextPressed());
      },
      verify: (bloc) {
        // THEN: zero points, but the quiz is finished.
        expect(bloc.state.score, 0);
        expect(bloc.state.finished, true);
      },
    );
  });

  group('QuizBloc - learn mode', () {
    blocTest<QuizBloc, QuizState>(
      'GIVEN learn WHEN correct answer THEN score increases and advances to next card',
      build: () => QuizBloc(
        progress: progress,
        deck: [buildCard(id: 'a'), buildCard(id: 'b')],
        mode: QuizMode.learn,
      ),
      act: (bloc) => bloc.add(OptionSelected(bloc.state.card.correctIndex)),
      wait: const Duration(milliseconds: 1200),
      verify: (bloc) {
        // THEN: a point is scored and we are on the second card.
        expect(bloc.state.score, 1);
        expect(bloc.state.index, 1);
        expect(bloc.state.finished, false);
        expect(bloc.state.selected, isNull);
      },
    );

    blocTest<QuizBloc, QuizState>(
      'GIVEN learn WHEN wrong answer THEN no point, mistake flagged, no advance',
      build: () => QuizBloc(
        progress: progress,
        deck: [buildCard()],
        mode: QuizMode.learn,
      ),
      act: (bloc) =>
          bloc.add(OptionSelected((bloc.state.card.correctIndex + 1) % 3)),
      verify: (bloc) {
        // THEN: mistake flagged, no point and no advance.
        expect(bloc.state.wrongOnThisCard, true);
        expect(bloc.state.score, 0);
        expect(bloc.state.index, 0);
        expect(bloc.state.locked, false);
      },
    );
  });
}
