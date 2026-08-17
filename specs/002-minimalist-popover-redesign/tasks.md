# 002 Minimalist Popover Redesign — Tasks

Each task is atomic, independently shippable, and verifiable. Execute in order.
Stop and update the spec if a task reveals new requirements. Work on branch
`feature/minimalist-popover-redesign` and commit after each task with a
conventional message referencing `specs/002-minimalist-popover-redesign/` (see
`git-workflow` skill).

---

## T-001: Update `GlassTokens` for the compact Control Center tile scale

- **Objective**: Update the design tokens to the new compact scale before
  touching views, so every subsequent task references the new values. Change
  `Numeric.hero` from 44pt to 28pt; update `Padding.popover` from 18 to 16;
  add a compact `Spacing` value if needed; remove the now-unused `Radius.card`,
  `Radius.tile`, `Padding.card`, and `Padding.tile` tokens **only if** no
  remaining consumer exists after T-006 (defer the deletion to T-006 to avoid
  breaking the build mid-stream — for now, leave them and add the new compact
  values).
- **Depends on**: (none)
- **Inputs**: `specs/002-minimalist-popover-redesign/spec.md` (Target State
  table); `plan.md` (Decision D-3); `src/GrowattToolbarCore/Views/Components/GlassTokens.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/Components/GlassTokens.swift`
  (`Numeric.hero` → 28pt; `Padding.popover` → 16; doc comments updated to
  describe the Control Center tile scale and the flat-surface pattern).
- **Acceptance check**:
  - [ ] `GlassTokens.Numeric.hero` is `.system(size: 28, weight: .bold, design: .rounded)`.
  - [ ] `GlassTokens.Padding.popover` is `16`.
  - [ ] Doc comments describe the compact Control Center tile rationale.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): update GlassTokens for compact Control Center tile scale` (refs spec).

---

## T-002: Rewrite `BatteryIndicatorView` as a thin neutral bar

- **Objective**: Replace the 38pt green/orange gradient battery bar with a
  thin (~10–12pt) neutral track and neutral fill. Remove the battery terminal
  nub (too small at this scale). Remove the `gradientColors` computed property
  and the `state` parameter's color usage (keep the `state` parameter only if
  the fill needs it; otherwise drop it). Use a neutral system fill
  (`.primary.opacity(0.15)` track, `.primary.opacity(0.6)` fill, or
  `Color(nsColor: .systemFill)` / `.secondarySystemFill`) so the bar respects
  appearance and contrast automatically. Keep the `levelPercentage` animation
  gated on `accessibilityReduceMotion`. Keep the `.accessibilityElement` +
  `.accessibilityLabel` (the bar is decorative; the parent hero carries the
  VoiceOver label).
- **Depends on**: T-001
- **Inputs**: `plan.md` (Decision D-2); `src/GrowattToolbarCore/Views/Components/BatteryIndicatorView.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/Components/BatteryIndicatorView.swift`
  (rewritten: ~10–12pt height, neutral fill, no nub, no gradient, no green/orange).
- **Acceptance check**:
  - [ ] No `.green` or `.orange` reference in the file.
  - [ ] Bar height is ~10–12pt; no terminal nub `RoundedRectangle`.
  - [ ] Fill and track use neutral system colors (no hardcoded RGB).
  - [ ] `accessibilityReduceMotion` still gates the fill animation.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): rewrite battery bar as thin neutral gauge` (refs spec).

---

## T-003: Shrink `BatteryIndicatorPlaceholder` to match the new bar

- **Objective**: Update the `.awaiting`-state shimmer placeholder to match the
  new ~10–12pt bar height and remove the terminal nub. Keep the shimmer
  animation gated on `accessibilityReduceMotion`. Keep `.accessibilityHidden(true)`.
- **Depends on**: T-002
- **Inputs**: `src/GrowattToolbarCore/Views/Components/BatteryIndicatorPlaceholder.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/Components/BatteryIndicatorPlaceholder.swift`
  (height ~10–12pt, no nub, shimmer preserved).
