import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../bloc/stats_bloc.dart';
import '../services/progress_service.dart';

/// Statistics screen (MVI): renders [StatsState].
class StatsScreen extends StatelessWidget {
  final ProgressService progress;
  final int totalCards;

  const StatsScreen({
    super.key,
    required this.progress,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatsBloc(progress: progress)..add(const StatsStarted()),
      child: _StatsView(totalCards: totalCards),
    );
  }
}

class _StatsView extends StatelessWidget {
  final int totalCards;

  const _StatsView({required this.totalCards});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.statistics)),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatTile(
                label: t.statSeen,
                value: t.fraction(state.seenCount, totalCards),
                icon: Icons.visibility,
              ),
              _StatTile(
                label: t.statMastered,
                value: t.fraction(state.masteredCount, totalCards),
                icon: Icons.workspace_premium,
              ),
              _StatTile(
                label: t.statAccuracy,
                value: t.accuracyValue(state.accuracyPercent,
                    state.totalCorrect, state.totalAnswered),
                icon: Icons.track_changes,
              ),
              _StatTile(
                label: t.statBestExam,
                value: t.percentValue(state.bestExamScore),
                icon: Icons.emoji_events,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(t.resetConfirmTitle),
                      content: Text(t.resetConfirmBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(t.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(t.reset),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<StatsBloc>().add(const StatsReset());
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(t.resetProgress),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
