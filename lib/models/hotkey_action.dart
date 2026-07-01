/// Signature for a hotkey-bound domain action.
///
/// Using a function type keeps the seam between "hotkey was pressed" and
/// "what happens" explicit. The registry is a simple map from string id
/// to action; callers register their own actions.
typedef HotkeyActionCallback = void Function();

/// Registry of named hotkey actions.
///
/// The HotkeyManager only knows about this registry. It doesn't import
/// pages, controllers, or window_manager directly.
class HotkeyActionRegistry {
  final Map<String, HotkeyActionCallback> _actions = {};

  void register(String id, HotkeyActionCallback action) {
    _actions[id] = action;
  }

  HotkeyActionCallback? get(String id) => _actions[id];
}
