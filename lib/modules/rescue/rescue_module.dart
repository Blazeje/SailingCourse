import 'package:flutter/material.dart';

import '../../shared/quiz/data/card_repository.dart';
import '../../shared/quiz/services/progress_service.dart';
import 'screens/rescue_home_screen.dart';

/// Standalone entry point of the rescue & safety module.
/// Initializes its own dependencies (card repository + progress) and shows the
/// module home screen. Uses a dedicated progress namespace and asset folder so
/// it stays independent from other modules.
class RescueModule extends StatefulWidget {
  const RescueModule({super.key});

  @override
  State<RescueModule> createState() => _RescueModuleState();
}

class _RescueModuleState extends State<RescueModule> {
  final CardRepository _repository = CardRepository(assetModule: 'rescue');
  final ProgressService _progress = ProgressService(namespace: 'rescue');
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = _progress.init();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    _repository.languageCode = lang;
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return RescueHomeScreen(
          key: ValueKey(lang),
          repository: _repository,
          progress: _progress,
        );
      },
    );
  }
}
