
## 1.0.3
- feat: support optional `onRemoved` callback in `FloatingController` to notify when the overlay is removed. Specifically for the floating overlay is removed, the `onRemoved` callback will be called to notify the caller, allowing them to perform any necessary cleanup or state updates. This enhancement provides better control and feedback for managing the lifecycle of floating overlays in Flutter applications.

## 1.0.2

- break change: rename `FloatingController.custom` to `FloatingController.transition` to better reflect its purpose and usage. 
- break change: merge `FloatingController.route` and `FloatingController.overlay` into a single factory constructor 

## 1.0.1

- support optional transition builder for `FloatingController.overlay` and `RawOverlayConfig` to enable custom transition animations for overlays.

## 1.0.0

### Added
- Initial release of `simple_overlay_kit` package, providing a simple and flexible way to manage overlays in Flutter applications.
