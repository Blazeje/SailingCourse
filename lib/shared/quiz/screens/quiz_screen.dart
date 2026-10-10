import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../bloc/quiz_bloc.dart';
import '../models/quiz_card.dart';
import '../services/progress_service.dart';
import '../widgets/scene_view.dart';
import 'result_screen.dart';

/// Quiz view (MVI): renders [QuizState] and dispatches intents to [QuizBloc].
class QuizScreen extends StatelessWidget {
  final String title;
  final List<QuizCard> deck;
  final QuizMode mode;
  final ProgressService progress;
  final ScenePainterBuilder? sceneBuilder;

  const QuizScreen({
    super.key,
    required this.title,
    required this.deck,
    required this.mode,
    required this.progress,
    this.sceneBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(progress: progress, deck: deck, mode: mode)
        ..add(const QuizStarted()),
      child: _QuizView(title: title, sceneBuilder: sceneBuilder),
    );
  }
}

class _QuizView extends StatelessWidget {
  final String title;
  final ScenePainterBuilder? sceneBuilder;
  static const _labels = ['A', 'B', 'C'];

  const _QuizView({required this.title, this.sceneBuilder});

  Color _buttonColor(QuizState s, int i) {
    final card = s.card;
    if (s.isExam) {
      // Exam: only highlight the selected option (without revealing).
      if (i == s.selected) return const Color(0xFF1E88E5);
      return const Color(0xFF37475A);
    }
    if (i == s.selected && i == card.correctIndex) {
      return const Color(0xFF2E7D32);
    }
    if (i == s.selected && i != card.correctIndex) {
      return const Color(0xFFC62828);
    }
    if (s.wrongOnThisCard && i == card.correctIndex) {
      return const Color(0xFF2E7D32);
    }
    return const Color(0xFF37475A);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocConsumer<QuizBloc, QuizState>(
      listenWhen: (prev, curr) =>
          (!prev.finished && curr.finished) ||
          (!prev.locked && curr.locked && curr.mode != QuizMode.exam),
      listener: (context, state) {
        if (state.finished) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                score: state.score,
                total: state.total,
                mode: state.mode,
              ),
            ),
          );
          return;
        }
        // Learn / review: a correct answer locks the card. Reveal the
        // explanation in a dialog and advance only after confirmation.
        _showExplanationDialog(context, state);
      },
      builder: (context, state) {
        final card = state.card;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: (state.index + 1) / state.total,
                minHeight: 4,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.cardCounter(state.index + 1, state.total),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  if (card.hasScene) ...[
                    SceneView(card: card, painterBuilder: sceneBuilder),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    card.question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(card.options.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonColor(state, i),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            alignment: Alignment.centerLeft,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: state.locked
                              ? null
                              : () => context
                                  .read<QuizBloc>()
                                  .add(OptionSelected(i)),
                          child: Text(
                            '${_labels[i]}.  ${card.options[i]}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (state.isExam) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: state.selected == null
                            ? null
                            : () => context
                                .read<QuizBloc>()
                                .add(const NextPressed()),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(state.index + 1 >= state.total
                            ? t.finish
                            : t.next),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showExplanationDialog(
    BuildContext context,
    QuizState state,
  ) async {
    final t = AppLocalizations.of(context);
    final card = state.card;
    final isLast = state.index + 1 >= state.total;
    final body = card.explanation.isNotEmpty
        ? card.explanation
        : card.options[card.correctIndex];

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          title: Text(t.correctTitle),
          content: SingleChildScrollView(child: Text(body)),
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: Icon(isLast ? Icons.flag : Icons.arrow_forward),
              label: Text(isLast ? t.finish : t.next),
            ),
          ],
        );
      },
    );

    if (context.mounted) {
      context.read<QuizBloc>().add(const NextPressed());
    }
  }
}
