import 'package:flutter/material.dart';

import '../../shared/quiz/data/card_repository.dart';
import '../../shared/quiz/services/progress_service.dart';
import 'screens/navigation_home_screen.dart';

/// Standalone entry point of the navigation module.
/// Covers navigation calculations (compass corrections, bearings & fixes,
/// dead reckoning, set & drift). Uses a dedicated progress namespace and asset
/// folder so it stays independent from the other modules.
class NavigationModule extends StatefulWidget {
  const NavigationModule({super.key});

  @override
  State<NavigationModule> createState() => _NavigationModuleState();
}

class _NavigationModuleState extends State<NavigationModule> {
  final CardRepository _repository = CardRepository(assetModule: 'navigation');
  final ProgressService _progress = ProgressService(namespace: 'navigation');
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
        return NavigationHomeScreen(
          key: ValueKey(lang),
          repository: _repository,
          progress: _progress,
        );
      },
    );
  }
}
