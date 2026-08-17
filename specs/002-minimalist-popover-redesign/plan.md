# 002 Minimalist Popover Redesign — Technical Plan

## Summary

Redesign the Growatt popover from a 360pt, multi-card, gradient-bar dashboard
into a 280pt, flat, single-surface Control Center tile. The work is confined to
the `Views/` layer of `GrowattToolbarCore` plus the `StatusBarController`
content-size constant and the `GlassTokens` / `DESIGN.md` design tokens. No
model, service, view-model, or AppKit-shell-lifecycle changes. The four-state
honesty layer survives as compact inline indicators. The Liquid Glass Regular
shell (settled in spec 001) stays; only the content on top of it changes.

Key trade-off: we give up the rich, dashboard-like information density (Home
Load tile, 44pt hero, gradient bar, title header) in exchange for a popover
that reads as a native macOS Tahoe 26 system utility. The single accent-colored
state signal replaces the green/orange gradients — one colored signal per
surface, per Apple's Liquid Glass restraint rule.

## Architecture

Layers touched, per the AGENTS.md constitution. **All changes are confined to
`Views/` in `GrowattToolbarCore` plus one constant in `StatusBarController`
(`GrowattToolbarApp`) and the design tokens.** No Models, Services, or
ViewModels change.

- **Views**: `GrowattPopoverView.swift` — full body rewrite: remove header,
  metrics row, opaque card backgrounds; new compact flat layout (hero row,
  battery bar, state/freshness row, refresh control).
- **Views/Components**: `BatteryIndicatorView.swift` — rewrite to a thin neutral
  bar (~10–12pt), neutral fill, no terminal nub, no gradient.
- **Views/Components**: `BatteryIndicatorPlaceholder.swift` — shrink to match
  the new bar height; keep the shimmer (Reduce-Motion-gated).
- **Views/Components**: `PowerFlowBadgeView.swift` — rewrite from a tinted-glass
  capsule to a compact accent-colored label + dot (no glass background; flat on
  the shell).
- **Views/Components**: `FreshnessIndicatorView.swift` — collapse into a compact
  inline dot + secondary text used inside the state row (no standalone pill
  background).
- **Views/Components**: `PowerMetricTileView.swift` — **delete** (no call site
  after the metrics row is removed).
- **Views/Components**: `ErrorBannerView.swift` — rewrite to a compact two-line
  flat indicator (no card background); keep the inline refresh and the
  `relativeString(for:)` helper (still the single source of truth for
  time-aware copy).
- **Views/Components**: `RefreshButton.swift` — shrink to `controlSize(.small)`
  (or `.extraSmall`); keep `ButtonStyle.glass` on macOS 26+, `.bordered` on 15.
- **Views/Components**: `GlassTokens.swift` — update `Numeric.hero` to ~28pt;
  add compact spacing/padding tokens for the tile; remove the now-unused `card`
  / `tile` radius and padding tokens if no consumer remains.
- **App**: `StatusBarController.swift` — change `popover.contentSize` width from
  360 to 280; set height to a value that fits the new compact content (or rely
  on intrinsic sizing if feasible with `NSHostingController`).
- **Docs**: `DESIGN.md` — document the flat-surface popover pattern and the
  compact Control Center tile tokens; `CHANGELOG.md` — new version block.

### Decision D-1: Flat single surface, no inner cards

The current opaque `controlBackgroundColor` cards (hero, tile, error) are
removed. Content renders directly on the `.glassEffect(.regular, in:)` shell.
Separation between sections is achieved with **hairline dividers**
(`Divider()` or a 1pt `separator`-colored line) and **spacing**, not card
backgrounds. This matches the Control Center tile pattern and Apple's
"navigation layer only" rule — the shell is the one glass surface; everything
on it is content.

