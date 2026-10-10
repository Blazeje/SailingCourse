import 'package:flutter/material.dart';

import '../../shared/quiz/data/card_repository.dart';
import '../../shared/quiz/services/progress_service.dart';
import 'screens/locja_home_screen.dart';

/// Standalone entry point of the pilotage ("Locja") module.
/// Uses a dedicated progress namespace and asset folder so it stays independent
/// from the other modules.
class LocjaModule extends StatefulWidget {
  const LocjaModule({super.key});

  @override
  State<LocjaModule> createState() => _LocjaModuleState();
}

class _LocjaModuleState extends State<LocjaModule> {
  final CardRepository _repository = CardRepository(assetModule: 'locja');
  final ProgressService _progress = ProgressService(namespace: 'locja');
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
        return LocjaHomeScreen(
          key: ValueKey(lang),
          repository: _repository,
          progress: _progress,
        );
      },
    );
  }
}
