import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_cubit.dart';
import 'modules/mpdm/mpdm_module.dart';
import 'modules/rescue/rescue_module.dart';

void main() {
  runApp(const SailingCourseApp());
}

class SailingCourseApp extends StatelessWidget {
  const SailingCourseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocaleCubit()..load(),
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E3A5F),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E3A5F),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: const CourseHomeScreen(),
          );
        },
      ),
    );
  }
}

/// Course hub screen. Lists the thematic modules.
class CourseHomeScreen extends StatelessWidget {
  const CourseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: const [_LanguageMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ModuleCard(
            icon: Icons.sailing,
            title: t.moduleMpdmTitle,
            subtitle: t.moduleMpdmSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MpdmModule()),
            ),
          ),
          _ModuleCard(
            icon: Icons.health_and_safety,
            title: t.moduleRescueTitle,
            subtitle: t.moduleRescueSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RescueModule()),
            ),
          ),
          _ModuleCard(
            icon: Icons.anchor,
            title: t.moduleKnotsTitle,
            subtitle: t.comingSoon,
            enabled: false,
          ),
          _ModuleCard(
            icon: Icons.map,
            title: t.moduleNavigationTitle,
            subtitle: t.comingSoon,
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu();

  Widget _flag(String languageCode) => CountryFlag.fromLanguageCode(
        languageCode,
        theme: const ImageTheme(
          width: 28,
          height: 20,
          shape: RoundedRectangle(3),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Flag follows the user's explicit choice, or the resolved locale when
    // "system default" is active.
    final selected = context.watch<LocaleCubit>().state?.languageCode;
    final activeCode = selected ?? Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      icon: _flag(activeCode),
      tooltip: t.language,
      initialValue: selected ?? 'system',
      onSelected: (value) {
        final cubit = context.read<LocaleCubit>();
        cubit.setLocale(value == 'system' ? null : Locale(value));
      },
      itemBuilder: (context) => [
        _flagItem('pl', 'Polski'),
        _flagItem('en', 'English'),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'system',
          child: Row(
            children: [
              const Icon(Icons.public, size: 24),
              const SizedBox(width: 12),
              Text(t.systemDefault),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _flagItem(String code, String label) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          _flag(code),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, size: 36),
        title: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: enabled
            ? const Icon(Icons.chevron_right)
            : const Icon(Icons.lock_outline),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
