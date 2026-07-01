# Flip Clock — Domain Model

## Glossary

### WindowGeometry ([lib/geometry/window_geometry.dart](../blob/main/lib/geometry/window_geometry.dart))
Pure calculation module for window sizing. Takes `(showAppBar, pageExtraHeight)` → `Size`. Hides the arithmetic of adding title bar height and sub-page deltas. Deep: two parameters, one return value, all window math contained.

### ConfigPersistence ([lib/persistence/config_persistence.dart](../blob/main/lib/persistence/config_persistence.dart))
Adapter at the persistence seam. Loads and saves app config keys to `SharedPreferences`. Controller never touches storage directly. Per-field saver methods enable reactive `ever()` watchers in the controller.

### AppRouter ([lib/navigation/app_router.dart](../blob/main/lib/navigation/app_router.dart))
Thin navigation facade. Centralises transition type, duration, and page construction. All callers (HotkeyManager, AppContextMenu, TodoController) route through this module.

### HotkeyActionRegistry ([lib/models/hotkey_action.dart](../blob/main/lib/models/hotkey_action.dart))
Registry of named hotkey callbacks. HotkeyManager binds against this registry and does not import pages, controllers, or window_manager.

### ClockSizing ([lib/pages/main_page.dart](../blob/main/lib/pages/main_page.dart))
Pure function from `BoxConstraints` → `(digitSize, width, height)`. Extracted from duplicate `min()` calls in `_flipClock` and `_flipCountDownClock`.

### AppConfigController
Reactive state hub. Manages theme, mode, and hotkey config via GetX `Rx` fields. Delegates window sizing to `WindowGeometry`, persistence to `ConfigPersistence`. No longer contains inline window arithmetic or `isNotInMainPage` navigation signal.

### pageExtraHeight (`RxDouble`)
Replaces the old `isNotInMainPage` boolean flag. Communicates the actual pixel delta contributed by a sub-page. Set by TodoPage/SettingsPage on init, zeroed on return to MainPage.

### FlipWidget<T> ([lib/widget/flip_widget.dart](../blob/main/lib/widget/flip_widget.dart))
The deepest module. Generic animated flip panel. ~320 lines of animation logic behind a ~10-parameter constructor interface. Leave untouched — learn from it.

## Architecture Invariants

1. `WindowGeometry.sizeForPage()` is the sole source of window size computation.
2. `ConfigPersistence` is the sole adapter for `SharedPreferences` config keys.
3. `AppRouter` is the sole routing entry point.
4. `HotkeyActionRegistry` separates hotkey detection from domain action execution.
5. Pages set `pageExtraHeight` on init, zero it on dispose — never directly set a controller boolean.
