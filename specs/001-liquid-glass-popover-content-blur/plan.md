# 001 Liquid Glass Popover Content Blur — Technical Plan

## Summary

Remove the `GlassEffectContainer` from the popover's content tree (the capture/lensing mechanism that blurs all interior content), switch the shell's glass variant from `.clear` to `.regular` (restoring the system's adaptive legibility treatment and ending the prohibited variant mixing), delete the now-dead `GlassContainerModifier`, collapse three dead identical `if/else` background branches, and amend `DESIGN.md` + code comments so the overgeneralized container rule that caused this regression cannot recur. Five small files change; no logic, no API, no dependency changes. Key trade-off: we give up the (illusory) benefit of unified lensing between the shell and the badge — in exchange for guaranteed-sharp content, which is the non-negotiable requirement.

## Architecture

Layers touched, per the AGENTS.md constitution. **All changes are confined to `Views/` in `GrowattToolbarCore`** — no Models, Services, or ViewModels change; the AppKit shell (`GrowattToolbarApp`) is untouched.

- **Views**: `src/GrowattToolbarCore/Views/GrowattPopoverView.swift` — remove the `.glassContainer(spacing:)` call (and its comment block) from `body`; change `popoverBackground` from `.glassEffect(.clear, in:)` to `.glassEffect(.regular, in:)`; collapse `heroBackground`'s identical RT on/off branches; update the file's top doc comment and the background rationale comments.
- **Views/Components**: `src/GrowattToolbarCore/Views/Components/PowerMetricTileView.swift` — collapse identical RT branches in `background`; update doc comment.
- **Views/Components**: `src/GrowattToolbarCore/Views/Components/ErrorBannerView.swift` — collapse identical RT branches in `background`.
- **Views/Components**: `src/GrowattToolbarCore/Views/Components/GlassContainerModifier.swift` — **delete the file** (sole call site removed; keeping it invites a third regression).
- **Docs**: `DESIGN.md` — amend the `GlassEffectContainer` Do-rule with its correct scope and add the popover-shell pattern; `CHANGELOG.md` — new `0.2.13` block.

### Decision D-1: Remove the container; do not relocate it

Apple's doc: "The `glassEffect(_:in:)` modifier captures the content to send to the container to render." A container wrapping the root `VStack` captures the whole tree. The container's legitimate purpose — blending/morphing **adjacent** glass elements — has no valid target in this UI: the badge (hero, top) and the refresh button (footer, bottom) are ~200pt apart and never merge. Therefore the correct fix is removal, not re-scoping. If a future cluster of adjacent glass controls appears, a container scoped to that cluster alone may return (encoded in the amended DESIGN.md rule and in spec.md's Optional EARS criterion).

### Decision D-2: Keep the shell as a `.glassEffect(.regular, in:)` background on the root view

Alternatives considered:

1. **`.glassEffect(.regular, in:)` root background (chosen).** Verified API, deterministic result: without a container, the glass renders behind the view sampling the desktop through the transparent popover — content above is drawn normally and stays sharp (empirically proven by the sharp `0.2.11` build, which had no container). Regular restores the adaptive vibrant legibility treatment for the header title and pill that sit directly on the glass, and matches the shell character the user already approved.
2. **Native `NSPopover` glass (no custom SwiftUI background).** Most idiomatic long-term, but its rendered result for an AppKit-hosted popover cannot be verified without runtime experimentation, and it risks losing the shell quality the user explicitly wants to keep. Deferred — recorded as spec OQ-2.
3. **`glassBackgroundEffect`-style scene API.** Rejected: existence on macOS SwiftUI could not be verified (both candidate DocC paths 404; the same-named API is visionOS-specific). The plan must not rely on unverified APIs (spec OQ-1, AGENTS.md "never guess").

### Decision D-3: One variant family — Regular

After D-2 the shell is `.regular`, the badge is `.regular.tint(accent)`, and the refresh button is `ButtonStyle.glass` (Regular family): a single lighting model across the surface, ending the prohibited Clear/Regular mix (WWDC25-219). The badge's tint stays — it is a meaning signal (battery state), which is the sanctioned use of tinting. The shell stays untinted: tint is reserved for emphasis, and the popover background is not an action.

### Decision D-4: Keep opaque inner cards; collapse dead branches

The `controlBackgroundColor` hero card / tile / banner are the correct "glass shell, opaque content" pattern (validated in `0.2.11`) and stay. The three `if reduceTransparency { X } else { X }` branches that return identical fills are collapsed to a single expression — pure hygiene, zero behavior change (RT users keep the same opaque surface they have today).

## Target code shape (before → after)

**`GrowattPopoverView.body`** — the container call and its comment block go away:

```swift
// Before (lines 38–46)
.background { popoverBackground }
// macOS 26 Liquid Glass: the shared sampling region gives the …
.glassContainer(spacing: GlassTokens.Spacing.lg)

// After
.background { popoverBackground }
```

**`GrowattPopoverView.popoverBackground`** — variant switch (single token), comment explains why Regular:

```swift
// Before (line 231–234)
} else if #available(macOS 26, *) {
    shape
        .fill(Color.clear)
        .glassEffect(.clear, in: shape)
}

// After
} else if #available(macOS 26, *) {
    // Regular, not Clear: Clear is only for media-rich backdrops with a
    // dimming layer and bold/bright overlay content (WWDC25-219) and never
    // applies the adaptive legibility treatment — the header title sits
    // directly on this shell. Regular keeps every label sharp and vibrant.
    shape
        .fill(Color.clear)
        .glassEffect(.regular, in: shape)
}
```

**`GrowattPopoverView.heroBackground` / `PowerMetricTileView.background` / `ErrorBannerView.background`** — collapse identical branches:

```swift
// Before (all three files)
if reduceTransparency {
    shape.fill(Color(nsColor: .controlBackgroundColor))
} else {
    shape.fill(Color(nsColor: .controlBackgroundColor))
}

// After — single fill; the `@Environment(reduceTransparency)` property is
// removed where it becomes unused (PowerMetricTileView, ErrorBannerView).
RoundedRectangle(cornerRadius: …, style: .continuous)
    .fill(Color(nsColor: .controlBackgroundColor))
```

**`GlassContainerModifier.swift`** — deleted in full.

## Data Model

N/A — no model, state, or DTO changes. `InverterStatus`, `InverterState`, `Freshness`, and `InverterViewModel` are untouched; this is a rendering-layer fix only.

## API Contracts

N/A — no network, protocol, or public-API-signature changes. `GrowattAPIServiceProtocol` and the `/status` integration are untouched. The only symbol removed from the module's public surface is the `glassContainer(spacing:)` `View` extension (internal modifier struct + public extension), which has exactly one call site — removed in the same change.

## Dependencies

- **New runtime dependencies**: none.
- **New dev dependencies**: none.

## Migration / Rollout

- **Backwards compatibility**: the macOS 15 path (`.ultraThinMaterial` shell, tinted-solid badge, `.bordered` button) and the Reduce Transparency paths are behavior-identical to today; only the macOS 26 rendering path changes.
- **Feature flags**: none — the `#available(macOS 26, *)` gates already in place are the only branching.
- **Rollback plan**: `git revert` the single fix commit. The change is surgical (5 files, ~40 lines net, one file deletion) so revert is clean.
- **Branch / commits**: `fix/liquid-glass-popover-content-blur`; one conventional `fix(ui): …` commit per task group per the `git-workflow` skill, referencing `specs/001-liquid-glass-popover-content-blur/`.

## Test Strategy

There are no automated visual tests in this package (no test targets in `Package.swift`); verification is build-level plus a structured manual visual pass:

- **Build gate (every task)**: `swift build` — 0 errors, 0 warnings.
- **Manual visual verification (final task)** — `swift run GrowattToolbarApp`, open the popover, and check against the spec's symptom table:
  - Title, `Live` pill, `100%` numeral, battery bar, `Home Load` tile: sharp edges, full contrast (compare against the pre-fix screenshot).
  - Shell: translucency, specular rim, and desktop sampling intact (the approved "perfect wrapper" character).
  - Badge: tinted glass, state switch charging ↔ discharging renders correctly.
  - Refresh button: glass style, spins while loading, sharp glyph.
  - No ghost/smear artifact under the popover arrow.
  - Dark and Light appearances (System Settings → Appearance): cards adopt `controlBackgroundColor`; all text legible in both.
  - Accessibility → Reduce Transparency ON: opaque fallbacks, no translucency, everything sharp; OFF: back to glass.
  - All four freshness states where feasible (`.awaiting` on launch, `.live`, `.stale` after stopping the local API, `.error` with a bad `GROWATT_API_KEY`).
- **Code-inspection gate**: `grep -R "GlassEffectContainer\|glassContainer" src/` returns zero hits; `grep -R "\.clear, in:" src/` returns zero hits.

## Risks & Trade-offs

- **Risk: losing the unified shell+badge lensing changes the shell's look.** Mitigation: the shell's glass is unchanged in kind (still a full-size glass background); the badge and button render as independent glass elements, which is Apple's default for non-adjacent controls. The `0.2.11` build already proved the shell reads as proper glass without the container; D-2's Regular variant adds the adaptive treatment, if anything improving the shell.
- **Risk: Regular shell is slightly more opaque than Clear, altering the "approved" look.** Accepted trade-off: Clear is documented by Apple as illegible-by-design for this use case (no dimming layer, non-media backdrop); Regular is the correct variant for a popover shell and is what system surfaces use. The visual delta is toward the macOS 26 system norm, which is the stated goal ("closest to a proper Liquid Glass effect of macOS Tahoe 26").
- **Trade-off: `GlassContainerModifier` deletion is lossy if a future cluster needs it.** Mitigated by the amended DESIGN.md rule documenting exactly when and how to reintroduce a scoped container.
- **Non-risk confirmation:** without a container, a full-size `.glassEffect` background cannot blur content above it — glass renders behind its view and samples the backdrop beneath (desktop), not siblings above it in z-order; corroborated by the sharp `0.2.11` build.

## References

- Spec: [spec.md](./spec.md)
- Constitution: [AGENTS.md](../../../AGENTS.md)
- Design system: [DESIGN.md](../../../DESIGN.md)
- Apple — Applying Liquid Glass to custom views; GlassEffectContainer; WWDC25-219; WWDC25-323 (full URLs in spec.md References)
