---
version: alpha
name: Apple Liquid Glass
description: The design system for Apple platforms (iOS 26, iPadOS 26, macOS Tahoe 26, tvOS 26, visionOS 26, watchOS 26) using the Liquid Glass material. Use for any UI generation, refactor, or review on these platforms.
colors:
  # Primary (Apple's accent). The single driver of intentional color on Liquid Glass.
  # CSS value is the iOS 18 / macOS 15 default blue; Apple tunes it per release.
  # In SwiftUI, prefer Color.accentColor at runtime so the user's chosen accent is honored.
  primary: "oklch(62% 0.18 255)"
  primary-container: "oklch(92% 0.04 255)"
  on-primary: "#FFFFFF"
  on-primary-container: "oklch(25% 0.08 255)"

  # Semantic status — used in banners, error states, success toasts.
  success: "oklch(68% 0.16 150)"
  warning: "oklch(78% 0.15 80)"
  error: "oklch(60% 0.22 25)"
  info: "oklch(65% 0.14 230)"

  # Neutrals — used for text and structural lines on glass.
  # These are mid-tone defaults from iOS 18 / macOS 15 Light appearance.
  # In SwiftUI, prefer the system semantic colors (UIColor.label, .secondaryLabel, etc.)
  # so the UI adapts to light/dark, Increase Contrast, and accessibility settings automatically.
  label: "oklch(15% 0 0)"           # ≈ UIColor.label (Light)
  label-secondary: "oklch(40% 0 0)" # ≈ UIColor.secondaryLabel (Light)
  label-tertiary: "oklch(60% 0 0)"  # ≈ UIColor.tertiaryLabel (Light)
  label-quaternary: "oklch(80% 0 0)" # ≈ UIColor.quaternaryLabel (Light)
  separator: "oklch(85% 0 0)"       # ≈ UIColor.separator (Light)
  fill: "oklch(50% 0 0 / 0.20)"     # ≈ UIColor.systemFill (Light)
  fill-secondary: "oklch(50% 0 0 / 0.16)"

  # Pure anchors — used only when a design system primitive must not adapt
  # (e.g. SVG assets, print styles, SF Symbol fallbacks).
  ink: "oklch(0% 0 0)"
  paper: "oklch(100% 0 0)"

typography:
  # Display — large expressive numerals (e.g. Lock Screen clock).
  display:
    fontFamily: "SF Pro Display"
    fontSize: 57px
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: -0.02em
  display-sm:
    fontFamily: "SF Pro Display"
    fontSize: 44px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -0.015em

  # Headings — SwiftUI native sizes. Use these for popover titles, sheet headers, sidebar headers.
  large-title:
    fontFamily: "SF Pro Display"
    fontSize: 34px
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: -0.01em
  title-1:
    fontFamily: "SF Pro Display"
    fontSize: 28px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: -0.005em
  title-2:
    fontFamily: "SF Pro Display"
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.25
  title-3:
    fontFamily: "SF Pro Text"
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.3
  headline:
    fontFamily: "SF Pro Text"
    fontSize: 17px
    fontWeight: 600
    lineHeight: 1.35

  # Body — long-form text inside popovers, sheets, sidebars.
  body:
    fontFamily: "SF Pro Text"
    fontSize: 17px
    fontWeight: 400
    lineHeight: 1.4
  body-emphasized:
    fontFamily: "SF Pro Text"
    fontSize: 17px
    fontWeight: 600
    lineHeight: 1.4
  callout:
    fontFamily: "SF Pro Text"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.4
  subheadline:
    fontFamily: "SF Pro Text"
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.35
  footnote:
    fontFamily: "SF Pro Text"
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.3
  caption-1:
    fontFamily: "SF Pro Text"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.3
  caption-2:
    fontFamily: "SF Pro Text"
    fontSize: 11px
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: 0.02em

  # Numeric — for live telemetry (battery %, kW). Use tabular features.
  numeric:
    fontFamily: "SF Pro"
    fontSize: 34px
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: -0.01em
    fontFeature: "tnum 1, lnum 1"
  numeric-sm:
    fontFamily: "SF Pro"
    fontSize: 17px
    fontWeight: 500
    lineHeight: 1.2
    fontFeature: "tnum 1, lnum 1"

  # Rounded (corner radius scale — used on glass shapes).
