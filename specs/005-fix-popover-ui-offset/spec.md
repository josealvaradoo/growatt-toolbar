# 005 Fix Popover UI Offset & Inner Border

## Problem

The Growatt Toolbar menu-bar popover currently displays an unexpected minimal border / inner card outline and an unnatural layout offset inside macOS's native `NSPopover` container:

1. **Nested Glass Background & Inner Specular Rim**: [`GrowattPopoverView.swift`](file:///Users/josealvarado/Dev/swift/growatt-toolbar/src/GrowattToolbarCore/Views/GrowattPopoverView.swift) applies `.background { popoverBackground }` with a `RoundedRectangle(cornerRadius: 24, style: .continuous).glassEffect(.regular, in: shape)`. However, `NSPopover` already provides its own window (`_NSPopoverWindow` with `NSPopoverFrame`) that hosts a full-bleed native `NSGlassView` (Liquid Glass on macOS 26) with standard window chrome, rounded corners, drop shadow, and arrow. Stacking `.glassEffect` inside `NSPopover` creates an inner glass card with a visible specular border outline along its perimeter.
2. **Offset & Inset Mismatch**: `NSPopoverFrame` automatically insets its hosted content view by approximately 13pt. Because the custom inner background is drawn on `NSHostingView` (sized at 280pt width), it floats 13pt inside the outer window with a fixed 24pt corner radius that does not match the popover window's geometry.
3. **Orphan Divider Line in Awaiting State**: In [`GrowattPopoverView.swift`](file:///Users/josealvarado/Dev/swift/growatt-toolbar/src/GrowattToolbarCore/Views/GrowattPopoverView.swift), `Divider()` is conditioned only on `freshness != .error`. When the app is in the `.awaiting` state (connecting / before first reading), `stateRow` is hidden (`EmptyView()`), leaving the hairline `Divider()` rendered at the very bottom edge of the view with nothing below it.
4. **Content Height Sizing**: [`StatusBarController.swift`](file:///Users/josealvarado/Dev/swift/growatt-toolbar/src/GrowattToolbarApp/StatusBarController.swift) hardcodes `popover.contentSize = NSSize(width: 280, height: 180)` while the intrinsic content height of `GrowattPopoverView` is ~142pt–151pt, contributing to vertical sizing discrepancies.

This violates [`DESIGN.md#L484`](file:///Users/josealvarado/Dev/swift/growatt-toolbar/DESIGN.md#L484) (*"Never stack glass on glass"*) and [`DESIGN.md#L529`](file:///Users/josealvarado/Dev/swift/growatt-toolbar/DESIGN.md#L529) (*"Sheets and popovers receive glass automatically in macOS 26 when you stop painting your own background"*).

## Goals

- Eliminate the unexpected inner border and specular rim inside the popover.
- Remove the redundant inner background so `NSPopover`'s native Liquid Glass surface serves as the single window material.
- Fix the orphan `Divider()` line during `.awaiting` state so separators only appear when adjacent content exists.
- Align popover content sizing and padding to provide a clean, native Control Center tile appearance.
- Ensure 100% compatibility across macOS 26 (Liquid Glass) and macOS 15 (Sequoia fallback), as well as Reduce Transparency modes.

## Non-Goals

- Changing the business logic, API client, or view model polling lifecycle.
- Redesigning the Settings / Onboarding window.
- Altering the status bar icon or percentage text formatting in `NSStatusItem`.

## User Stories

- As a macOS menu bar user, I want the Growatt status popover to appear as a seamless, native system popover without extraneous inner borders or outlines.
- As a user, I want the popover content to sit cleanly and flat on the native glass surface with consistent edge insets.
- As a user waiting for connection, I do not want to see stray separator lines floating at the bottom of the popover.

## Functional Requirements

- **FR-1**: Remove `.background { popoverBackground }` and `PopoverGeometry` from [`GrowattPopoverView.swift`](file:///Users/josealvarado/Dev/swift/growatt-toolbar/src/GrowattToolbarCore/Views/GrowattPopoverView.swift).
- **FR-2**: Render the popover content hierarchy directly on the native `NSPopover` surface without any inner card or nested glass plane.
- **FR-3**: Condition `Divider()` so that it only renders when `stateRow` is non-empty (`freshness != .awaiting && freshness != .error`).
- **FR-4**: Update [`StatusBarController.swift`](file:///Users/josealvarado/Dev/swift/growatt-toolbar/src/GrowattToolbarApp/StatusBarController.swift) to size the popover to the intrinsic content dimensions (~150pt height) rather than a rigid 180pt height.
- **FR-5**: Maintain `GrowattPopoverView_Previews` preview functionality.

## Acceptance Criteria (EARS)

### Ubiquitous
- The system shall render `GrowattPopoverView` without any secondary glass rim, inner border outline, or nested background container.
- The system shall display content flat on `NSPopover`'s native material.

### State-driven
- While `freshness == .awaiting`, the system shall render the hero placeholder, the battery indicator placeholder, and no trailing `Divider()`.
- While `freshness == .live` or `freshness == .stale`, the system shall render the hero metrics, battery bar, `Divider()`, and state row in vertical sequence.
- While `freshness == .error`, the system shall render `ErrorBannerView` with no battery bar or outer divider.
- While `accessibilityReduceTransparency` is enabled, the system shall rely on macOS's native popover opaque window styling.

### Unwanted Behavior
- If `stateRow` is empty, then the system shall not render an adjacent `Divider()`.
- If the view is displayed inside `NSPopover`, then the system shall not paint a custom `RoundedRectangle` glass shape behind the content.

## Non-Functional Requirements
- **Performance**: Zero overhead; eliminates redundant offscreen glass rendering pass.
- **Reliability**: `swift build` passes with 0 warnings and 0 errors.