Rationale: spec 001 established that the shell is the only translucency layer
and inner cards are opaque so type stays sharp. With a flat surface, content
sits directly on the Regular glass, which applies its **adaptive legibility
treatment** to all labels above it (WWDC25-219: "All content placed on the
Regular variant will automatically receive this treatment"). This is the
documented mechanism that keeps flat-on-glass content legible. The Reduce
Transparency fallback renders the shell opaque, so flat content stays legible
there too.

### Decision D-2: Neutral battery bar; accent for the single state signal

The battery bar fill becomes **neutral** (`.primary` at reduced opacity, or a
neutral system fill color). The green/orange gradient is removed entirely. The
battery **state** (charging / discharging) is conveyed by a single
accent-colored label + dot using `Color.accentColor`, so there is exactly one
colored signal on the surface — Apple's Liquid Glass tinting restraint ("tint
at most one primary element per screen"). The bar is a gauge (how full), not a
state indicator (which direction); conflating them was the pre-redesign
design's loudest anti-native cue.

### Decision D-3: Compact hero number (~28pt), not 44pt

The 44pt display number is a Lock Screen scale (`DESIGN.md typography.display-sm`).
A Control Center tile uses a smaller, denser numeral. The new hero uses a fixed
~28pt bold rounded font (`GlassTokens.Numeric.hero` updated), consistent with
the existing `Numeric` token pattern. Trade-off: the hero does not scale with
Dynamic Type (it is a glance instrument, not body copy); this is the same
conscious trade-off documented for the 44pt number, now at a smaller scale.
All other text uses semantic SwiftUI styles that **do** scale with Dynamic Type.

### Decision D-4: Fold freshness into the state row; drop the standalone pill

The standalone `FreshnessIndicatorView` pill (capsule background + dot + text)
is collapsed into a compact inline element within the state row: a small dot +
secondary text ("Live" / "Updated Nm ago" / "Offline" / "Connecting…"). The
four-state honesty layer is preserved — only its visual weight is reduced. The
`.awaiting` shimmer stays on the battery bar placeholder; the `.error` state
becomes a compact two-line flat indicator replacing the hero (no card).

### Decision D-5: Fold Home Load into a two-column hero; remove the title header

Radical minimalism: the title "Growatt Inverter" adds no information the
battery percentage doesn't already convey (the status bar item already
identifies the app). The **separate** Home Load tile is a second metric that
doubles the popover's vertical footprint; removing it as a standalone block
is the single biggest height reduction. However, the home consumption value
(`outputPowerKW`) is core information the product exists to surface, so it is
**not dropped** — it is folded into the **right column of a two-column hero
row** (battery % left, home load kW right, each with a tiny secondary label).
This preserves both core metrics at a glance with no extra vertical row,
matching the Control Center tile density. The `PowerMetricTileView` component
is deleted (no call site); the kW value renders inline in the hero. A future
spec may add more metrics as compact flat rows if the user revisits.

### Decision D-6: Keep the Regular glass shell; do not touch the AppKit lifecycle

Spec 001 settled the shell as `.glassEffect(.regular, in:)` on the root
background with no `GlassEffectContainer`. This spec keeps that exactly. The
`NSPopover` + `NSHostingController` shell in `StatusBarController` stays; only
`contentSize` width changes (360 → 280) and the height is adjusted to fit the
new compact content. No migration to SwiftUI-native popover presentation
(deferred, spec 001 OQ-2 / this spec OQ-3).

## Target layout (wireframe)

```
┌─────────────────────────────── 280pt ───────────────────────────────┐
│  (16pt padding all around, flat on Regular glass)                    │
│                                                                      │
│   Battery            Home Load          ← tiny secondary labels       │
│   73%                1.8 kW             ← two-column hero (~28pt)   │
│   ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄   ← thin neutral bar (~10pt)  │
│                                                                      │
│   ─────────────────────────────  ← hairline divider (optional)       │
│                                                                      │
│   ● Charging  ● Live                    ↻  ← state/freshness + refresh │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

- **Hero row (two-column)**: left column = tiny "Battery" label (`.caption`,
  `.secondary`) + `~28pt` bold rounded percentage; right column = tiny
  "Home Load" label (`.caption`, `.secondary`) + `~28pt` bold rounded (or
  `.title2.bold()`) kW value. The two columns split the 280pt width evenly
  (minus padding); the kW value uses `monospacedDigit()` so it doesn't jitter.
- **Battery bar**: thin neutral track, neutral fill, no terminal nub.
- **Divider**: optional hairline between the bar and the state row.
- **State row**: accent dot + "Charging" / "Discharging" label (state signal,
  `Color.accentColor`) + freshness dot + "Live" / "Updated Nm ago" / "Offline"
  (trust signal, semantic green/amber/red — see D-2 nuance) + refresh icon
  button trailing.
- **Error state**: hero row replaced by icon + "Can't reach inverter" +
  "Last reading Nm ago" (two compact lines) + inline refresh.
- **Awaiting state**: percentage replaced by "···"; kW value replaced by
  "···"; bar shows shimmer; "Connecting…" in the state row.

> **D-2 nuance:** the *state* signal (charging/discharging) uses accent only.
> The *freshness* signal (live/stale/error) may use a small semantic dot
> (green/amber/red) because freshness is a **trust** signal, not a state
> signal — it is a different semantic axis. This keeps "one colored signal per
> axis" rather than one per surface. The plan documents this distinction so a
> reviewer does not read it as a contradiction of D-2.

## Data Model

N/A — no model, state, or DTO changes. `InverterStatus`, `InverterState`,
`Freshness`, and `InverterViewModel` are untouched. `InverterState.accentColor`
(green/orange) stays in the model for any future consumer but is **no longer
read by the popover views** — the popover uses `Color.accentColor` for the
state signal instead. (Leaving the model property avoids a model-layer change
out of scope for a UI redesign; a future cleanup may remove it.)

## API Contracts

N/A — no network, protocol, or public-API-signature changes. The only public
symbol removed from the module's surface is `PowerMetricTileView` (deleted; no
call site after the metrics row is removed). `PowerFlowBadgeView`'s initializer
signature changes (state-only, no glass background) but it is internal to the
popover composition.

## Dependencies

- **New runtime dependencies**: none.
- **New dev dependencies**: none.

## Migration / Rollout

- **Backwards compatibility**: the macOS 15 path (`.ultraThinMaterial` shell)
  and the Reduce Transparency paths remain functional; flat content on an
  opaque RT shell is legible. The `#available(macOS 26, *)` gates are
  unchanged.
