---
name: apple-liquid-glass
description: Designs and implements Apple Liquid Glass interfaces across iOS 26, iPadOS 26, macOS Tahoe (26), tvOS 26, visionOS 26, and watchOS 26. Use when building, reviewing, or refactoring any UI on Apple platforms with the Liquid Glass material — SwiftUI `.glassEffect()`, `GlassEffectContainer`, `glassEffectID`, AppKit `NSGlassEffectView`, or when auditing an existing app for Liquid Glass compliance. Pairs with the companion DESIGN.md in this skill for concrete tokens, components, and do's and don'ts.
---

# Apple Liquid Glass

Liquid Glass is Apple's dynamic, real-time-rendered meta-material introduced at WWDC 2025 and shipped in iOS 26 / macOS Tahoe (26) and siblings. It is **not a blur**. It is a digital material that dynamically **bends, shapes, and concentrates light** (Apple calls this *lensing*) and behaves like a lightweight liquid — fluid, gel-like, and responsive to touch, motion, and the content beneath it. It refracts, reflects, casts dynamic shadows, and adapts to light/dark context automatically.

This skill teaches an agent to design, build, and review Liquid Glass interfaces. It is paired with `DESIGN.md` (same directory), which holds the actual machine-readable design tokens, component recipes, and prose rationale that an agent should reference when generating code.

## When to load this skill

- Building a new SwiftUI / UIKit / AppKit screen on iOS 26+, iPadOS 26+, macOS 26+, tvOS 26+, visionOS 26+, or watchOS 26+.
- Auditing or refactoring an existing Apple-platform UI toward Liquid Glass.
- Designing layered app icons (Icon Composer).
- Reviewing for accessibility, contrast, or layout regressions caused by glass.
- Choosing between `glassEffect(.regular)` / `.clear` / `.identity`, or between `.buttonStyle(.glass)` / `.glassProminent`.
- Deciding whether something belongs in the **content layer** (no glass) or the **navigation layer** (glass).

If the project is targeting macOS 15 or earlier, glass is unavailable — fall back to `.ultraThinMaterial` and stop. Don't pretend the platform supports Liquid Glass.

## The five principles (memorize these)

These come straight from Apple's "Meet Liquid Glass" (WWDC25 Session 219) and the Human Interface Guidelines. Every design decision must be tested against them.

1. **Navigation layer only.** Liquid Glass floats *above* content. It is for toolbars, tab bars, sidebars, sheets, popovers, menus, floating actions, and controls. **Never** put glass on lists, tables, media, scrollable content, or stacked on top of other glass.
2. **Lensing, not blur.** Glass concentrates light, not scatters it. A `Rectangle().fill(.ultraThinMaterial)` is **not** Liquid Glass — it's a 2014-era fallback. Use `.glassEffect()`.
3. **Adaptivity is built in.** Multi-layer composition continuously shifts tint, shadows, dynamic range, and (for small elements) flips between light/dark to stay legible over any background. Don't override this unless you have a measured reason.
4. **Concentricity with hardware.** On modern rounded Apple hardware, glass controls nest concentrically with the device / window corner radius. Use `RoundedRectangle(cornerRadius: .containerConcentric, style: .continuous)` for anything that must align with the container.
5. **Accessibility travels with the system.** Reduced Transparency, Increase Contrast, Reduce Motion, and the iOS 26.1+ Tinted-mode toggle all apply **automatically** to `.glassEffect()`. Don't fight the system; don't manually reproduce these states.

## Variants (pick one — never mix)

| Variant       | When to use                                                       | Adaptivity              | Notes                                                                 |
| ------------- | ----------------------------------------------------------------- | ----------------------- | --------------------------------------------------------------------- |
| `.regular`    | Default. Any size, any content, anything on top.                  | Full. Legible always.   | The right answer 95% of the time.                                     |
| `.clear`      | Small, floating controls over **media-rich** content.             | Limited. Needs dimming. | All three must be true: over media-rich, dimming acceptable, bold+bright foreground. |
| `.identity`   | Conditional disable (e.g. on macOS 15 fallback or state toggles). | None. No effect.        | Use `glassEffect(shouldShow ? .regular : .identity)` for cheap toggles. |

`.regular` and `.clear` **must never be mixed in the same view** — they have incompatible lighting models.

## The four SwiftUI APIs (the whole surface)

1. `.glassEffect(_:in:isEnabled:)` — apply the material to a view.
2. `GlassEffectContainer(spacing:)` — share a sampling region between nearby glass elements so they morph and render consistently.
3. `.glassEffectID(_:in:)` — pair views inside a container so they **morph** into each other on state change (e.g. collapsed → expanded cluster).
4. `ButtonStyle.glass` / `ButtonStyle.glassProminent` — purpose-built glass buttons (always prefer these over hand-rolled `Button { }.glassEffect()`).

Optional modifiers on `Glass`:

- `.tint(_:)` — convey semantic meaning on the **single** most important action per screen. Never tint everything.
- `.interactive()` — touch/press feedback, scaling, shimmer. iOS. Sparingly.

## Quick reference: macOS-first patterns

For menu-bar / popover / panel work (the dominant case in this repo):

```swift
// Status-bar popover body (macOS 26)
struct GrowattPopoverView: View {
    @Bindable var viewModel: InverterViewModel

    var body: some View {
        GlassEffectContainer(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                BatteryIndicatorView(level: viewModel.batterySoC, state: viewModel.state)
                    .glassEffect(.regular, in: .rect(cornerRadius: .containerConcentric))

                HStack(spacing: 12) {
                    PowerMetricTileView(metric: .solar,   value: viewModel.solarKW)
                    PowerMetricTileView(metric: .grid,    value: viewModel.gridKW)
                    PowerMetricTileView(metric: .load,    value: viewModel.loadKW)
                }
                .glassEffect(.regular, in: .capsule)

                PowerFlowBadgeView(state: viewModel.state)
                    .glassEffect(.regular.interactive(), in: .circle)
            }
            .padding(20)
        }
    }
}
```

