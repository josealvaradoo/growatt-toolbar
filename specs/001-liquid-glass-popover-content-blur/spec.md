# 001 Liquid Glass Popover Content Blur

## Summary

The popover's **shell** renders a correct macOS 26 Liquid Glass surface (translucency, specular rim, desktop sampling), but all **content inside it** — the header title, the freshness pill, the battery hero (percentage + bar), and the `Home Load` metric tile — renders blurred, milky, and ghosted instead of sharp. This is a regression of the same class of bug fixed in `0.2.11` and re-introduced in `0.2.12` when `.glassContainer(spacing:)` was re-added to the popover body under the incorrect assumption that the container only affects glass surfaces. Root-cause analysis against Apple's official SwiftUI documentation and WWDC25 sessions identifies **three compounding defects**: (1) a `GlassEffectContainer` wrapping the entire content tree captures all interior content into the glass rendering pass, (2) the popover shell uses the `.clear` glass variant outside its documented preconditions, destroying content legibility, and (3) the `.clear` shell is mixed with a `.regular` badge, which Apple explicitly prohibits. This spec defines the correct end state: a Regular-variant glass shell with crisp, vibrant content and no content-tree capture.

## User Stories

- As a user, I want the popover's text, numbers, and gauges to render sharp and high-contrast, so that I can read my inverter's state at a glance from arm's length.
- As a user, I want the popover to keep its Liquid Glass shell (translucency, lensing, specular highlights), so that the app looks and feels like a first-class macOS Tahoe citizen.
- As the maintainer, I want the glass architecture rules written down correctly, so that this regression cannot be re-introduced a third time.

## Symptom (image analysis)

Screenshot: popover open on macOS 26, dark desktop wallpaper, live data (`100%`, charging, `0.0 kW`).

| Region | Expected | Observed |
| --- | --- | --- |
| Popover shell (edges, rim) | Liquid Glass: translucency, specular highlight, desktop sampling | ✅ Correct — preserve exactly |
| Header title `Growatt Inverter` | Sharp, full-contrast primary label | ❌ Gray, soft-edged, ghosted |
| Freshness pill `Live` | Crisp capsule + legible caption | ❌ Faint, washed out |
| Hero card (`100%` + battery bar) | Sharp 44pt numeral, crisp gradient bar on an opaque card | ❌ Milky card, fuzzy numeral, blurred bar |
| `Home Load` tile | Sharp icon, label, and value on an opaque card | ❌ Washed, blurred content |
| Refresh button (footer) | Sharp glyph on glass | ⚠️ Comparatively sharp (sits at the edge of the affected region) |
| Top edge, under popover arrow | Clean glass edge | ❌ Smeared, vertically-stretched ghost echo of content — the classic signature of content captured into a lensing pass |

Key diagnostic: the blur is **uniform across all interior content** (including content on opaque cards) while the shell itself looks perfect. Content above a background cannot be blurred by that background — so the content must be getting **captured into the glass rendering pass itself**.

## Root-Cause Analysis

### RC-1 (primary): `GlassEffectContainer` wraps the entire content tree

`GrowattPopoverView.swift:45` applies `.glassContainer(spacing:)` to the popover's root `VStack`, wrapping **all** content (header, hero, metrics, footer) in a `GlassEffectContainer` (`GlassContainerModifier.swift:20`).

Apple's documentation is explicit about the mechanism ([Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)):

- "Use `GlassEffectContainer` when applying Liquid Glass effects on multiple views… Inside a container, **each view with the `glassEffect(_:in:)` modifier renders with the effects behind it**."
- "**The `glassEffect(_:in:)` modifier captures the content to send to the container to render.**"
- "A spacing value on the container that's larger than the spacing of an interior `HStack`, `VStack`, or other layout container **causes Liquid Glass effects to blend together at rest** because the views are too close to each other."

The popover contains a **full-size** background glass shape (360 × full height rounded rectangle) plus the badge capsule plus the refresh-button glass. Inside the container these shapes union into a single glass region covering the entire popover, and the interior content is captured into that shared lensing/sampling pass — producing exactly the observed uniform blur, the milky wash, and the smeared ghost artifact near the popover arrow. The container is designed to make **adjacent glass controls** blend and morph (e.g., badge clusters in the Landmarks sample), not to wrap content hierarchies.

Regression history (from `CHANGELOG.md`): introduced in `0.2.5`; removed in `0.2.11` (content became sharp — empirical proof); re-added in `0.2.12` on the mistaken belief that "the container's shared sampling region only affects the glass surfaces" (blur returned — current state). The only delta between the sharp and blurred builds is the presence of the container.

### RC-2 (secondary): the shell uses the `.clear` variant outside its preconditions

`GrowattPopoverView.swift:234` renders the shell with `.glassEffect(.clear, in: shape)`. Per WWDC25 session 219 (Meet Liquid Glass), Clear is legitimate **only** when all three conditions hold: (a) the element sits over media-rich content, (b) a dimming layer can be applied without harming the content layer, (c) content above it is bold and bright. Otherwise "legibility gets noticeably worse," and Clear "does not have adaptive behaviors" — it never applies the automatic light/dark vibrant legibility treatment that Regular applies to content above it ("All content placed on the Regular variant will automatically receive this treatment"). The popover satisfies none of the three preconditions: the backdrop is an arbitrary desktop, there is no dimming layer, and the header title is 20pt semibold. This defect primarily washes out the elements that sit **directly on the glass** (header title, freshness pill, footer button).

### RC-3 (secondary): `.clear` shell mixed with `.regular` badge

