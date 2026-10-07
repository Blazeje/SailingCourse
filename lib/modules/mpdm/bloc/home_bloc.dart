import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/quiz/data/card_repository.dart';
import '../../../shared/quiz/models/quiz_card.dart';
import '../../../shared/quiz/services/progress_service.dart';

// ------------------------------ INTENTS (Events) -----------------------------

sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

/// Initial load of the module data.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Refresh of the counters (e.g. after returning from a quiz).
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

// ------------------------------- STATE (State) -------------------------------

class HomeState extends Equatable {
  final bool loading;
  final List<QuizCard> all;
  final int dueCount;
  final int bestExamScore;

  const HomeState({
    this.loading = true,
    this.all = const [],
    this.dueCount = 0,
    this.bestExamScore = 0,
  });

  int get lightsCount =>
      all.where((c) => c.category == CardCategory.lights).length;
  int get shapesCount =>
      all.where((c) => c.category == CardCategory.shapes).length;

  List<QuizCard> byCategory(CardCategory? cat) =>
      cat == null ? all : all.where((c) => c.category == cat).toList();

  HomeState copyWith({
    bool? loading,
    List<QuizCard>? all,
    int? dueCount,
    int? bestExamScore,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      all: all ?? this.all,
      dueCount: dueCount ?? this.dueCount,
      bestExamScore: bestExamScore ?? this.bestExamScore,
    );
  }

  @override
  List<Object?> get props => [loading, all, dueCount, bestExamScore];
}

// ------------------------------- REDUCER (Bloc) ------------------------------

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CardRepository repository;
  final ProgressService progress;

  HomeBloc({required this.repository, required this.progress})
      : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final cards = await repository.loadCards();
    emit(state.copyWith(
      loading: false,
      all: cards,
      dueCount: _dueCount(cards),
      bestExamScore: progress.bestExamScore,
    ));
  }

  void _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      dueCount: _dueCount(state.all),
      bestExamScore: progress.bestExamScore,
    ));
  }

  int _dueCount(List<QuizCard> cards) =>
      progress.dueCount(cards.map((c) => c.id).toList());

  List<QuizCard> dueDeck() {
    final dueIds = progress.dueCardIds(state.all.map((c) => c.id).toList()).toSet();
    return state.all.where((c) => dueIds.contains(c.id)).toList();
  }
}
