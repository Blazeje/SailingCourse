import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../modules.dart';
import '../quiz/data/card_repository.dart';
import '../quiz/services/progress_service.dart';

// ------------------------------ INTENTS (Events) -----------------------------

sealed class GlobalStatsEvent extends Equatable {
  const GlobalStatsEvent();
  @override
  List<Object?> get props => [];
}

class GlobalStatsStarted extends GlobalStatsEvent {
  const GlobalStatsStarted();
}

class GlobalStatsReset extends GlobalStatsEvent {
  const GlobalStatsReset();
}

// ------------------------------- STATE (State) -------------------------------

/// Aggregated progress of a single module.
class ModuleStat extends Equatable {
  final String namespace;
  final int seenCount;
  final int totalCards;
  final int totalAnswered;
  final int totalCorrect;
  final int bestExamScore;

  const ModuleStat({
    required this.namespace,
    required this.seenCount,
    required this.totalCards,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.bestExamScore,
  });

  @override
  List<Object?> get props => [
        namespace,
        seenCount,
        totalCards,
        totalAnswered,
        totalCorrect,
        bestExamScore,
      ];
}

class GlobalStatsState extends Equatable {
  final bool loading;
  final List<ModuleStat> modules;

  const GlobalStatsState({
    this.loading = true,
    this.modules = const [],
  });

  int get seenCount => modules.fold(0, (s, m) => s + m.seenCount);
  int get totalCards => modules.fold(0, (s, m) => s + m.totalCards);
  int get totalAnswered => modules.fold(0, (s, m) => s + m.totalAnswered);
  int get totalCorrect => modules.fold(0, (s, m) => s + m.totalCorrect);

  int get accuracyPercent =>
      totalAnswered == 0 ? 0 : (totalCorrect * 100 / totalAnswered).round();

  @override
  List<Object?> get props => [loading, modules];
}

// ------------------------------- REDUCER (Bloc) ------------------------------

/// Aggregates learning progress across every [CourseModule] into one view.
class GlobalStatsBloc extends Bloc<GlobalStatsEvent, GlobalStatsState> {
  final List<CourseModule> modules;
  final String languageCode;

  GlobalStatsBloc({
    required this.modules,
    required this.languageCode,
  }) : super(const GlobalStatsState()) {
    on<GlobalStatsStarted>((_, emit) async => emit(await _snapshot()));
    on<GlobalStatsReset>((_, emit) async {
      for (final m in modules) {
        final progress = ProgressService(namespace: m.namespace);
        await progress.init();
        await progress.resetAll();
      }
      emit(await _snapshot());
    });
  }

  Future<GlobalStatsState> _snapshot() async {
    final stats = <ModuleStat>[];
    for (final m in modules) {
      final progress = ProgressService(namespace: m.namespace);
      await progress.init();
      final cards = await CardRepository(
        assetModule: m.assetModule,
        languageCode: languageCode,
      ).loadCards();
      stats.add(ModuleStat(
        namespace: m.namespace,
        seenCount: progress.seenCount,
        totalCards: cards.length,
        totalAnswered: progress.totalAnswered,
        totalCorrect: progress.totalCorrect,
        bestExamScore: progress.bestExamScore,
      ));
    }
    return GlobalStatsState(loading: false, modules: stats);
  }
}