- **Acceptance check**:
  - [ ] Placeholder height matches `BatteryIndicatorView` (~10–12pt).
  - [ ] No terminal nub `RoundedRectangle`.
  - [ ] Shimmer still gated on `accessibilityReduceMotion`.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): shrink battery placeholder to match neutral bar` (refs spec).

---

## T-004: Rewrite `PowerFlowBadgeView` as a flat accent label + dot

- **Objective**: Replace the tinted-glass capsule badge with a compact flat
  label + dot that sits directly on the glass shell (no `.glassEffect`, no
  capsule background). The dot and label use `Color.accentColor` for the state
  signal (charging / discharging). Remove the `@Environment(reduceTransparency)`
  property (no glass background to fall back from). Keep the
  `.accessibilityElement` + `.accessibilityLabel`. Use `.footnote` or
  `.caption` for the label so it reads as secondary metadata, not a headline.
- **Depends on**: T-001
- **Inputs**: `plan.md` (Decision D-2); `src/GrowattToolbarCore/Views/Components/PowerFlowBadgeView.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/Components/PowerFlowBadgeView.swift`
  (flat accent dot + label; no glass, no capsule, no green/orange).
- **Acceptance check**:
  - [ ] No `.glassEffect` or `Capsule()` background in the file.
  - [ ] Dot and label use `Color.accentColor` (not `.green`/`.orange`).
  - [ ] No `@Environment(\.accessibilityReduceTransparency)` property.
  - [ ] `.accessibilityLabel` preserved.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): flatten state badge to accent label and dot` (refs spec).

---

## T-005: Collapse `FreshnessIndicatorView` into a compact inline indicator

- **Objective**: Remove the standalone capsule background from the freshness
  pill. Reduce it to a compact inline dot + secondary text (`.caption` or
  `.footnote`) intended to sit inside the state row. Keep the four-state
  rendering (`.awaiting` / `.live` / `.stale` / `.error`) and the pulse on
  `.awaiting` (Reduce-Motion-gated). The freshness dot **may** use semantic
  colors (green/amber/red) because freshness is a trust axis, distinct from
  the state axis (see plan D-2 nuance) — document this distinction in a comment.
- **Depends on**: T-001
- **Inputs**: `plan.md` (Decision D-4, D-2 nuance); `src/GrowattToolbarCore/Views/Components/FreshnessIndicatorView.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/Components/FreshnessIndicatorView.swift`
  (no capsule background; compact dot + text; four states preserved).
