import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../bloc/home_bloc.dart';
import '../../../shared/quiz/bloc/quiz_bloc.dart';
import '../../../shared/quiz/data/card_repository.dart';
import '../../../shared/quiz/models/quiz_card.dart';
import '../../../shared/quiz/services/progress_service.dart';
import '../../../shared/quiz/screens/quiz_screen.dart';
import 'stats_screen.dart';

/// MPDM module home screen (MVI): renders [HomeState].
class HomeScreen extends StatelessWidget {
  final CardRepository repository;
  final ProgressService progress;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(repository: repository, progress: progress)
        ..add(const HomeStarted()),
      child: _HomeView(progress: progress),
    );
  }
}

class _HomeView extends StatelessWidget {
  final ProgressService progress;

  const _HomeView({required this.progress});

  Future<void> _startQuiz(
    BuildContext context,
    String title,
    List<QuizCard> deck,
    QuizMode mode,
  ) async {
    if (deck.isEmpty) return;
    final homeBloc = context.read<HomeBloc>();
    final shuffled = List<QuizCard>.from(deck)..shuffle();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: title,
          deck: shuffled,
          mode: mode,
          progress: progress,
        ),
      ),
    );
    homeBloc.add(const HomeRefreshed());
  }

  void _learnSheet(BuildContext context, HomeState state) {
    final homeContext = context;
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.chooseLearnScope,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(t.scopeAll(state.all.length)),
              onTap: () {
                Navigator.pop(ctx);
                _startQuiz(homeContext, t.learn, state.all, QuizMode.learn);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: Text(t.scopeLights(state.lightsCount)),
              onTap: () {
                Navigator.pop(ctx);
                _startQuiz(homeContext, t.learnLights,
                    state.byCategory(CardCategory.lights), QuizMode.learn);
              },
            ),
            ListTile(
              leading: const Icon(Icons.change_history),
              title: Text(t.scopeShapes(state.shapesCount)),
              onTap: () {
                Navigator.pop(ctx);
                _startQuiz(homeContext, t.learnShapes,
                    state.byCategory(CardCategory.shapes), QuizMode.learn);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(t.moduleMpdmTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart),
                tooltip: t.statistics,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StatsScreen(
                        progress: progress,
                        totalCards: state.all.length,
                      ),
                    ),
                  );
                  if (context.mounted) {
                    context.read<HomeBloc>().add(const HomeRefreshed());
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MenuCard(
                icon: Icons.school,
                title: t.learn,
                subtitle: t.learnSubtitle,
                onTap: () => _learnSheet(context, state),
              ),
              _MenuCard(
                icon: Icons.replay,
                title: t.reviews,
                subtitle: state.dueCount > 0
                    ? t.dueToday(state.dueCount)
                    : t.noReviews,
                enabled: state.dueCount > 0,
                onTap: () {
                  final deck = context.read<HomeBloc>().dueDeck();
                  _startQuiz(context, t.reviewsShort, deck, QuizMode.srs);
                },
              ),
              _MenuCard(
                icon: Icons.assignment_turned_in,
                title: t.exam,
                subtitle: t.examSubtitle(state.bestExamScore),
                onTap: () =>
                    _startQuiz(context, t.exam, state.all, QuizMode.exam),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Icon(icon, size: 36),
        title: Text(title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