rounded:
  none: 0px
  sm: 6px
  md: 10px
  lg: 16px
  xl: 20px
  xxl: 28px
  full: 9999px
  container-concentric: 0px   # Resolved at runtime by SwiftUI to the container's corner radius

  # Spacing — Apple's effective scale is a 4/8 hybrid.
spacing:
  # Micro
  hairline: 1px
  xxs: 2px
  xs: 4px
  sm: 8px
  # Standard
  md: 12px
  lg: 16px
  xl: 20px
  # Macro
  xxl: 24px
  xxxl: 32px
  # Layout primitives
  edge: 16px          # Standard edge inset for popover/sheet content
  edge-mac: 20px      # macOS popover edge inset (per Apple HIG popover spec)
  toolbar: 44px       # Toolbar item hit target
  toolbar-mac: 52px   # macOS toolbar item hit target
  min-tap: 44px       # WCAG / Apple minimum touch target

components:
  # ── Buttons ───────────────────────────────────────────────────────────────
  button-glass:
    typography: "{typography.callout}"
    backgroundColor: "tint.clear"        # Liquid Glass .regular, untinted
    textColor: "{colors.label}"
    rounded: "{rounded.full}"
    padding: 12px
    size: 44px                          # Apple minimum touch target
    height: 32px
    width: 32px
  button-glass-hover:
    backgroundColor: "tint.clear.elevated" # Subtle elevation cue, NOT a separate glass
    textColor: "{colors.label}"
  button-glass-pressed:
    backgroundColor: "tint.clear.pressed"
    textColor: "{colors.label}"
  button-glass-disabled:
    backgroundColor: "tint.clear.muted"
    textColor: "{colors.label-tertiary}"

  button-glass-prominent:
    typography: "{typography.callout}"
    backgroundColor: "tint.prominent"     # Liquid Glass .glassProminent
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    padding: 12px
    size: 44px                          # Apple minimum touch target
    height: 32px
    width: 32px
  button-glass-prominent-hover:
    backgroundColor: "tint.prominent.elevated"
    textColor: "{colors.on-primary}"
  button-glass-prominent-disabled:
    backgroundColor: "tint.prominent.muted"
    textColor: "{colors.on-primary-container}"

  # ── Toolbar (macOS / iPadOS top bar) ──────────────────────────────────────
  toolbar-mac:
    typography: "{typography.subheadline}"
    backgroundColor: "surface.glass.toolbar"
    textColor: "{colors.label}"
    rounded: "{rounded.container-concentric}"
    padding: 0
    height: "{spacing.toolbar-mac}"
  toolbar-ios:
    typography: "{typography.body-emphasized}"
    backgroundColor: "surface.glass.toolbar"
    textColor: "{colors.label}"
    rounded: "{rounded.lg}"
    padding: 0
    height: "{spacing.toolbar}"

  # ── Sidebar (NavigationSplitView) ─────────────────────────────────────────
  sidebar:
    typography: "{typography.subheadline}"
    backgroundColor: "surface.glass.sidebar"
    textColor: "{colors.label}"
    rounded: "{rounded.container-concentric}"
    padding: "{spacing.sm}"
    width: 232px
  sidebar-item:
    typography: "{typography.subheadline}"
    backgroundColor: "tint.clear"
    textColor: "{colors.label}"
    rounded: "{rounded.md}"
    padding: 8px
    height: 32px
  sidebar-item-selected:
    backgroundColor: "tint.selected"
    textColor: "{colors.label}"
    rounded: "{rounded.md}"
    padding: 8px
    height: 32px

  # ── Tab Bar (iOS / iPadOS bottom; macOS sidebar) ─────────────────────────
  tab-bar:
    backgroundColor: "surface.glass.tabbar"
    rounded: "{rounded.full}"
    padding: 4px
    height: 50px
  tab-item:
    typography: "{typography.caption-2}"
    backgroundColor: "tint.clear"
    textColor: "{colors.label-secondary}"
    rounded: "{rounded.full}"
    size: 48px
  tab-item-selected:
    backgroundColor: "tint.clear.elevated"
    textColor: "{colors.label}"
    rounded: "{rounded.full}"
    size: 48px

  # ── Cards (floating, over content) ───────────────────────────────────────
  card:
    typography: "{typography.body}"
    backgroundColor: "surface.glass.card"
    textColor: "{colors.label}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"
  card-metric:
    typography: "{typography.numeric}"
    backgroundColor: "surface.glass.card"
    textColor: "{colors.label}"
    rounded: "{rounded.lg}"
    padding: "{spacing.md}"
    width: 140px
    height: 96px

  # ── Sheet / Popover ─────────────────────────────────────────────────────
  sheet:
    backgroundColor: "surface.glass.sheet"
    textColor: "{colors.label}"
    rounded: "{rounded.xxl}"
  popover-mac:
    backgroundColor: "surface.glass.popover"
    textColor: "{colors.label}"
    rounded: "{rounded.lg}"
    padding: "{spacing.edge-mac}"
    width: 320px
  popover-ios:
    backgroundColor: "surface.glass.popover"
    textColor: "{colors.label}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"

  # ── Floating action (FAB / power-flow badge) ───────────────────────────
  fab:
    backgroundColor: "tint.prominent"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    size: 56px
  fab-mini:
    backgroundColor: "tint.clear"
    textColor: "{colors.label}"
    rounded: "{rounded.full}"
    size: 36px

  # ── Status bar item (macOS menu bar) ────────────────────────────────────
  status-bar:
    typography: "{typography.caption-1}"
    backgroundColor: "tint.clear"
    textColor: "{colors.label}"
    padding: 0

  # ── Toggle / Slider (system) ───────────────────────────────────────────
  toggle:
    backgroundColor: "tint.prominent"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
  slider:
    backgroundColor: "tint.clear"
    textColor: "{colors.label-secondary}"
    rounded: "{rounded.full}"
    height: 24px

  # ── Menu (context) ─────────────────────────────────────────────────────
  menu:
    backgroundColor: "surface.glass.menu"
    textColor: "{colors.label}"
    rounded: "{rounded.lg}"
    padding: "{spacing.xs}"
  menu-item:
    typography: "{typography.subheadline}"
    backgroundColor: "tint.clear"
    textColor: "{colors.label}"
    rounded: "{rounded.md}"
    padding: 6px
    height: 28px
  menu-item-hover:
    backgroundColor: "tint.accent.muted"
    textColor: "{colors.label}"
    rounded: "{rounded.md}"
    padding: 6px
    height: 28px

  # ── Search field ───────────────────────────────────────────────────────
  search-field:
    typography: "{typography.body}"
    backgroundColor: "surface.glass.search"
    textColor: "{colors.label}"
    rounded: "{rounded.full}"
    padding: "{spacing.sm}"
    height: 36px
  search-field-ios:
    typography: "{typography.body}"
    backgroundColor: "surface.glass.search"
    textColor: "{colors.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
    height: 36px

  # ── Notification / Banner ──────────────────────────────────────────────
  banner:
    backgroundColor: "surface.glass.banner"
    textColor: "{colors.label}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"
  banner-error:
    backgroundColor: "tint.error.muted"
    textColor: "{colors.error}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"
  banner-success:
    backgroundColor: "tint.success.muted"
    textColor: "{colors.success}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"
  banner-warning:
    backgroundColor: "tint.warning.muted"
    textColor: "{colors.warning}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"
  banner-info:
    backgroundColor: "tint.info.muted"
    textColor: "{colors.info}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"

  # ── Print / icon fallback ─────────────────────────────────────────────
  # Used only for assets that must not adapt to system appearance
  # (SVG exports, SF Symbol fallbacks, print stylesheets).
  icon-fallback:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    size: 24px
  print-surface:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    padding: "{spacing.lg}"

  # ── Structural primitives ────────────────────────────────────────────
  # Hairline divider for separating rows inside a glass surface.
  divider:
    backgroundColor: "{colors.separator}"
    height: 1px
    padding: 0
  # Filled overlay used to dim the content beneath a sheet or modal.
  overlay-dim:
    backgroundColor: "{colors.fill}"
    padding: 0
  # Soft selection background (e.g. highlighted text, focused row).
  selection-background:
    backgroundColor: "{colors.fill-secondary}"
    padding: 0
  # Disabled icon — uses label-quaternary so it always recedes visually.
  # Intentionally low contrast is the semantic of a disabled control.
  icon-disabled:
    textColor: "{colors.label-quaternary}"
    size: 24px
  # Placeholder text inside a search or input field.
  placeholder-text:
    typography: "{typography.body}"
    textColor: "{colors.label-quaternary}"
    padding: 0
