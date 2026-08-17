# 002 Minimalist Popover Redesign

## Summary

The Growatt Toolbar popover is currently **360pt wide** with a **44pt display
hero number**, a **38pt battery bar**, a **separate Home Load metric tile**, a
**title header** ("Growatt Inverter"), a **freshness pill**, and a **refresh
button** — all sitting on **opaque inner cards** (`controlBackgroundColor`)
inside a Liquid Glass shell, with **green/orange gradient** state colors. The
result reads as a small dashboard, not a native macOS Tahoe 26 menu-bar popover.
The user finds it "huge and large," which breaks the macOS Tahoe 26 style guide.

This spec defines the target end state: a **subtle, delicate, minimalist
popover** calibrated against the **macOS Tahoe 26 Control Center tile** aesthetic
— the densest, most restrained native Apple popover pattern. The redesign
applies **radical minimalism** (strip to essentials), a **280pt** target width,
a **fully neutral color palette** driven by system semantic colors plus the
user's accent as the single state signal, and a **flat single glass surface**
with no opaque inner cards. The **home consumption** (`outputPowerKW`) is
preserved as the right column of a **two-column hero row** — battery percentage
on the left, home load kW on the right, each with a tiny secondary label — so
both core metrics survive the compression without adding a vertical row.
Typography drops to native SwiftUI semantic styles (SF Pro via system fonts,
`.primary`/`.secondary`/`.tertiary` foreground styles) so the popover reads as
a first-class system citizen at a glance.

The four-state honesty layer (`.awaiting` / `.live` / `.stale` / `.error`)
introduced in `0.2.0` **survives the compression** — it becomes compact inline
indicators rather than a separate pill + card system, so the popover never lies
about data freshness.

## User Stories

- As a user, I want the popover to feel like a native macOS Tahoe 26 Control
  Center tile, so that it looks and feels like a first-class system citizen
  rather than a third-party widget.
- As a user, I want to see both my battery level and my home consumption at a
  glance, so that the popover surfaces the two core metrics without needing a
  second tile or row.
- As a user, I want the popover to be small and unobtrusive, so that it never
  covers more of my screen than necessary and dismisses in under a second.
- As a user, I want the typography, colors, and spacing to match what Apple
  uses in its own menu-bar popovers, so that the app is indistinguishable from
  a system utility at a glance.
- As a user, I want the battery state conveyed through a single restrained
  accent color, so that the popover stays calm and the one colored signal
  actually means something.
- As the maintainer, I want the honesty layer preserved through the
  redesign, so that the popover never shows stale data as if it were live.

## Current State (baseline)

| Property | Current value | Source |
| --- | --- | --- |
| Width | 360pt | `GrowattPopoverView.frame(width: 360)`; `StatusBarController.contentSize` |
| Height | 210pt (fixed) | `StatusBarController.contentSize` |
| Hero number | 44pt bold rounded | `GlassTokens.Numeric.hero` |
| Battery bar height | 38pt | `BatteryGeometry.barHeight` |
| Battery bar fill | green/orange gradient | `BatteryIndicatorView.gradientColors` |
| State badge | tinted glass capsule (`.regular.tint(accent)`) | `PowerFlowBadgeView` |
| Inner cards | opaque `controlBackgroundColor` (hero + tile + error) | `heroBackground`, `PowerMetricTileView`, `ErrorBannerView` |
| Header | "Growatt Inverter" `.title3.bold()` + freshness pill | `GrowattPopoverView.header` |
| Home Load | separate `PowerMetricTileView` (opaque card) | `GrowattPopoverView.metricsRow` |
| Footer | `RefreshButton` (44pt, `ButtonStyle.glass`) | `GrowattPopoverView.footer` |
| Outer padding | 18pt | `GlassTokens.Padding.popover` |
| Section spacing | 16pt (`lg`) | `GlassTokens.Spacing.lg` |
| Shell | `.glassEffect(.regular, in:)` (fixed post-spec-001) | `GrowattPopoverView.popoverBackground` |

## Target State

| Property | Target value | Rationale |
| --- | --- | --- |
| Width | **280pt** | Aggressive reduction; close to the smallest Apple system popovers; matches the "radical minimalism" direction. |
| Height | Intrinsic (no fixed height) | Let SwiftUI size to content; `StatusBarController.contentSize` width-only. |
| Hero number | **~28pt** bold rounded (`.title.bold()` or custom) | Control Center tile scale; not a Lock Screen display number. |
| Hero layout | **two-column** — battery % (left) + home load kW (right), each with a tiny secondary label | Densest use of horizontal space; both core metrics at a glance, no extra row. |
| Battery bar height | **~10–12pt** | Thin neutral track, Control Center gauge scale. |
| Battery bar fill | **neutral** (`.primary` opacity) | No green/orange gradient; state conveyed by accent label, not bar color. |
| State signal | **accent-colored label + dot** in the state row | Single colored signal per Apple restraint; `.accentColor` drives it. |
| Inner cards | **none** — flat single glass surface | Content sits directly on the shell; dividers/spacing separate sections. |
| Header | **removed** | No title; the two-column hero is the identity. |
| Home Load | **folded into the hero right column** (not a separate tile) | Preserves the metric without a vertical row; matches Control Center density. |
| Freshness | **compact inline** — small dot + secondary text in the state row | Folds the four-state honesty layer into one line, not a separate pill. |
| Footer | **compact refresh** — small glass icon button, trailing | Retains the manual refresh affordance at minimal size. |
| Outer padding | **16pt** (DESIGN.md `spacing.edge`) | Apple popover edge inset; tighter than 18pt. |
| Section spacing | **12pt** (`md`) | Tighter rhythm for a compact tile. |
| Shell | `.glassEffect(.regular, in:)` — unchanged | Spec 001 settled this; the shell stays Regular glass. |

