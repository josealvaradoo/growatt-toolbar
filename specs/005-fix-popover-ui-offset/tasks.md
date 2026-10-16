# 005 Fix Popover UI Offset & Inner Border — Tasks

Each task is atomic, independently verifiable, and formatted for conventional commits.

---

## T-001: Remove redundant inner glass background and guard divider in `GrowattPopoverView`

- **Objective**: Remove the redundant `.background { popoverBackground }` modifier, `popoverBackground` view builder, `PopoverGeometry` enum, and unused `@Environment(\.accessibilityReduceTransparency)` property from `GrowattPopoverView`. Guard `Divider()` so it only renders when `stateRow` is actively rendered.
- **Depends on**: None
- **Inputs**:
  - `specs/005-fix-popover-ui-offset/spec.md`
  - `specs/005-fix-popover-ui-offset/plan.md`
  - `src/GrowattToolbarCore/Views/GrowattPopoverView.swift`
- **Outputs**:
  - `src/GrowattToolbarCore/Views/GrowattPopoverView.swift`
- **Acceptance check**:
  - [ ] No `popoverBackground` or `PopoverGeometry` exists in `GrowattPopoverView.swift`.
  - [ ] `Divider()` is not rendered in `.awaiting` state.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
- **Commit prefix**: `fix(ui): remove redundant inner popover background and guard divider`

---

## T-002: Harmonize popover content size in `StatusBarController`

- **Objective**: Update `popover.contentSize` in `StatusBarController.setupPopover()` from `height: 180` to `height: 150` to match the intrinsic height of `GrowattPopoverView`.
- **Depends on**: T-001
- **Inputs**:
  - `src/GrowattToolbarApp/StatusBarController.swift`
- **Outputs**:
  - `src/GrowattToolbarApp/StatusBarController.swift`
- **Acceptance check**:
  - [ ] `popover.contentSize` has `width: 280, height: 150`.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
- **Commit prefix**: `fix(ui): adjust popover content size to match intrinsic height`

---

## T-003: Verify layout rendering across freshness states

- **Objective**: Run render verification to ensure zero specular inner rim, zero nested border, and correct alignment in `.awaiting`, `.live`, and `.error` states.
- **Depends on**: T-001, T-002
- **Inputs**:
  - `.build/debug/GrowattToolbarApp`
- **Outputs**:
  - Verification artifacts in scratch
- **Acceptance check**:
  - [ ] Popover renders flat directly on `NSPopover` glass with no inner border or offset artifact.
  - [ ] No orphan divider in awaiting state.
- **Commit prefix**: `docs: add spec and verification for popover ui offset fix`