---

# Apple Liquid Glass

## Overview

**Liquid Glass** is the unified design language for Apple platforms introduced at WWDC 2025 and shipped across iOS 26, iPadOS 26, macOS Tahoe (26), tvOS 26, visionOS 26, and watchOS 26. It is a real-time-rendered **digital meta-material** that *bends and concentrates light* (Apple calls this *lensing*) rather than scattering it, and behaves like a lightweight liquid — fluid, gel-like, responsive to touch and motion.

The visual personality is **translucent, dynamic, weightless**. It evokes physical glass but adapts intelligently: highlights move with geometry, shadows deepen over text and lighten over solid backgrounds, colors are pulled from surrounding content, and the surface flips between light and dark to stay legible in any context. The emotional response we want is *vitality without distraction* — controls that feel alive and layered above content, but never compete with it.

**Hierarchy is non-negotiable.** Liquid Glass is reserved for the **navigation layer** that floats above the **content layer**. Content (lists, tables, media, scrollable text) lives beneath, untouched. A single floating glass plane is the rule: never stack glass on glass. The system uses lenses, tints, dynamic shadows, and specular highlights as the depth language — there is no separate elevation system; depth *is* the material.

The visual contract is the same on every Apple platform. What changes is the **scale** of the glass surface, the **density** of the controls, and the **concentricity** with which controls nest into the rounded corners of the device or window.