For multi-state expansion (collapsed FAB → expanded cluster):

```swift
struct ActionCluster: View {
    @State private var expanded = false
    @Namespace private var glass

    var body: some View {
        GlassEffectContainer(spacing: 24) {
            VStack(spacing: 12) {
                if expanded {
                    actionButton("rotate.right", id: "rotate")
                    actionButton("flip.horizontal", id: "flip")
                }
                Button {
                    withAnimation(.bouncy) { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "xmark" : "plus")
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(.accentColor)
                .glassEffectID("toggle", in: glass)
            }
        }
    }
}
```

For the macOS 15 fallback (no Liquid Glass):

```swift
extension View {
    @ViewBuilder
    func glassedEffect<S: Shape>(in shape: S = .capsule, interactive: Bool = false) -> some View {
        if #available(macOS 26, *) {
            self.glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
        } else {
            self.background(
                shape
                    .fill(.ultraThinMaterial)
                    .overlay(shape.stroke(.white.opacity(0.2), lineWidth: 1))
            )
        }
    }
}
```

## Audit checklist (use this when reviewing an existing app)

Walk the screen top-to-bottom and answer each question. If "no", refactor.

- [ ] Every glass surface is in the **navigation / control layer**, never on content.
- [ ] No glass is stacked on top of glass.
- [ ] Multiple nearby glass elements are wrapped in a single `GlassEffectContainer`.
- [ ] Morphing transitions between states use a `Namespace` + `.glassEffectID(_:in:)`.
- [ ] Buttons use `.buttonStyle(.glass)` or `.glassProminent`, not hand-rolled `Button { }.glassEffect()`.
- [ ] Tint is used on at most **one** primary action per screen.
- [ ] Rounded rectangles that must align with the device use `cornerRadius: .containerConcentric`.
- [ ] `.regular` and `.clear` are not mixed in the same view.
- [ ] Glass is gated with `if #available(macOS 26, *)` (or platform equivalent).
- [ ] The macOS 15 fallback path produces a usable UI, not a layout shift.
- [ ] No custom `RoundedRectangle().fill(.ultraThinMaterial)` is masquerading as glass.
- [ ] Accessibility is automatic — no manual `accessibilityReduceTransparency` overrides unless measured.
- [ ] Text on glass is high contrast; no thin gray labels on a clear variant over a busy background.
- [ ] Performance: continuous animations on glass are rare; steady states are steady.

## Anti-patterns (these are wrong, full stop)

- ❌ `HStack { Tile1().glassEffect(); Tile2().glassEffect() }` — must be inside a `GlassEffectContainer`.
- ❌ `List { ... }.glassEffect()` — glass on content. Lose the glass.
- ❌ `RoundedRectangle().fill(.ultraThinMaterial)` and calling it "glass". It's not.
- ❌ `.glassEffect(.clear)` over a plain background. Needs media-rich content + dimming.
- ❌ Tinting every button. Tint conveys **meaning**, not decoration.
- ❌ Stacking `glassEffect` on parent and child.
- ❌ `presentationBackground(.thickMaterial)` for "more glass". Use `.regular` or `.clear`.
- ❌ Overriding `accessibilityReduceTransparency` to force a non-glass look. Trust the system.

## Performance & battery

Apple silicon renders Liquid Glass in real time. The cost is real but manageable:

- One `GlassEffectContainer` per logical group; don't nest.
- Steady states are steady — don't keep spinning a glass dial.
- `glassEffect(condition ? .regular : .identity)` is essentially free to toggle.
- Test on iPhone 11 / iPhone 12 / Intel Mac before shipping; older GPUs feel the cost.
- Profile with Instruments → GPU Frame Capture if you ship heavy glass.

## What this skill does **not** cover

- Detailed Icon Composer workflow (refer to WWDC25 Session 361 and the Apple Icon Composer docs).
- Layered app-icon token values (covered in `DESIGN.md` at a high level; for production icons use Icon Composer directly).
- visionOS-specific volumetric glass patterns (refer to WWDC25 Session 219 and the visionOS HIG).
- Migration from `NSVisualEffectView` / `UIVisualEffectView` — covered in WWDC25 Session 310 (AppKit) and the Apple *Adopting Liquid Glass* tech overview.

## Companion files

- `DESIGN.md` — The machine-readable design system in Google Labs' open-source DESIGN.md format (YAML frontmatter + markdown). **Always read `DESIGN.md` before generating any code on Apple platforms.** It contains the actual color, typography, spacing, shape, and component tokens an agent should use.

## Authoritative references (re-verify before shipping)

- Apple, *Meet Liquid Glass* — WWDC25 Session 219.
- Apple, *Build a SwiftUI app with the new design* — WWDC25 Session 323.
- Apple, *Build an AppKit app with the new design* — WWDC25 Session 310.
- Apple, *Create icons with Icon Composer* — WWDC25 Session 361.
- Apple, *Say hello to the new look of app icons* — WWDC25 Session 220.
- Apple Developer Documentation — *Adopting Liquid Glass* (technology overview).
- Apple Developer Documentation — `Glass`, `GlassEffectContainer`, `glassEffectID` in SwiftUI.
- Human Interface Guidelines — *Materials*.

When a public API on this page is in doubt, re-verify against the Apple docs (use the `context7` skill) before recommending it.
