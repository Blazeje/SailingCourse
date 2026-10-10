import '../l10n/app_localizations.dart';

/// Descriptor of a thematic course module, used as the single source of truth
/// for cross-module features such as the global statistics screen.
class CourseModule {
  /// Progress storage namespace (see [ProgressService]).
  final String namespace;

  /// Asset folder holding the module's card files (`assets/<assetModule>/`).
  final String assetModule;

  /// Localized display name of the module.
  final String Function(AppLocalizations) title;

  const CourseModule({
    required this.namespace,
    required this.assetModule,
    required this.title,
  });
}

/// All modules that store learning progress, in display order.
final List<CourseModule> kCourseModules = [
  CourseModule(
    namespace: 'mpdm',
    assetModule: 'mpdm',
    title: (t) => t.moduleMpdmTitle,
  ),
  CourseModule(
    namespace: 'rescue',
    assetModule: 'rescue',
    title: (t) => t.moduleRescueTitle,
  ),
  CourseModule(
    namespace: 'locja',
    assetModule: 'locja',
    title: (t) => t.moduleLocjaTitle,
  ),
];
