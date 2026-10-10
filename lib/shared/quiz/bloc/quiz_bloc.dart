import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/quiz_card.dart';
import '../services/progress_service.dart';

enum QuizMode { learn, exam }

// ------------------------------ INTENTS (Events) -----------------------------

sealed class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

/// Start of the quiz.
class QuizStarted extends QuizEvent {
  const QuizStarted();
}

/// The user selected the answer at the given index.
class OptionSelected extends QuizEvent {
  final int index;
  const OptionSelected(this.index);
  @override
  List<Object?> get props => [index];
}

/// Advance to the next card (exam mode - the "Next" button).
class NextPressed extends QuizEvent {
  const NextPressed();
}

// ------------------------------- STATE (State) -------------------------------

class QuizState extends Equatable {
  final List<QuizCard> deck;
  final int index;
  final int score;
  final int? selected;
  final bool wrongOnThisCard;
  final bool locked;
  final bool finished;
  final QuizMode mode;

  const QuizState({
    required this.deck,
    required this.mode,
    this.index = 0,
    this.score = 0,
    this.selected,
    this.wrongOnThisCard = false,
    this.locked = false,
    this.finished = false,
  });

  QuizCard get card => deck[index];
  int get total => deck.length;
  bool get isExam => mode == QuizMode.exam;

  QuizState copyWith({
    int? index,
    int? score,
    int? selected,
    bool clearSelected = false,
    bool? wrongOnThisCard,
    bool? locked,
    bool? finished,
  }) {
    return QuizState(
      deck: deck,
      mode: mode,
      index: index ?? this.index,
      score: score ?? this.score,
      selected: clearSelected ? null : (selected ?? this.selected),
      wrongOnThisCard: wrongOnThisCard ?? this.wrongOnThisCard,
      locked: locked ?? this.locked,
      finished: finished ?? this.finished,
    );
  }

  @override
  List<Object?> get props =>
      [index, score, selected, wrongOnThisCard, locked, finished, mode];
}

// ------------------------------- REDUCER (Bloc) ------------------------------

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final ProgressService progress;

  QuizBloc({
    required this.progress,
    required List<QuizCard> deck,
    required QuizMode mode,
  }) : super(QuizState(
          deck: deck.map((c) => c.shuffledOptions()).toList(),
          mode: mode,
        )) {
    on<QuizStarted>((_, _) {});
    on<OptionSelected>(_onOptionSelected);
    on<NextPressed>(_onNextPressed);
  }

  Future<void> _onOptionSelected(
    OptionSelected event,
    Emitter<QuizState> emit,
  ) async {
    if (state.locked) return;
    final card = state.card;
    final correct = event.index == card.correctIndex;

    if (state.isExam) {
      // Exam: only record the selection (changeable), without revealing
      // correctness. Advancing happens via the "Next" button.
      emit(state.copyWith(selected: event.index));
      return;
    }

    // Learn mode.
    if (correct) {
      final gained = !state.wrongOnThisCard;
      // Lock the card and reveal the explanation. The view shows a dialog and
      // advancing happens only when the user confirms ("Next").
      emit(state.copyWith(
        selected: event.index,
        locked: true,
        score: gained ? state.score + 1 : state.score,
      ));
      await progress.recordAnswer(card.id, gained);
    } else {
      emit(state.copyWith(selected: event.index, wrongOnThisCard: true));
    }
  }

  Future<void> _onNextPressed(
    NextPressed event,
    Emitter<QuizState> emit,
  ) async {
    if (state.isExam) {
      if (state.selected == null) return;
      final card = state.card;
      final correct = state.selected == card.correctIndex;
      await progress.recordAnswer(card.id, correct);
      emit(state.copyWith(
        score: correct ? state.score + 1 : state.score,
      ));
      _advance(emit);
      return;
    }

    // Learn mode: advance only after a card has been answered
    // correctly (locked) and the explanation has been acknowledged.
    if (!state.locked) return;
    _advance(emit);
  }

  void _advance(Emitter<QuizState> emit) {
    if (state.index + 1 >= state.deck.length) {
      if (state.isExam) {
        final percent =
            state.total == 0 ? 0 : (state.score * 100 / state.total).round();
        progress.saveBestExamScore(percent);
      }
      emit(state.copyWith(finished: true, locked: true));
    } else {
      emit(state.copyWith(
        index: state.index + 1,
        clearSelected: true,
        wrongOnThisCard: false,
        locked: false,
      ));
    }
  }
}
