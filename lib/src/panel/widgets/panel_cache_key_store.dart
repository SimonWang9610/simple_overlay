import 'package:flutter/widgets.dart';

typedef CacheKeyGetter = GlobalKey Function(Object panelId);

GlobalKey _defaultCacheKeyGetter(Object panelId) => GlobalKey(debugLabel: "cache_key_$panelId");

/// A store for cache keys of panels.
/// This is used to preserve the state of panel widgets during reparenting a panel,
/// like dragging.
///
/// If no key is found for a panel, the store will return null,
/// and the panel widget may be recreated (re-mounted) from scratch when needed.
class PanelCacheKeyStore extends InheritedWidget {
  /// A map from panel id to cache key.
  final Map<Object, GlobalKey> cacheKeys;

  final bool autoGenerateCacheKeys;

  /// When [autoGenerateCacheKeys] is true and there is no existing cache key for an item,
  /// the store will generate a new cache key using [getKey] and store it in [cacheKeys].
  final CacheKeyGetter getKey;

  const PanelCacheKeyStore({
    super.key,
    required this.cacheKeys,
    required super.child,
    this.getKey = _defaultCacheKeyGetter,
    this.autoGenerateCacheKeys = false,
  });

  @override
  bool updateShouldNotify(covariant PanelCacheKeyStore oldWidget) {
    return cacheKeys != oldWidget.cacheKeys ||
        getKey != oldWidget.getKey ||
        autoGenerateCacheKeys != oldWidget.autoGenerateCacheKeys;
  }

  static PanelCacheKeyStore? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PanelCacheKeyStore>();
  }

  static GlobalKey? getCacheKeyForPanel(BuildContext context, Object panelId) {
    final store = of(context);

    if (store == null) {
      return null;
    }

    if (store.autoGenerateCacheKeys) {
      return store.cacheKeys.putIfAbsent(panelId, () => store.getKey(panelId));
    }

    return store.cacheKeys[panelId];
  }
}