## Colors

The palette is **restrained by design**. Liquid Glass does most of the visual work through refraction, shadow, and dynamic range. Color is a **signal**, not decoration.

- **Accent** is the single driver of intentional color. Apply it to the **most important action on a screen** — never to every button. On glass, the system tints through the material rather than painting a solid fill; the result is a hue that shifts with the content beneath it, like colored glass in the real world.
- **Semantic status** (`success`, `warning`, `error`, `info`) is used sparingly: validation states, error banners, system notifications, and progress indicators. Never as decoration.
- **Neutrals** are the workhorses. Always prefer Apple **system semantic colors** (`LabelColor`, `SeparatorColor`, `systemFillColor`, etc.) so the UI adapts automatically to light/dark, Increase Contrast, and the user's accent color. Resolve them at runtime, never hardcode the hex.
- **Ink / Paper** exist only as escape hatches for cases where a design system primitive (an SVG asset, an SF Symbol fallback) must not adapt.

The accent and semantic colors are expressed in `oklch()` so the design system can target wide-gamut displays (Display P3) without losing perceptual uniformity across platforms.

## Typography

Liquid Glass inherits Apple's **SF Pro** type system unchanged. Typography is a primary tool for hierarchy on glass because **text and glyphs are the elements that flip between light and dark** to maintain contrast as the surface changes. The right type ramp makes the glass legible; the wrong one is the first place contrast fails.

- **Display / large-title** — Lock-screen scale, hero numerals, full-bleed marketing. Used on glass only when the glass is the focal element (e.g. status bar item numerals).
- **Title 1–3 / Headline** — Popover titles, sheet headers, sidebar section titles, prominent controls. The workhorses on glass.
- **Body / Callout** — Default reading text inside popovers, sheets, and sidebars.
- **Subheadline / Footnote** — Secondary metadata, timestamps, helper text.
- **Caption 1–2** — Toolbar labels, tab bar labels, status bar text. **Always set `lineHeight` tightly** (`1.2`–`1.3`); loose caption leading looks broken on a 1-pixel-tall toolbar.
- **Numeric / numeric-sm** — Live telemetry (battery %, kW, temperatures). Always enable **tabular numerals** (`tnum`) so values don't jitter as they update.

Dynamic Type is mandatory. Every text style scales with the user's preferred size. Test at the largest accessibility size.

## Layout

The layout model is a **4 / 8 hybrid grid** with **container-aware safe areas**. Liquid Glass is edge-aware: controls sit concentrically inside the rounded corners of the device or window, separated from the bezel by a uniform edge inset. On macOS this is `20px`; on iOS / iPadOS it is `16px`.