- **Acceptance check**:
  - [ ] No `Capsule()` background fill in the file.
  - [ ] Four freshness states still render distinct dot + text.
  - [ ] `.awaiting` pulse still gated on `accessibilityReduceMotion`.
  - [ ] Comment documents the freshness-vs-state color-axis distinction.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): collapse freshness pill to inline indicator` (refs spec).

---

## T-006: Rewrite `GrowattPopoverView` as a flat 280pt two-column Control Center tile

- **Objective**: Full body rewrite of the popover. Remove the title header,
  the `metricsRow` (separate Home Load tile), and all opaque card backgrounds
  (`heroBackground`, `controlBackgroundColor`). New compact flat layout:
  (1) **two-column hero row** — left column: tiny "Battery" label (`.caption`,
  `.secondary`) + `~28pt` bold rounded percentage; right column: tiny "Home Load"
  label (`.caption`, `.secondary`) + `~28pt` bold rounded (or `.title2.bold()`)
  kW value with `monospacedDigit()`. The two columns split the 280pt width
  evenly (minus padding). (2) thin neutral `BatteryIndicatorView` (or
  `BatteryIndicatorPlaceholder` in `.awaiting`). (3) optional hairline
  `Divider()`. (4) state row — `PowerFlowBadgeView` (accent dot + state label,
  moved here from the hero) + `FreshnessIndicatorView` (inline freshness dot +
  text) on the left, `RefreshButton` on the right. Set `.frame(width: 280)`.
  Use `GlassTokens.Padding.popover` (16) and `Spacing.md` (12) for the rhythm.
  Render content directly on the `.glassEffect(.regular, in:)` shell (keep the
  `popoverBackground` from spec 001; remove `heroBackground`). Handle the four
  freshness states: `.awaiting` (placeholder bar + "···" in both hero columns +
  "Connecting…"), `.live`/`.stale` (two-column hero + bar + inline freshness),
  `.error` (compact `ErrorBannerView` replaces the hero). Keep all
  accessibility labels and the `accessibilityReduceTransparency` /
  `accessibilityReduceMotion` environments. The kW value reads
  `viewModel.status.outputPowerKW` formatted to one decimal place + " kW".
- **Depends on**: T-002, T-003, T-004, T-005
- **Inputs**: `plan.md` (Target layout wireframe, Decisions D-1, D-4, D-5);
  `spec.md` (Target State, FR-1..FR-10, OQ-4); `src/GrowattToolbarCore/Views/GrowattPopoverView.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/GrowattPopoverView.swift`
  (rewritten: 280pt, flat, two-column hero, no header, no metrics row, no cards).
- **Acceptance check**:
  - [ ] `.frame(width: 280)` (not 360).
  - [ ] No `header` view with "Growatt Inverter" title.
  - [ ] No `metricsRow` / `PowerMetricTileView` call.
  - [ ] No `heroBackground` / `controlBackgroundColor` reference.
  - [ ] Hero row is two-column: battery % (left) + home load kW (right), each
    with a tiny `.caption` `.secondary` label.
  - [ ] kW value uses `monospacedDigit()` and reads `viewModel.status.outputPowerKW`.
  - [ ] State row contains `PowerFlowBadgeView` (accent dot + label) +
    `FreshnessIndicatorView` (inline dot + text) + `RefreshButton`.
  - [ ] `popoverBackground` still uses `.glassEffect(.regular, in:)` on macOS 26+
    and `.ultraThinMaterial` on macOS 15 (spec 001 unchanged).
  - [ ] Four freshness states render (`.awaiting`/`.live`/`.stale`/`.error`);
    `.awaiting` shows "···" in both hero columns.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `feat(ui): redesign popover as flat 280pt two-column Control Center tile` (refs spec).

---

## T-007: Rewrite `ErrorBannerView` as a compact flat two-line indicator

- **Objective**: Remove the opaque card background from the error banner.
  Render a compact two-line flat indicator: icon + "Can't reach inverter"
  headline + "Last reading Nm ago" (or "No previous reading") subtitle, with
  the inline `RefreshButton`. Use system semantic colors (`.primary` for the
  headline, `.secondary` for the subtitle, `.orange` for the icon only — the
  error icon is a trust/destructive semantic, not a state signal). Keep the
  `relativeString(for:)` static helper (single source of truth for time copy).
  Keep the `.accessibilityElement` + `.accessibilityLabel`.
- **Depends on**: T-006
- **Inputs**: `plan.md` (Decision D-4); `src/GrowattToolbarCore/Views/Components/ErrorBannerView.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/Components/ErrorBannerView.swift`
  (no card background; compact two-line flat indicator; helper preserved).
- **Acceptance check**:
  - [ ] No `controlBackgroundColor` / card background in the file.
  - [ ] Icon + headline + subtitle render as a compact flat block.
  - [ ] `relativeString(for:)` static helper preserved.
  - [ ] `.accessibilityLabel` preserved.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): flatten error banner to compact two-line indicator` (refs spec).

---

## T-008: Shrink `RefreshButton` to compact control size

- **Objective**: Change `RefreshButton` from `controlSize(.regular)` (44pt) to
  `controlSize(.small)` (or `.extraSmall` if `.small` still reads too large at
  280pt). Keep `ButtonStyle.glass` on macOS 26+ and `.bordered` on macOS 15.
  Keep the `accessibilityReduceMotion`-gated spinner and the `.accessibilityLabel("Refresh")`
  and the `.help(…)` tooltip. Verify the icon glyph (`arrow.clockwise`) is
  legible at the smaller size.
- **Depends on**: T-006
- **Inputs**: `src/GrowattToolbarCore/Views/Components/RefreshButton.swift`.
- **Outputs**: `src/GrowattToolbarCore/Views/Components/RefreshButton.swift`
  (`controlSize(.small)`; glyph legible; behavior unchanged).
