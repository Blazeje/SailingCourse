import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/quiz/services/progress_service.dart';

// ------------------------------ INTENTS (Events) -----------------------------

sealed class StatsEvent extends Equatable {
  const StatsEvent();
  @override
  List<Object?> get props => [];
}

class StatsStarted extends StatsEvent {
  const StatsStarted();
}

class StatsReset extends StatsEvent {
  const StatsReset();
}

// ------------------------------- STATE (State) -------------------------------

class StatsState extends Equatable {
  final int seenCount;
  final int masteredCount;
  final int totalAnswered;
  final int totalCorrect;
  final int bestExamScore;

  const StatsState({
    this.seenCount = 0,
    this.masteredCount = 0,
    this.totalAnswered = 0,
    this.totalCorrect = 0,
    this.bestExamScore = 0,
  });

  int get accuracyPercent =>
      totalAnswered == 0 ? 0 : (totalCorrect * 100 / totalAnswered).round();

  @override
  List<Object?> get props =>
      [seenCount, masteredCount, totalAnswered, totalCorrect, bestExamScore];
}

// ------------------------------- REDUCER (Bloc) ------------------------------

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final ProgressService progress;

  StatsBloc({required this.progress}) : super(const StatsState()) {
    on<StatsStarted>((_, emit) => emit(_snapshot()));
    on<StatsReset>((_, emit) async {
      await progress.resetAll();
      emit(_snapshot());
    });
  }

  StatsState _snapshot() => StatsState(
        seenCount: progress.seenCount,
        masteredCount: progress.masteredCount,
        totalAnswered: progress.totalAnswered,
        totalCorrect: progress.totalCorrect,
        bestExamScore: progress.bestExamScore,
      );
}
