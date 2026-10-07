import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/quiz/bloc/quiz_bloc.dart';
import '../../../shared/quiz/data/card_repository.dart';
import '../../../shared/quiz/models/quiz_card.dart';
import '../../../shared/quiz/screens/quiz_screen.dart';
import '../../../shared/quiz/services/progress_service.dart';

/// Rescue module home screen. Offers two study modes (learn and exam) over a
/// single deck of text-only knowledge cards.
class RescueHomeScreen extends StatelessWidget {
  final CardRepository repository;
  final ProgressService progress;

  const RescueHomeScreen({
    super.key,
    required this.repository,
    required this.progress,
  });

  Future<void> _startQuiz(
    BuildContext context,
    String title,
    List<QuizCard> deck,
    QuizMode mode,
  ) async {
    if (deck.isEmpty) return;
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
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.moduleRescueTitle)),
      body: FutureBuilder<List<QuizCard>>(
        future: repository.loadCards(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cards = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MenuCard(
                icon: Icons.school,
                title: t.learn,
                subtitle: t.learnSubtitle,
                onTap: () =>
                    _startQuiz(context, t.learn, cards, QuizMode.learn),
              ),
              _MenuCard(
                icon: Icons.assignment_turned_in,
                title: t.exam,
                subtitle: t.examSubtitle(progress.bestExamScore),
                onTap: () =>
                    _startQuiz(context, t.exam, cards, QuizMode.exam),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
        onTap: onTap,
      ),
    );
  }
}