- **Acceptance check**:
  - [ ] `controlSize(.small)` (or `.extraSmall`) applied.
  - [ ] `ButtonStyle.glass` / `.bordered` branching unchanged.
  - [ ] Spinner still gated on `accessibilityReduceMotion`.
  - [ ] `.accessibilityLabel("Refresh")` and `.help(…)` preserved.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): shrink refresh button to compact control size` (refs spec).

---

## T-009: Delete `PowerMetricTileView` (home load now renders inline in the hero)

- **Objective**: Delete `src/GrowattToolbarCore/Views/Components/PowerMetricTileView.swift`
  in full — its sole call site (the `metricsRow`) was removed in T-006, and the
  home consumption value now renders inline in the two-column hero row (T-006).
  The component is no longer needed. Also remove the now-unused
  `GlassTokens.Radius.tile` and `GlassTokens.Padding.tile` tokens if no other
  consumer references them (verify with `grep` first).
- **Depends on**: T-006
- **Inputs**: `plan.md` (Decision D-5); `src/GrowattToolbarCore/Views/Components/PowerMetricTileView.swift`;
  `src/GrowattToolbarCore/Views/Components/GlassTokens.swift`.
- **Outputs**: `PowerMetricTileView.swift` deleted; `GlassTokens` cleaned of
  unused `tile` tokens (if confirmed unused).
- **Acceptance check**:
  - [ ] `grep -R "PowerMetricTileView" src/` returns zero hits.
  - [ ] `grep -R "Radius.tile\|Padding.tile" src/` returns zero hits (or only
    the token definitions, which are removed).
  - [ ] The home consumption value is still rendered (in the hero right column,
    per T-006) — verify `outputPowerKW` is read in `GrowattPopoverView`.
  - [ ] `swift build` passes with 0 errors, 0 warnings (proves no dangling refs).
  - [ ] Committed as `refactor(ui): delete unused PowerMetricTileView and tile tokens` (refs spec).

---

## T-010: Update `StatusBarController.contentSize` to 280pt width

- **Objective**: Change `popover.contentSize` from `NSSize(width: 360, height: 210)`
  to `NSSize(width: 280, height: <compact height>)`. Determine the height by
  building and measuring the new compact content, or set a height that fits
  the hero + bar + state row + refresh with the 16pt padding (estimate ~150–170pt;
  confirm at the manual visual pass). If `NSHostingController` intrinsic sizing
  is feasible (it often is for SwiftUI content), set the height to a reasonable
  default and let the hosting controller size to fit; otherwise use the
  measured value. Keep `popover.behavior = .transient` and `popover.animates = true`.
- **Depends on**: T-006
- **Inputs**: `spec.md` (FR-1); `src/GrowattToolbarApp/StatusBarController.swift`.
- **Outputs**: `src/GrowattToolbarApp/StatusBarController.swift`
  (`contentSize` width 280; height adjusted; comment updated).
- **Acceptance check**:
  - [ ] `contentSize.width` is 280 (not 360).
  - [ ] `contentSize.height` fits the new compact content (no clipping).
  - [ ] `grep -R "360" src/GrowattToolbarApp/StatusBarController.swift` returns zero hits.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `feat(ui): set popover content size to 280pt compact width` (refs spec).

---

## T-011: Update `DESIGN.md` with the flat-surface popover pattern

- **Objective**: Amend `DESIGN.md` to document the new flat-surface Control
  Center tile popover pattern: 280pt width, flat content on the Regular glass
  shell (no inner cards), neutral palette + accent for the single state signal,
  compact ~28pt hero, thin neutral bar, inline freshness. Update the
  `popover-mac` component token (`width: 320` → note the 280pt compact
  variant for menu-bar utility popovers). Add a Do-rule for the flat-surface
  pattern and amend any Do/Don't that implied inner cards are required.
- **Depends on**: T-010
- **Inputs**: `plan.md` (Decisions D-1, D-2); `DESIGN.md`.
- **Outputs**: `DESIGN.md` (flat-surface pattern documented; popover-mac token
  updated; Do/Don't amended).
- **Acceptance check**:
  - [ ] `DESIGN.md` documents the flat-surface popover pattern (glass shell,
    flat content, dividers/spacing for separation, no inner cards).
  - [ ] `popover-mac` token notes the 280pt compact menu-bar variant.
  - [ ] No Do-rule implies inner cards are required for legibility.
  - [ ] `swift build` passes with 0 errors, 0 warnings (docs change; build hygiene).
  - [ ] Committed as `docs: document flat-surface Control Center tile popover pattern` (refs spec).

---

## T-012: Append the new version block to `CHANGELOG.md`

- **Objective**: Add a new `## <version> (2026-07-30)` block with `### Features`
  and `### Refactor` sections describing the minimalist redesign, per the
  `changelog` skill and the existing file's style. Determine the next version
  number from the current top of `CHANGELOG.md` (increment the minor or patch
  per the magnitude of the change — a UI redesign is a minor bump).