The shell uses `.clear` while `PowerFlowBadgeView.swift:48` uses `.regular.tint(state.accentColor)` and `RefreshButton` uses `ButtonStyle.glass` (Regular family). WWDC25 session 219 and `DESIGN.md` both state the variants "should never be mixed, as they each have their own characteristics" — incompatible lighting models on one surface produce inconsistent lighting, contributing to the uneven wash (sharp-ish button, ghosted title).

## Functional Requirements

- FR-1: Remove the `GlassEffectContainer` from the popover's content tree so no interior content is captured into a glass rendering pass.
- FR-2: Render the popover shell with the **Regular** Liquid Glass variant on macOS 26+ so the system applies its adaptive legibility treatment to content above it.
- FR-3: Keep every glass surface in the popover within the **Regular** family (shell, badge tint, refresh button) — one lighting model per surface.
- FR-4: Preserve the existing opaque inner cards (`controlBackgroundColor` hero card, metric tile, error banner) — the shell is the only translucency layer.
- FR-5: Preserve the macOS 15 (`.ultraThinMaterial`) and Reduce Transparency (opaque) fallbacks unchanged.
- FR-6: Correct the project documentation (`DESIGN.md`, code comments) so the container rule that caused this regression is stated with its proper scope.

## Acceptance Criteria (EARS)

### Ubiquitous

- The system shall render all popover content (title, pill, percentage, battery bar, metric tile, error banner) free of blur, milkiness, and lensing distortion on macOS 26+.
- The system shall keep the popover shell as a Liquid Glass surface with lensing and specular highlights on macOS 26+.
- The system shall not wrap any view hierarchy containing non-glass content in a `GlassEffectContainer`.
- The system shall render all glass surfaces in the popover with the Regular variant family (`.regular`, `.regular.tint(...)`, `ButtonStyle.glass`).

### Event-driven

- When the popover opens on macOS 26+, the system shall render the shell using `.glassEffect(.regular, in:)` and no `GlassEffectContainer` ancestor.
- When the popover opens on macOS 15, the system shall render the shell using `.ultraThinMaterial` exactly as before the fix.
- When the user toggles the battery state, the system shall render the state badge with `.regular.tint(state.accentColor)` exactly as before the fix.

### State-driven

- While `accessibilityReduceTransparency` is enabled, the system shall render the popover shell and inner cards with their existing opaque fallbacks.
- While the freshness state is `.awaiting`, `.live`, `.stale`, or `.error`, the system shall render the corresponding hero content sharp and undistorted.

### Unwanted behavior

- If two glass elements are not adjacent and never need to blend or morph, then the system shall not group them in a `GlassEffectContainer`.
- If a surface is not over media-rich content with a dimming layer and bold/bright overlay content, then the system shall not use the `.clear` Liquid Glass variant on it.

### Optional features

- Where the system appearance is dark, the system shall render inner cards with the dark `controlBackgroundColor` and keep all text legible without manual color overrides.
- Where a future UI introduces a cluster of adjacent glass controls that must blend, the system may scope a `GlassEffectContainer` to that cluster only, per the amended `DESIGN.md` rule.

## Non-Functional Requirements

- **Performance**: exactly one glass background region for the shell plus two small control glass surfaces; no full-popover sampling/capture pass (removes the container's offscreen capture of the entire content tree).
- **Security**: N/A (no data, network, or credential changes).
- **Observability**: N/A (pure rendering change; no logging added or removed).
- **Reliability**: `swift build` must complete with 0 errors and 0 warnings; the macOS 15 and Reduce Transparency code paths must be byte-identical in behavior to before the fix.

## Out of Scope

- Changing the popover layout, information architecture, typography, colors, or component set (the design stays; only the glass mechanics change).
- Replacing the `NSPopover` shell or migrating to SwiftUI-native popover presentation.
- Evaluating or adopting a scene/window-level glass background API (no such macOS SwiftUI API could be verified in current documentation; see Open Questions).
- The `popover.contentSize` fixed height (`210`) vs. intrinsic content height mismatch (pre-existing, harmless, unrelated).
- Keychain-based credential storage, polling logic, view-model, model, or service changes of any kind.

## Open Questions

- **OQ-1 (resolved in plan):** Is there a designated macOS 26 SwiftUI API for window/popover glass backgrounds (`glassBackgroundEffect`)? — Could not be verified: both candidate DocC paths return 404; the similarly-named API is visionOS-specific. The plan must therefore not depend on it; the verified primitive (`.glassEffect(.regular, in:)` on the root background, no container) is the designated approach.
- **OQ-2 (deferred, non-blocking):** Would the native macOS 26 `NSPopover` appearance alone (no custom SwiftUI background) deliver an equal or better shell? Worth a future experiment; not required to close this spec, and removing the custom shell now would risk losing the shell quality the user already approved.

## References

- Constitution: [AGENTS.md](../../../AGENTS.md)
- Design system: [DESIGN.md](../../../DESIGN.md)
- Regression history: [CHANGELOG.md](../../../CHANGELOG.md) (`0.2.5`, `0.2.11`, `0.2.12`)
- Apple — [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views) (container capture/blend semantics)
- Apple — [GlassEffectContainer](https://developer.apple.com/documentation/swiftui/glasseffectcontainer) ("combines multiple Liquid Glass shapes into a single shape")
- Apple — WWDC25 session 219, [Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/) (Regular vs. Clear preconditions; never mix variants; legibility treatment)
- Apple — WWDC25 session 323, [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/) (glassEffect usage; container grouping intent: "glass cannot sample other glass… share their sampling region")