## Functional Requirements

- FR-1: Reduce the popover width from 360pt to 280pt in both
  `GrowattPopoverView` and `StatusBarController.contentSize`.
- FR-2: Remove the title header ("Growatt Inverter") and the freshness pill as
  standalone elements; fold the freshness signal into a compact inline
  indicator within the state row.
- FR-3: Remove the **separate** Home Load metric tile (`PowerMetricTileView`
  call site and the `metricsRow`) and fold the home consumption value
  (`outputPowerKW`) into the **right column of a two-column hero row** so the
  metric is preserved without a vertical row or card.
- FR-4: Replace the 44pt single hero number with a **two-column hero row**:
  battery percentage (left, ~28pt bold rounded) and home load kW (right,
  ~28pt bold rounded or `.title2.bold()`), each with a tiny secondary label
  ("Battery" / "Home Load") in `.caption` or `.footnote`.
- FR-5: Replace the 38pt green/orange gradient battery bar with a thin (~10–12pt)
  neutral track and neutral fill; remove the battery terminal nub at this scale.
- FR-6: Convey the battery state (charging/discharging) through a single
  accent-colored label and dot, using `Color.accentColor`, not green/orange.
- FR-7: Remove all opaque inner cards (`controlBackgroundColor` hero card,
  metric tile, error banner background); render content directly on the glass
  shell with hairline dividers or spacing for separation.
- FR-8: Preserve the four-state honesty layer (`.awaiting` / `.live` / `.stale`
  / `.error`) as compact inline indicators so the popover never lies about
  freshness.
- FR-9: Use only system semantic colors (`.primary`, `.secondary`, `.tertiary`)
  and `Color.accentColor` for all text and fills; no hardcoded green/orange.
- FR-10: Use native SwiftUI semantic font styles (SF Pro via `.font(.…)`) at
  Control Center tile scale; no 44pt display number.
- FR-11: Keep the `.glassEffect(.regular, in:)` shell on macOS 26+ and the
  `.ultraThinMaterial` fallback on macOS 15 unchanged (spec 001 settled this).
- FR-12: Keep the `accessibilityReduceTransparency`, `accessibilityReduceMotion`,
  and `accessibilityIncreaseContrast` honor throughout.
- FR-13: Keep the refresh affordance as a compact glass icon button
  (`ButtonStyle.glass`, `controlSize(.small)` or `.extraSmall)`).
- FR-14: Update `DESIGN.md` and `GlassTokens` to reflect the new compact
  tokens so the design system stays the single source of truth.

## Acceptance Criteria (EARS)

### Ubiquitous

- The system shall render the popover at a width of 280pt on all supported
  macOS versions (15 and 26+).
- The system shall render all text using system semantic font styles (SF Pro)
  and system semantic foreground styles (`.primary`, `.secondary`, `.tertiary`).
- The system shall convey the battery state (charging / discharging) through
  `Color.accentColor` as the single colored signal, with no green or orange
  fills or gradients.
- The system shall render the popover content directly on the Liquid Glass
  shell with no opaque inner card backgrounds.
- The system shall preserve the four-state freshness honesty layer
  (`.awaiting` / `.live` / `.stale` / `.error`) so the popover never presents
  stale data as live.

### Event-driven

- When the popover opens, the system shall render a **two-column hero row**
  (battery percentage on the left, home load kW on the right, each with a tiny
  secondary label), a thin neutral battery bar, and a state/freshness row with
  a compact refresh control — no title header, no separate Home Load tile,
  no separate freshness pill.
- When the battery state changes, the system shall update the accent-colored
  state label and dot in the state row to reflect the new state.
- When the home consumption value changes, the system shall update the right
  column of the hero row with the new kW value.
- When the freshness transitions to `.stale`, the system shall render an inline
  secondary "Updated Nm ago" text within the state row.
- When the freshness is `.error`, the system shall render a compact two-line
  error indicator (icon + headline + last-reading subtitle) with an inline
  refresh affordance, replacing the hero.
- When the freshness is `.awaiting`, the system shall render a compact
  placeholder (shimmer bar + "Connecting…") with no fabricated percentage.
