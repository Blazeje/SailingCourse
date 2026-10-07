import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../bloc/quiz_bloc.dart';

/// Pure result view (saving the record is handled by QuizBloc).
class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final QuizMode mode;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final percent = total == 0 ? 0 : (score * 100 / total).round();
    final isExam = mode == QuizMode.exam;
    final passed = percent >= 75;

    return Scaffold(
      appBar: AppBar(title: Text(t.result)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isExam
                    ? (passed ? Icons.verified : Icons.cancel)
                    : Icons.check_circle,
                size: 96,
                color: isExam
                    ? (passed ? Colors.green : Colors.redAccent)
                    : Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                '$score / $total',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                t.percentValue(percent),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                isExam
                    ? (passed ? t.examPassed : t.examFailed)
                    : t.correctFirstTry,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home),
                label: Text(t.backToMenu),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