- **Spacing scale** follows Apple's effective rhythm: `4 → 8 → 12 → 16 → 20 → 24 → 32`. Use `xxs` (2px) and `hairline` (1px) only for optical adjustments — never for structural layout.
- **Touch / hit targets** are `44pt` minimum (Apple HIG / WCAG 2.5.5). macOS toolbar items are `52pt` for cursor ergonomics.
- **Popovers and sheets** are content-first: their internal layout is a `VStack` of glass atoms with `16–24px` of outer padding, never full-bleed.
- **Sidebars** are `232pt` wide on iPadOS / macOS, with a single column of `32pt`-tall selectable rows. They are not lists — they are navigation.
- **Tab bars** shrink on scroll down and expand on scroll up (iOS), giving content maximum focus while keeping navigation one tap away.
- **Toolbar** items are clustered using `ToolbarSpacer(.fixed, spacing: 20)` so related actions group visually and the primary action is unambiguously the right-most glass surface.

## Elevation & Depth

Depth on Liquid Glass is **the material itself**, not a separate shadow system. There is no `--elevation-1`, `--elevation-2`, `--elevation-3` — there is one floating glass plane, and depth is communicated by:

- **Lens intensity** — the bending of light is stronger on larger surfaces (sidebars, sheets) and softer on small controls (toolbar buttons, tab items).
- **Dynamic shadows** — opacity is computed by the system based on what's underneath. Over text, the shadow deepens to maintain separation. Over a white background, it nearly disappears.
- **Specular highlights** — light sources in the environment reflect off the glass and move with device motion. They define the silhouette of every control.
- **Tint** — the only "intentional" depth cue, used for the single most important action per screen.

Larger glass surfaces are perceived as **thicker material**: a sidebar casts deeper shadows and refracts more aggressively than a toolbar button. This is built in; do not override it.

**Never** stack two glass surfaces. A `HStack` of glass tiles is fine; a `VStack` of glass cards is not. If two surfaces must overlap, the top one uses a **fill + vibrancy** rather than its own glass material.

## Shapes

Apple's shape language is **rounded by default, concentric with the container, continuous in style**. There is one corner-radius value that changes everything: **`containerConcentric`**.

- **`containerConcentric`** is a runtime-resolved radius. Set on a `RoundedRectangle` and the shape automatically matches the device bezel, window, or parent surface it lives inside. Use it for **every** glass surface that should align with its container — toolbars, sheets, popovers, sidebars, cards that fill a frame.
- **`full` (`9999px`)** is the default for buttons, tab items, and floating actions. It produces the "pill" that defines interactive controls.
- **`lg` (16px) → `xl` (20px) → `xxl` (28px)** are the descending radius scale for cards, sheets, and popovers.
- **Always** use `RoundedRectangle(..., style: .continuous)`. The `.continuous` corner style is the soft, squircle-like curve Apple introduced with iOS 13; the default `.circular` style looks visibly wrong on glass.

Square corners and minimal radii (`sm`, `md`) are reserved for **status bar / menu bar** content where vertical real estate is at a premium.

## Components

Components are the **reusable glass atoms** an agent should reach for first. Every component is a `GlassEffectContainer` (or a `glassEffect(...)` modifier on a single view) — never a hand-rolled `RoundedRectangle().fill(.ultraThinMaterial)`.

### Buttons

**Two button styles, no more.**

- **`buttonStyle(.glass)`** — translucent, see-through. Secondary actions, cancel, dismiss.
- **`buttonStyle(.glassProminent)`** — opaque-prominent, the single primary action on a screen. Tint with `.accentColor`.

Tint at most **one button** per screen. Tint is a **meaning signal**, not decoration. A primary action that doesn't need tinting is better than five tinted buttons that compete.

Sizing: `controlSize(.regular)` by default; use `.large` for hero CTAs. Border shape: `.capsule` for pills, `.circle` for floating actions (with the documented `.clipShape(Circle())` workaround for the iOS 26.0–26.1 prominent-circle artifact).

### Toolbar (macOS / iPadOS)

Top-of-window chrome. `surface.glass.toolbar` with `.containerConcentric` corner radius. Items are clustered via `ToolbarItemGroup` separated by `ToolbarSpacer(.fixed, spacing: 20)`. The confirmation action automatically receives `.glassProminent`.

### Sidebar (NavigationSplitView)

`surface.glass.sidebar` with `.containerConcentric`. Single-column navigation. `sidebar-item` rows are `32pt` tall with `8px` padding; selected state uses a `tint.selected` glass fill — not a solid color. Backgrounds extend beyond safe area via `.backgroundExtensionEffect()` to feel immersive.

### Tab Bar

