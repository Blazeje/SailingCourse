import 'package:flutter/material.dart';

import '../../shared/quiz/data/card_repository.dart';
import '../../shared/quiz/services/progress_service.dart';
import 'screens/meteo_home_screen.dart';

/// Standalone entry point of the meteorology module.
/// Covers marine weather basics (Beaufort scale, pressure and fronts, clouds,
/// land and sea breezes, wind veering/backing). Uses a dedicated progress
/// namespace and asset folder so it stays independent from the other modules.
class MeteoModule extends StatefulWidget {
  const MeteoModule({super.key});

  @override
  State<MeteoModule> createState() => _MeteoModuleState();
}

class _MeteoModuleState extends State<MeteoModule> {
  final CardRepository _repository = CardRepository(assetModule: 'meteo');
  final ProgressService _progress = ProgressService(namespace: 'meteo');
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
        return MeteoHomeScreen(
          key: ValueKey(lang),
          repository: _repository,
          progress: _progress,
        );
      },
    );
  }
}