- When the user clicks the refresh control, the system shall trigger
  `viewModel.refreshData()` and show the loading state on the compact button.

### State-driven

- While `accessibilityReduceTransparency` is enabled, the system shall render
  the popover shell with the existing opaque fallback and keep all content
  legible without inner cards.
- While `accessibilityReduceMotion` is enabled, the system shall disable the
  shimmer, the bar fill animation, and the refresh spinner rotation.
- While the system appearance is dark, the system shall render all text and
  the battery bar using system semantic colors so no manual override is needed.

### Unwanted behavior

- If the popover width would cause text truncation at the largest Dynamic Type
  size, then the system shall allow the text to wrap or truncate with an
  ellipsis rather than overflow the 280pt frame.
- If a surface is not a navigation/control element, then the system shall not
  apply `.glassEffect()` to it (content stays flat on the shell).

### Optional features

- Where the user has set a custom accent color, the system shall use that
  accent for the state signal so the popover respects the user's preference.
- Where a future requirement reintroduces a metric, the system may add a
  compact row on the flat surface rather than a card, per the amended
  `DESIGN.md` flat-surface pattern.

## Non-Functional Requirements

- **Performance**: the popover renders one glass shell and flat content; no
  inner card backgrounds, no gradient fills, no full-tree glass container.
  Rendering cost decreases vs. the current state.
- **Security**: N/A (no data, network, or credential changes).
- **Observability**: N/A (pure rendering change; no logging added or removed).
- **Reliability**: `swift build` must complete with 0 errors and 0 warnings;
  the macOS 15 and Reduce Transparency code paths must remain functional.
- **Accessibility**: all text respects Dynamic Type; all interactive controls
  carry VoiceOver labels; Reduce Motion and Reduce Transparency honored.
- **Compatibility**: minimum macOS 15 (`Package.swift` floor unchanged); Liquid
  Glass gated with `#available(macOS 26, *)`; `.ultraThinMaterial` fallback
  preserved.

## Out of Scope

- Changing the `NSPopover` shell or migrating to SwiftUI-native popover
  presentation (the AppKit `NSPopover` + `NSHostingController` shell stays).
- Changing the data model, service layer, view model, or polling logic.
- Reintroducing the Home Load metric as a **separate tile or card** — the value
  is preserved in the two-column hero row; a separate vertical tile is out of
  scope (a future spec may revisit if more metrics are needed).
- Changing the status bar item (`NSStatusItem`) title or icon.
- Raising the macOS deployment target.
- Introducing third-party dependencies.
- The Keychain credential storage work (separate concern).

## Open Questions

- **OQ-1 (resolved in plan):** Should the battery bar fill be neutral
  (`.primary` opacity) or accent-tinted? — Resolved: neutral fill; the accent
  is reserved for the state label/dot so there is exactly one colored signal.
  The bar is a gauge, not a state indicator.
- **OQ-2 (resolved in plan):** Should the hero number use a SwiftUI semantic
  style (`.title.bold()`) or a fixed point size? — Resolved: a fixed ~28pt
  rounded bold, matching the Control Center tile scale and the existing
  `GlassTokens.Numeric` pattern (the hero is a glance instrument, not body
  copy); the trade-off (no Dynamic Type scaling on the hero) is documented
  at the call site, consistent with the prior 44pt decision.
- **OQ-4 (resolved in plan):** Should the home consumption be rendered as a
  separate tile, an inline row, or folded into the hero? — Resolved: a
  **two-column hero row** (battery % left, home load kW right, each with a
  tiny label). Densest use of horizontal space; both core metrics at a glance
  with no extra vertical row. The separate `PowerMetricTileView` is removed; the
  value renders inline in the hero.
- **OQ-3 (deferred, non-blocking):** Would the native macOS 26 `NSPopover`
  appearance alone (no custom SwiftUI background) deliver an equal or better
  shell? — Carried forward from spec 001 OQ-2; not required to close this
  spec. The custom Regular shell stays.

## References

- Constitution: [AGENTS.md](../../../AGENTS.md)
- Design system: [DESIGN.md](../../../DESIGN.md) (`popover-mac`, `typography`,
  `colors`, `spacing`, `rounded` tokens)
- Prior spec: [specs/001-liquid-glass-popover-content-blur/](../001-liquid-glass-popover-content-blur/)
  (settled the Regular-variant shell, no-container, opaque-card pattern that
  this spec evolves into a flat-surface pattern)
- Apple — WWDC25 Session 219, [Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
  (Regular variant, navigation-layer-only, never mix variants, tint = one
  primary action)
- Apple — WWDC25 Session 323, [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
  (Control Center tile density, semantic typography)
- Apple — [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)
  (technology overview)
- Apple Human Interface Guidelines — Materials, Popovers
- Research: macOS Tahoe 26 Control Center tile aesthetic (compact, modular,
  glass shell, neutral palette, accent for the single state signal)