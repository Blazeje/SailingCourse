import 'package:flutter/material.dart';
import 'data/card_repository.dart';
import 'services/progress_service.dart';
import 'screens/home_screen.dart';

/// Standalone entry point of the MPDM module.
/// Initializes its own dependencies (card repository + progress)
/// and shows the module home screen.
class MpdmModule extends StatefulWidget {
  const MpdmModule({super.key});

  @override
  State<MpdmModule> createState() => _MpdmModuleState();
}

class _MpdmModuleState extends State<MpdmModule> {
  final CardRepository _repository = CardRepository();
  final ProgressService _progress = ProgressService();
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
        return HomeScreen(
          key: ValueKey(lang),
          repository: _repository,
          progress: _progress,
        );
      },
    );
  }
}
