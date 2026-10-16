# 005 Fix Popover UI Offset & Inner Border — Technical Plan

## Architecture Decisions

### Decision 1: Remove Redundant Inner Glass Background from `GrowattPopoverView`
- **Context**: In macOS AppKit, `NSPopover` hosts its content inside an `_NSPopoverWindow` managed by `NSPopoverFrame`. On macOS 26, `NSPopoverFrame` automatically renders an `NSGlassView` spanning the whole window boundary, arrow included.
- **Problem**: In `GrowattPopoverView.swift`, drawing `.background { popoverBackground }` with a 24pt corner radius `RoundedRectangle` and `.glassEffect(.regular, in: shape)` creates a secondary glass plate. The system generates specular highlights on that shape's edge, presenting as an unwanted minimal border offset by 13pt from the window boundary.
- **Resolution**: Drop `popoverBackground`, `PopoverGeometry`, and the `@Environment(\.accessibilityReduceTransparency)` reference from `GrowattPopoverView.swift`. The content will render flat against the window's native glass surface, adhering to `DESIGN.md` (*"never stack glass on glass"*, *"sheets and popovers receive glass automatically"*).

### Decision 2: Guard `Divider()` Visibility Against Empty `stateRow`
- **Context**: In `GrowattPopoverView.swift`, `stateRow` is only shown when `viewModel.freshness != .awaiting && viewModel.freshness != .error`.
- **Problem**: `Divider()` was placed unconditionally under `if viewModel.freshness != .error`, meaning during `.awaiting` state it rendered directly beneath `batteryBarSection` with nothing below it.
- **Resolution**: Move `Divider()` inside the condition that guards `stateRow`, so the separator is only drawn when separating two visible sections:
  ```swift
  if viewModel.freshness != .awaiting && viewModel.freshness != .error {
      Divider()
      stateRow
  }
  ```

### Decision 3: Harmonize Popover Size in `StatusBarController`
- **Context**: `StatusBarController.setupPopover()` configured `popover.contentSize = NSSize(width: 280, height: 180)`.
- **Resolution**: Update `popover.contentSize` to `NSSize(width: 280, height: 150)` to closely match the natural content height (~142–151pt), avoiding excess vertical space or unwanted stretching.

## File Modifications

| File | Target Changes |
|---|---|
| `src/GrowattToolbarCore/Views/GrowattPopoverView.swift` | Remove `popoverBackground`, remove `PopoverGeometry`, remove unused `@Environment(\.accessibilityReduceTransparency)`, guard `Divider()` when `stateRow` is active. |
| `src/GrowattToolbarApp/StatusBarController.swift` | Adjust `popover.contentSize` from `height: 180` to `height: 150`. |

## Verification Plan

1. **Compilation**: `swift build` passes with zero errors and zero warnings.
2. **Visual & Layout Inspection**: Render popover across `.awaiting`, `.live`, and `.error` states via headless AppKit harness; verify zero nested specular borders, zero orphan dividers, and seamless integration with `NSPopoverFrame`.
3. **Manual Validation**: Notify user to test the UI visually on their active menu bar.
