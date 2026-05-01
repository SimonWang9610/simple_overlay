import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/simple_overlay_kit.dart';
import 'package:simple_overlay_kit/src/panel/widgets/panel_cache_key_store.dart';

final class PanelShower {
  final PanelController controller;
  final Map<Object, GlobalKey> _cacheKeys = {};

  PanelShower(this.controller) {
    controller.addListener(_onPanelControllerUpdate);
  }

  FloatingController? _floating;

  void ensurePanelOnstage(BuildContext context, {Panel? panel}) {
    if (panel != null && panel.maintainState) {
      _cacheKeys.putIfAbsent(
        panel.id,
        () => GlobalKey(debugLabel: '$hashCode@${panel.id}'),
      );
    }

    if (_floating != null && _floating!.value) return;

    final CapturedThemes themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(context, rootNavigator: false).context,
    );

    _floating ??= FloatingController.transition(
      useRootNavigator: false,
      builder: (_, __, ___) => themes.wrap(
        PanelCacheKeyStore(
          cacheKeys: _cacheKeys,
          child: FloatingPanel(controller: controller),
        ),
      ),
    );

    _floating!.show(context);
  }

  void _onPanelControllerUpdate() {
    if (!controller.hasPanels) {
      _floating?.dispose();
      _floating = null;
    }
  }

  void dispose() {
    controller.removeListener(_onPanelControllerUpdate);
    _floating?.dispose();
    _floating = null;
    _cacheKeys.clear();
  }
}
