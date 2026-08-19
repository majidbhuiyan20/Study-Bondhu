// Compatibility shim for the Flutter `gen-l10n` generated
// `AppLocalizations` class. Re-exports the generated type and adds the
// project-wide conveniences:
//   - `context.l10n` getter (delegates to `AppLocalizations.of(context)`)
//   - `l10n.isBangla` (derived from `localeName` / `locale.languageCode`)
//   - camelCase forwarders via `l10n_compat.dart`
//   - `loadBundles()` no-op so callers can keep awaiting it.
import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';


export '../l10n/app_localizations.dart';
export 'l10n_compat.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsBangla on AppLocalizations {
  bool get isBangla => localeName.startsWith('bn');
}

/// `flutter gen-l10n` produces a `SynchronousFuture`-backed delegate, so the
/// bundles are already available the moment the first widget tree mounts.
/// This helper is kept as a no-op so callers can `await` it the same way
/// they would if bundles needed an explicit asset load.
Future<void> loadBundles() async {}