- **Feature flags**: none — the `#available` gates already in place are the
  only branching.
- **Rollback plan**: `git revert` the redesign commit(s). The change is
  confined to `Views/` + one `StatusBarController` constant + tokens, so revert
  is clean.
- **Branch / commits**: `feature/minimalist-popover-redesign`; one conventional
  `feat(ui):` / `refactor(ui):` commit per task group per the `git-workflow`
  skill, referencing `specs/002-minimalist-popover-redesign/`.

## Test Strategy

There are no automated visual tests in this package (no test targets in
`Package.swift`); verification is build-level plus a structured manual visual
pass:

- **Build gate (every task)**: `swift build` — 0 errors, 0 warnings.
- **Code-inspection gates**:
  - `grep -R "controlBackgroundColor" src/GrowattToolbarCore/Views/` returns
    zero hits (no inner cards).
  - `grep -R "\.green\|\.orange" src/GrowattToolbarCore/Views/` returns zero
    hits in the popover views (state colors gone; the model's `accentColor`
    is the only allowed green/orange reference, and it is no longer read).
  - `grep -R "PowerMetricTileView" src/` returns zero hits (deleted).
  - `grep -R "frame(width: 360)" src/` returns zero hits; `280` is the only
    popover width.
- **Manual visual verification (final task)** — `swift run GrowattToolbarApp`,
  open the popover, and check:
  - Width is visibly smaller (~280pt); height is compact (no large empty
    regions).
  - No title header; no Home Load tile; no opaque card backgrounds.
  - Battery percentage renders at ~28pt; battery bar is thin and neutral.
  - State label + dot use the system accent color; no green/orange bar.
  - Freshness dot + text render inline in the state row.
  - Refresh button is compact and functional (spins while loading).
  - All four freshness states render correctly (`.awaiting` shimmer +
    "Connecting…"; `.live`; `.stale` "Updated Nm ago"; `.error` compact
    two-line indicator).
  - Dark and Light appearances: all text legible via system semantic colors.
  - Reduce Transparency ON: opaque shell, flat content legible; OFF: glass.
  - Reduce Motion ON: shimmer/animation/spinner disabled; OFF: animated.
  - Dynamic Type at largest size: no overflow beyond 280pt (wrap/truncate).
- **Accessibility gate**: VoiceOver reads the hero, state, freshness, and
  refresh as coherent utterances; the refresh button has its "Refresh" label.

## Risks & Trade-offs

- **Risk: flat content on glass may reduce contrast in edge cases.** Mitigation:
  the Regular variant applies adaptive legibility treatment to content above
  it (WWDC25-219); the Reduce Transparency fallback renders the shell opaque.
  If a measured contrast failure appears, a subtle opaque scrim behind text
  only (not a full card) is the documented fallback — recorded but not needed
  unless measured.
- **Risk: 280pt may crowd at the largest Dynamic Type size.** Mitigation: the
  hero number is fixed-point (does not scale); secondary text uses semantic
  styles that wrap/truncate. The manual visual pass checks the largest size.
- **Risk: the two-column hero may crowd at the largest Dynamic Type size.**
  Mitigation: the hero numbers are fixed-point (do not scale); the tiny labels
  use `.caption` which wraps/truncates. The manual visual pass checks the
  largest size. If crowding is measured, the kW value may drop to `.title2`
  while the battery % stays at 28pt.
- **Risk: removing `InverterState.accentColor` usage may leave dead model
  code.** Mitigation: the property stays (out of scope to remove a model
  property in a UI spec); a future cleanup task may remove it. Documented.
- **Non-risk:** the Regular shell, no-container rule, and macOS 15 fallback are
  all settled by spec 001 and unchanged here.

## References

- Spec: [spec.md](./spec.md)
- Constitution: [AGENTS.md](../../../AGENTS.md)
- Design system: [DESIGN.md](../../../DESIGN.md)
- Prior spec: [specs/001-liquid-glass-popover-content-blur/](../001-liquid-glass-popover-content-blur/)
- Apple — WWDC25-219 (Meet Liquid Glass); WWDC25-323 (Build a SwiftUI app with
  the new design); Adopting Liquid Glass (full URLs in spec.md References)