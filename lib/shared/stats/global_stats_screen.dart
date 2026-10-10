import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../modules.dart';
import 'global_stats_bloc.dart';

/// Global statistics screen (MVI): aggregates progress across every module.
class GlobalStatsScreen extends StatelessWidget {
  const GlobalStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      create: (_) => GlobalStatsBloc(
        modules: kCourseModules,
        languageCode: lang,
      )..add(const GlobalStatsStarted()),
      child: const _GlobalStatsView(),
    );
  }
}

class _GlobalStatsView extends StatelessWidget {
  const _GlobalStatsView();

  CourseModule? _moduleFor(String namespace) {
    for (final m in kCourseModules) {
      if (m.namespace == namespace) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.statistics)),
      body: BlocBuilder<GlobalStatsBloc, GlobalStatsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(title: t.statOverall),
              _StatTile(
                label: t.statSeen,
                value: t.fraction(state.seenCount, state.totalCards),
                icon: Icons.visibility,
              ),
              _StatTile(
                label: t.statAccuracy,
                value: t.accuracyValue(state.accuracyPercent,
                    state.totalCorrect, state.totalAnswered),
                icon: Icons.track_changes,
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: t.statByModule),
              for (final m in state.modules)
                _ModuleStatCard(
                  title: _moduleFor(m.namespace)?.title(t) ?? m.namespace,
                  seen: t.fraction(m.seenCount, m.totalCards),
                  accuracy: m.totalAnswered == 0
                      ? t.percentValue(0)
                      : t.percentValue(
                          (m.totalCorrect * 100 / m.totalAnswered).round()),
                  bestExam: t.percentValue(m.bestExamScore),
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
                    context
                        .read<GlobalStatsBloc>()
                        .add(const GlobalStatsReset());
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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

class _ModuleStatCard extends StatelessWidget {
  final String title;
  final String seen;
  final String accuracy;
  final String bestExam;

  const _ModuleStatCard({
    required this.title,
    required this.seen,
    required this.accuracy,
    required this.bestExam,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _row(context, Icons.visibility, t.statSeen, seen),
            _row(context, Icons.track_changes, t.statAccuracy, accuracy),
            _row(context, Icons.emoji_events, t.statBestExam, bestExam),
          ],
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
