# simple_overlay_kit

`simple_overlay_kit` is a focused Flutter package for showing temporary UI layers with a **single, consistent API**.

Use it when you want one abstraction for:
- raw `OverlayEntry`
- `OverlayRoute`
- transition-based routes (including dialog-like routes)

---

## Why this package

Many overlay packages are optimized for one style only (entry-only, dialog-only, or highly opinionated UI widgets).

`simple_overlay_kit` is intentionally low-level and composable:
- **Unified controller model** across overlay entry, route, and transition route.
- **Consistent barrier configuration** (`BarrierConfig`) for route-based overlays.
- **Lifecycle-aware state** via `ValueListenable<bool>` (`controller.value`).
- **No global singleton required**: use controller instances or `FloatingManager` per feature/screen.
- **Navigator/overlay flexibility** with root navigator and root overlay options.

---

## Key features

- ✅ One API surface (`FloatingController`) for multiple overlay mechanisms.
- ✅ Optional dim barrier with color, dismissible behavior, semantics label, and curve.
- ✅ Overlay route and transition route support with custom builders.
- ✅ `FloatingManager` for replacing currently showing overlays safely.
- ✅ Value-based config objects (`==` and `hashCode` implemented).
- ✅ Test-covered behavior for barrier/no-barrier and controller lifecycle scenarios.

---

## Comparison (typical alternatives on pub.dev)

| Capability | `simple_overlay_kit` | Many overlay/dialog packages |
| --- | --- | --- |
| Single controller API for entry + route + transition route | ✅ | ❌ Often split APIs |
| Shared barrier config model across route types | ✅ | ⚠️ Inconsistent or per-widget |
| Raw low-level composition (bring your own UI) | ✅ | ⚠️ Often widget/opinionated |
| Replace current overlay via manager abstraction | ✅ | ❌ Usually manual |
| Works with root navigator / root overlay options | ✅ | ⚠️ Varies |

If your app needs predictable overlay orchestration without adopting a full UI framework, this package is a strong fit.

---

## Installation

Add dependency:

```yaml
dependencies:
	simple_overlay_kit: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## Quick start

### 1) Show an `OverlayEntry`

```dart
final controller = FloatingController.overlay(
	builder: (_) => const Center(
		child: Text('OverlayEntry content'),
	),
);

controller.show(context);
// ...
controller.hide();
```

### 2) Show an `OverlayRoute` with barrier

```dart
final controller = FloatingController.route(
	barrierConfig: const BarrierConfig(
		label: 'Dismiss overlay',
		dismissible: true,
	),
	builder: (_) => const Center(
		child: Text('OverlayRoute content'),
	),
);

controller.show(context);
```

### 3) Show a custom transition route

```dart
final controller = FloatingController.custom(
	barrierConfig: const BarrierConfig(label: 'Custom transition barrier'),
	transitionDuration: const Duration(milliseconds: 220),
	builder: (context, animation, secondaryAnimation) {
		return FadeTransition(
			opacity: animation,
			child: const Center(child: Text('Transition content')),
		);
	},
);

await controller.show(context);
```

### 4) Manage overlays with `FloatingManager`

```dart
final manager = FloatingManager();

await manager.show(
	context,
	const RawOverlayConfig(
		builder: _toastBuilder,
	),
);

await manager.hide();
```

```dart
Widget _toastBuilder(BuildContext context) {
	return const Align(
		alignment: Alignment.bottomCenter,
		child: Padding(
			padding: EdgeInsets.all(16),
			child: Text('Saved'),
		),
	);
}
```

---

## API overview

### Controllers

- `FloatingController.overlay(...)`
- `FloatingController.route(...)`
- `FloatingController.custom(...)`
- `FloatingController.dialog(...)`
- `FloatingController.withConfig(...)`

### Configs

- `RawOverlayConfig`
- `OverlayRouteConfig`
- `SimpleTransitionRouteConfig`
- `DialogRouteConfig`
- `BarrierConfig`

### Manager

- `FloatingManager.show(context, config)`
- `FloatingManager.hide()`
- `FloatingManager.isShowing`

---

## Notes

- For transition routes, `show` completes after forward transition completes.
- For route-based overlays, pop/system back updates controller showing state automatically.
- Barrier is optional for route and transition route flows.

---

## Example

See the runnable example app in `example/`.

---

## Contributing

Issues and PRs are welcome. If you report a bug, include:
- Flutter version
- minimal reproduction
- expected vs actual behavior