- **Depends on**: T-011
- **Inputs**: `spec.md` (Summary, Target State); `CHANGELOG.md` (style of prior
  entries).
- **Outputs**: `CHANGELOG.md` (new dated version block at the top).
- **Acceptance check**:
  - [ ] New dated version block at the top, before the previous latest.
  - [ ] `### Features` section covers: 280pt compact width, flat single-surface
    layout, Control Center tile aesthetic, accent-only state signal.
  - [ ] `### Refactor` section covers: removed title header, removed Home Load
    tile, removed opaque inner cards, removed green/orange gradients, deleted
    `PowerMetricTileView`, shrank hero/bar/refresh.
  - [ ] Committed as `docs: changelog <version> minimalist popover redesign` (refs spec).

---

## T-013: Full verification pass

- **Objective**: Run every gate from the plan's Test Strategy and confirm the
  spec's Target State and EARS criteria are fully met.
- **Depends on**: T-012
- **Inputs**: `plan.md` (Test Strategy); `spec.md` (Target State, EARS).
- **Outputs**: verification results noted in the PR description; no code changes
  expected.
- **Acceptance check**:
  - [ ] `swift build` — 0 errors, 0 warnings.
  - [ ] `grep -R "controlBackgroundColor" src/GrowattToolbarCore/Views/` → zero hits (maps to FR-7).
  - [ ] `grep -R "\.green\|\.orange" src/GrowattToolbarCore/Views/` → zero hits in popover views (maps to FR-9; the model's `accentColor` is the only allowed reference and is no longer read by views).
  - [ ] `grep -R "PowerMetricTileView" src/` → zero hits (maps to FR-3).
  - [ ] `grep -R "frame(width: 360)" src/` → zero hits; `280` is the only popover width (maps to FR-1).
  - [ ] `grep -R "outputPowerKW" src/GrowattToolbarCore/Views/GrowattPopoverView.swift` → at least one hit (home consumption is rendered in the hero, maps to FR-3, FR-4).
  - [ ] `swift run GrowattToolbarApp`, open popover: width visibly ~280pt; compact height; no title; no separate Home Load tile; no cards; two-column hero (battery % + home load kW); thin neutral bar; accent state label + dot in the state row; inline freshness; compact refresh — maps to EARS Ubiquitous #1–#5, Event-driven #1.
  - [ ] All four freshness states render correctly (`.awaiting` shimmer + "Connecting…"; `.live`; `.stale` "Updated Nm ago"; `.error` compact two-line indicator) — maps to EARS Event-driven #2–#5, FR-8.
  - [ ] Dark and Light appearances both legible via system semantic colors — maps to EARS State-driven #3, FR-9.
  - [ ] Reduce Transparency ON → opaque shell, flat content legible; OFF → glass — maps to EARS State-driven #1, FR-12.
  - [ ] Reduce Motion ON → shimmer/animation/spinner disabled; OFF → animated — maps to EARS State-driven #2, FR-12.
  - [ ] Dynamic Type at largest size: no overflow beyond 280pt — maps to EARS Unwanted #1.
  - [ ] VoiceOver reads hero, state, freshness, refresh coherently — maps to FR-12.
  - [ ] macOS 15 code path verified by inspection: `#available` fallbacks untouched — maps to FR-11.

---

## Verification (after all tasks)

- [ ] Every EARS acceptance criterion from spec.md is covered by a passing check above.
- [ ] `swift build` passes with 0 errors, 0 warnings.
- [ ] Manual visual smoke test (T-013) passes in full.
- [ ] `git-workflow` skill conventions followed: `feature/minimalist-popover-redesign` branch, conventional commits, each referencing `specs/002-minimalist-popover-redesign/`.
- [ ] PR description references `specs/002-minimalist-popover-redesign/` and includes before/after screenshots (see `create-pull-request` skill).