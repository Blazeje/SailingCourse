import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sailing_course/modules/mpdm/bloc/home_bloc.dart';
import 'package:sailing_course/modules/mpdm/data/card_repository.dart';
import 'package:sailing_course/modules/mpdm/models/quiz_card.dart';
import 'package:sailing_course/modules/mpdm/services/progress_service.dart';

import 'helpers.dart';

/// Fake repository returning in-memory cards (no asset loading).
class FakeCardRepository extends CardRepository {
  final List<QuizCard> cards;
  FakeCardRepository(this.cards);

  @override
  Future<List<QuizCard>> loadCards() async => cards;
}

void main() {
  late ProgressService progress;
  late FakeCardRepository repository;

  setUp(() async {
    // GIVEN: a clean store and a repository with two cards.
    SharedPreferences.setMockInitialValues({});
    progress = ProgressService();
    await progress.init();
    repository = FakeCardRepository([
      buildCard(id: 'a', category: CardCategory.lights),
      buildCard(id: 'b', category: CardCategory.shapes),
    ]);
  });

  blocTest<HomeBloc, HomeState>(
    'GIVEN startup WHEN HomeStarted THEN loading finishes and every card is new (due)',
    build: () => HomeBloc(repository: repository, progress: progress),
    act: (bloc) => bloc.add(const HomeStarted()),
    verify: (bloc) {
      // THEN: data loaded, all cards are due (new).
      expect(bloc.state.loading, false);
      expect(bloc.state.all.length, 2);
      expect(bloc.state.lightsCount, 1);
      expect(bloc.state.shapesCount, 1);
      expect(bloc.state.dueCount, 2);
    },
  );

  blocTest<HomeBloc, HomeState>(
    'GIVEN a card was answered WHEN HomeRefreshed THEN the due count decreases',
    build: () => HomeBloc(repository: repository, progress: progress),
    act: (bloc) async {
      bloc.add(const HomeStarted());
      await Future.delayed(const Duration(milliseconds: 10));
      // WHEN: card 'a' is answered correctly (schedules it in the future).
      await progress.recordAnswer('a', true);
      bloc.add(const HomeRefreshed());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      // THEN: only one card remains due.
      expect(bloc.state.dueCount, 1);
    },
  );
}