`surface.glass.tabbar` in a pill (`rounded.full`). Tab items are `48pt` circular tap targets. iOS tab bars minimize on scroll (`.tabBarMinimizeBehavior(.onScrollDown)`); macOS uses the system sidebar instead.

### Card (Floating)

`surface.glass.card` in a `.xl` continuous rounded rectangle. Used for floating, non-navigational content. **Not** for stacked list rows. Cards never nest inside other cards.

### Sheet / Popover

Sheets and popovers receive glass automatically in iOS 26 / macOS 26 when you stop painting your own background. For partial-height sheets the glass materializes at the small detent and becomes more opaque as it expands. Popovers on macOS use the `popover-mac` template; on iOS / iPadOS use `popover-ios`.

### Floating Action / Power-Flow Badge

`fab` (56pt) for primary floating actions; `fab-mini` (36pt) for secondary floating controls. Both are `.glassProminent` tinted with the system accent. Always circular.

### Status Bar (macOS menu bar)

`status-bar` — `NSStatusItem` with a template icon and a numeric title. The icon and text respond to the system appearance. Re-arm `withObservationTracking` whenever the value changes; don't drive it from a timer.

### Toggle / Slider

System components — they adopt Liquid Glass automatically when compiled with the iOS 26 / macOS 26 SDK. Do not re-implement.

### Menu (context)

`surface.glass.menu` with `menu-item` rows. Selected / hover state uses `tint.accent.muted`, **not** a solid color. Menus are popovers and are part of the navigation layer.

### Search Field

`search-field` is the macOS pill; `search-field-ios` is the iOS rectangle with `rounded.md`. Both use `surface.glass.search`. When using `.searchable`, let the system apply glass automatically.

### Notification / Banner

`banner` for neutral; `banner-error` for destructive. Banners are part of the **overlay** layer — they use glass but never tint with the action color. The error color is reserved for the text / glyph.

## Do's and Don'ts

### Do

- ✅ Use `.glassEffect(.regular)` as the default and reach for `.clear` only over media-rich content.
- ✅ Wrap every group of two or more nearby glass elements in a `GlassEffectContainer(spacing:)`.
- ✅ Use `RoundedRectangle(cornerRadius: .containerConcentric, style: .continuous)` for anything that should nest with its container.
- ✅ Reach for `ButtonStyle.glass` / `.glassProminent` before hand-rolling a `Button { }.glassEffect()`.
- ✅ Use `glassEffectID(_:in:)` with a `Namespace` to morph between collapsed and expanded states.
- ✅ Tint at most **one** primary action per screen, with the system accent.
- ✅ Gate every glass modifier with `if #available(macOS 26, *)` / `if #available(iOS 26, *)` and provide a `.ultraThinMaterial` fallback.
- ✅ Trust system accessibility (Reduced Transparency, Increase Contrast, Reduce Motion, iOS 26.1+ Tinted mode) — do not override it.
- ✅ Test in light **and** dark appearance, with Increase Contrast on, and at the largest Dynamic Type size.
- ✅ Use SF Pro tabular numerals (`tnum`) for any value that updates live.

### Don't

- ❌ Put glass on content. No glass on lists, tables, media, scroll views, or stacked rows.
- ❌ Stack glass on glass. If two surfaces overlap, the top one is a **fill + vibrancy**, not glass.
- ❌ Mix `.regular` and `.clear` in the same view — they have incompatible lighting models.
- ❌ Tint every button. Tint is a meaning signal; one per screen.
- ❌ Replace `.glassEffect()` with `RoundedRectangle().fill(.ultraThinMaterial)` and call it "glass". It's a 2014-era fallback.
- ❌ Wrap a `Menu` inside a `GlassEffectContainer` on iOS 26.0–26.1 (morphing breaks); use `.glassEffect(.regular.interactive())` on the menu itself.
- ❌ Use `.glassProminent` with `.buttonBorderShape(.circle)` without also adding `.clipShape(Circle())` on iOS 26.0–26.1 (rendering artifact).
- ❌ Hardcode light/dark colors. Use system semantic colors so the UI adapts to the user's appearance and accessibility settings.
- ❌ Manually re-implement Reduced Transparency or Increase Contrast. The system does this for `.glassEffect()`.
- ❌ Animate glass continuously. Steady states should rest; morph only on user-initiated state change.
- ❌ Use glass over a plain background. The material shines over varied content; on a flat color it looks like a grey rectangle.
