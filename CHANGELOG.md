# Changelog

All notable changes to **Growatt Toolbar Status** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.4.0 (2026-07-31)

---

### Added

- Settings/onboarding window: native macOS window (`SettingsView` + `SettingsWindowController`) for entering API key and URL. Shows automatically on first launch, reopenable via right-click → "Settings…" on the status bar item.
- Right-click context menu on status bar item with "Settings…" and "Quit" actions.
- Credentials now persist across launches via `UserDefaults` (`apiKey`, `apiURL` keys) after onboarding completes, with `.env` as a fallback.
- Full accessibility labels and hints on all settings form controls.
- macOS 26 Liquid Glass `.glassEffect()` background on settings window with `.ultraThinMaterial` fallback on macOS 15.

### Changed

- `AppDelegate` now detects first launch (`hasCompletedOnboarding` flag) and routes to onboarding or straight to menu bar mode.
- `StatusBarController` now exposes `viewModel` as `private(set)` for lifecycle management on re-save.
- `StatusBarController.deinit` cleans up the `NSStatusItem` via `NSStatusBar.system.removeStatusItem` to prevent leaks on settings re-save.
- `finishSetup()` calls `viewModel.stopAutoRefresh()` on the old controller before replacing it.

## 0.3.4 (2026-07-30)

---

### Refactor

- error banner: remove internal padding so it sits at the popover's shell inset instead of creating a double-padded card-within-card illusion
- error banner: differentiate subtitle per error type — "Check API key" for unauthorized, "Last reading Nm ago" for transient errors
- error banner: center-align the icon against the two-line text block instead of top-aligning
- popover: hide battery bar, divider, and state row in error state to eliminate dead vertical space and redundant divider
- popover: add 250ms ease-in-out crossfade on hero freshness transitions

## 0.3.3 (2026-07-30)

---

### Refactor

- error banner: move the refresh button below a divider line, aligned to the trailing edge, so the icon / headline / last-fetched-time row stays uncluttered

## 0.3.2 (2026-07-30)

---

### Features

- freshness dot is now a binary trust signal in Apple Design System colors: system green while live, system red for awaiting / stale / offline

## 0.3.1 (2026-07-30)

---

### Features

- battery bar fill is now level-aware: green (same green as the charging dot) at or above 60%, shifting to orange below that threshold so the gauge reads as a level alarm at a glance

## 0.3.0 (2026-07-30)

---

### Features

- redesigned popover as a 280pt flat two-column Control Center tile: battery percentage (left) and home load kW (right) in a compact hero with tiny secondary labels, matching the macOS Tahoe 26 native popover aesthetic
- switched to a fully neutral color palette: system semantic colors (`.primary` / `.secondary` / `.tertiary`) plus `Color.accentColor` as the single state signal — no green/orange gradient fills
- new flat single-surface layout: content renders directly on the Regular Liquid Glass shell with hairline dividers for separation; no opaque inner cards (spec 001's adaptive legibility treatment keeps flat-on-glass content sharp at 280pt)
- compact 12pt neutral battery bar: thin gauge conveying fill level only; state direction (charging/discharging) moved to an accent-colored label + dot in the state row
- compact inline state row: accent state badge (`PowerFlowBadgeView`) + freshness trust indicator (`FreshnessIndicatorView`) + compact refresh button (`controlSize(.small)`) in a single horizontal line

### Refactor

- removed the title header ("Growatt Inverter") — the two-column hero identifies the popover; the status bar item carries the app identity
- removed the separate Home Load `PowerMetricTileView` component; the home consumption value now renders inline in the hero right column with `monospacedDigit()` formatting
- removed all opaque `controlBackgroundColor` inner card backgrounds (hero, tile, error banner) — content is now flat on the glass shell
- removed the green/orange gradient stops from `BatteryIndicatorView`; bar uses neutral primary-opacity fills
- deleted `GlassTokens.Radius.tile` and `GlassTokens.Padding.tile` tokens (no remaining consumer)
- collapsed `FreshnessIndicatorView` from a standalone capsule pill into a compact inline dot + text indicator
- flattened `PowerFlowBadgeView` from a tinted-glass capsule into a flat accent label + dot (no glass background)
- reduced `Numeric.hero` from 44pt to 28pt (compact Control Center tile scale)
- reduced popover width from 360pt to 280pt, padding from 18pt to 16pt, spacing from 16pt to 12pt

### Removed

- `PowerMetricTileView.swift` — deleted; home consumption now renders inline in the two-column hero row
- `GlassTokens.Radius.tile` and `GlassTokens.Padding.tile` — deleted; no remaining consumer

## 0.2.0 (2026-07-29)

---

### Features

- add four-state honesty layer (`.awaiting` / `.live` / `.stale` / `.error`) so the popover never lies about the freshness of its data
- add `Freshness` model with display title, leading SF Symbol, tint, and accessibility label
- add `FreshnessIndicatorView` header pill that re-evaluates freshness once per second via `TimelineView`
- add `BatteryIndicatorPlaceholder` with a left-to-right shimmer for the `.awaiting` state, honoring `accessibilityReduceMotion`
- add `ErrorBannerView` that replaces the hero with a designed state in the `.error` condition: energy-specific icon, "Can't reach inverter" headline, "Last reading Nm ago" subtitle, and an inline elevated refresh button
- surface the in-flight `Live` / `Stale` / `Offline` / `Connecting` trust pill in the popover header; the footer `caption2` "Last synced" line is gone, its job moved into the hero

### Refactor

- change `InverterViewModel.errorMessage: String?` to `error: GrowattAPIError?` so the typed error surface is the single source of truth for failure
- add `InverterViewModel.hasReceivedFirstReading: Bool` and seed the popover with a composed placeholder (never `0% / .charging / 0 kW`) until the first successful poll
- add `InverterViewModel.freshness: Freshness` and `secondsSinceLastUpdate: TimeInterval?` as derived state
- replace the footer's "Last synced" `caption2` line with the new hero-anchored freshness story
- in `.error` state, hide the popover footer (the recovery affordance lives inside `ErrorBannerView`)

### Hardening

- add `deinit` to `InverterViewModel` that cancels `pollingTask` and `inFlightRefresh` (guarded by `MainActor.assumeIsolated` since the class is `@MainActor`)
- add `inFlightRefresh: Task<Void, Never>?` to serialize concurrent `refreshData()` invocations — the polling loop and the manual refresh button now share a single in-flight task
- replace the untyped `} catch { self.errorMessage = error.localizedDescription }` in `InverterViewModel.performRefresh()` with `} catch let error as GrowattAPIError { ... } catch { ... }` so the typed `GrowattAPIError.unauthorized` case surfaces a recovery message instead of being swallowed into a generic string
- make the `refreshData()` public API race-safe: concurrent callers await the in-flight task rather than starting parallel polls that race on `isLoading` and last-writer-wins on `status`

## 0.2.1 (2026-07-29)

---

### Polish

- add `GlassTokens.Spacing` namespace (`xs` / `sm` / `md` / `lg` / `xl` / `xxl` / `xxxl` / `xxs` / `hairline`) so the new trust-axis components stop carrying raw spacing literals
- replace the raw `HStack(spacing:)` / `VStack(spacing:)` / `.padding(N)` literals in `GrowattPopoverView`, `FreshnessIndicatorView`, `ErrorBannerView`, and `BatteryIndicatorPlaceholder` with `GlassTokens.Spacing` references
- honor `accessibilityReduceMotion` on the refresh button's rotation in both `GrowattPopoverView` (footer) and `ErrorBannerView` (banner) — the spinner holds at 0° instead of looping for users who opt out of motion
- make the inline "Updated Nm ago" caption's transition conditional on `accessibilityReduceMotion` (identity transition, no animation) so the stale state appears instantly for users who opt out of motion
- remove the duplicated `relativeString(for:)` helper from `GrowattPopoverView`; `ErrorBannerView.relativeString(for:)` is now the single source of truth for time-aware copy

## 0.2.2 (2026-07-29)

---

### Clarify

- drop the misleading "+X.X kW grid power" / "-X.X kW load power" wording from the badge subtitle — `output_power` is *home consumption* (watts the home is currently drawing from the inverter / grid), not battery flow direction; the old sign convention conflated the two concepts
- rename `InverterStatus.formattedPowerDescription` to `InverterStatus.formattedKilowatts` so the formatter's name matches what it actually returns (a localized `X.X kW` value, not a description)
- the badge subtitle now reads as just the consumption value (e.g. `3.2 kW`); the "Home Load" category label is carried by the `PowerMetricTileView` in the popover's metrics row, which is the correct place for it
- rename `PowerFlowBadgeView.powerDescription` parameter to `powerValue` to match the renamed property
- update `GrowattPopoverView` to pass the new `powerValue: viewModel.status.formattedKilowatts` to `PowerFlowBadgeView`
- expand the `InverterStatus.outputPowerKW` doc comment to make the consumption semantic explicit so future code doesn't reintroduce the sign convention

## 0.2.3 (2026-07-29)

---

### Clarify

- remove the consumption value from the battery state badge subtitle so the `output_power` reading lives in only one place — the `PowerMetricTileView` ("Home Load") in the popover's metrics row; the badge now shows only the battery state direction (Charging / Discharging)
- drop the `powerValue` parameter from `PowerFlowBadgeView`; the badge is a pure state indicator, not a duplicated consumption reading
- simplify `PowerFlowBadgeView` from a `VStack` of (pill + subtitle) to a single `HStack` pill — the surrounding `VStack` is no longer needed when there is no second line
- drop the now-unused `InverterStatus.formattedKilowatts` property — there is no consumer left; `PowerMetricTileView` formats the value inline with its "kW" suffix as a separate `Text`, which is the design we want to keep
- update the `InverterStatus.outputPowerKW` doc comment to point to `PowerMetricTileView` as the single rendered surface, so future code does not reintroduce a duplicate reading in the hero

## 0.2.4 (2026-07-29)

---

### Polish

- extract a single `RefreshButton` view (`Views/Components/RefreshButton.swift`) used by both the popover footer and the error banner — closes the duplicated 33-line hand-rolled glass block; one component, two call sites
- use the system `ButtonStyle.glass` on macOS 26+ inside `RefreshButton` instead of a hand-rolled `.glassEffect(.clear.interactive(), …)`; falls back to `ButtonStyle.bordered` on macOS 15
- bump the refresh control to `controlSize(.regular)` (44pt hit target, the Apple HIG / WCAG minimum); the old hand-rolled 32pt frame is gone
- add `.disabled(isLoading)` to the refresh control so the user gets a clear visual cue during in-flight refreshes (no more "I clicked it, nothing happened" perception)
- fix the `ErrorBannerView` hero card so it honors `accessibilityReduceTransparency` (a `.regularMaterial` fallback to `Color(nsColor: .windowBackgroundColor)` when the user has Reduce Transparency on)
- delete the dead `footerDetail` property and its inner `if let` branch in the popover footer — the property always returned `nil` and the comment explaining why was longer than the code
- inline `staleSubtitleColor` (which returned `.orange` unconditionally) into its single call site, and delete the property
- add `GlassTokens.Radius.terminal = 3` for the battery-indicator tip nub, and use it in `BatteryIndicatorPlaceholder` instead of a magic number
- add `.accessibilityElement(children: .combine)` to `PowerFlowBadgeView.body` for hygiene (parent `.accessibilityLabel` still reads correctly; this is a defensive addition)
- drop the now-unused `GlassTokens.ControlSize` namespace (the refresh control now uses the system `controlSize(.regular)`)
- drop the unused `import SwiftUI` from `InverterStatus.swift` (the deleted formatter was the only consumer)
- align `StatusBarController.popover.contentSize.width` to 360pt to match the SwiftUI frame in `GrowattPopoverView` — the two sources of popover width now agree; `DESIGN.md:285`'s `popover-mac.width: 320` remains the design-system default for smaller popovers

## 0.2.5 (2026-07-29)

---

### Layout

- add a `.glassContainer(spacing:)` `ViewModifier` + `View` extension (`Views/Components/GlassContainerModifier.swift`) that wraps the content in a `GlassEffectContainer` on macOS 26+ and is a no-op on macOS 15
- apply `.glassContainer(spacing: GlassTokens.Spacing.lg)` to `GrowattPopoverView.body` so the popover background, the state badge, and the refresh button all share a single sampling region on macOS 26+; without the container, each `.glassEffect(...)` call computed the lensing and specular highlights as three separate planes
- the macOS 15 path is unchanged — the popover renders as before (each glass surface computed independently), which matches the platform's pre-Liquid-Glass capability

## 0.2.6 (2026-07-29)

---

### Polish

- replace the hardcoded `Color(red: 0.15, green: 0.85, blue: 0.45)` / `Color(red: 0.25, green: 0.95, blue: 0.55)` gradient stops in `BatteryIndicatorView` with semantic system colors `[.green, .green.opacity(0.8)]` for `.charging` and `[.orange, .orange.opacity(0.8)]` for `.discharging` — the bar now respects `accessibilityIncreaseContrast`, Light / Dark appearance, and the user's chosen accent automatically
- gate the spring / ease-in-out animations on `accessibilityReduceMotion` via new `levelAnimation` and `stateAnimation` computed properties that return `nil` when the user has opted out of motion; passing `nil` to `.animation(_:value:)` disables the animation without removing the modifier from the view tree
- add `@Environment(\.accessibilityReduceMotion) private var reduceMotion` to `BatteryIndicatorView` and use it to gate the animations
- extract a private `BatteryGeometry` enum with the bar's component-local constants (`trackCornerRadius = 12`, `fillCornerRadius = 10`, `fillInset = 3`, `barHeight = 38`, `tipWidth = 5`, `tipHeight = 16`) — kept local because they are specific to the battery bar's physical proportions, not system abstractions
- replace the magic `cornerRadius: 3` on the tip nub with `GlassTokens.Radius.terminal` (now used in both `BatteryIndicatorView` and `BatteryIndicatorPlaceholder`)
- replace the raw `HStack(spacing: 4)` and `VStack(spacing: 20)` literals in the file and preview with `GlassTokens.Spacing.xs` and `GlassTokens.Spacing.xl`
- add `.accessibilityElement(children: .combine)` to the bar's body so VoiceOver reads the parent accessibility label as a single utterance instead of descending into the decorative RoundedRectangles

## 0.2.7 (2026-07-29)

---

### Polish

- replace the magic `+ 1` in `PowerFlowBadgeView`'s vertical padding with `+ GlassTokens.Spacing.hairline` — the `hairline` token (defined in 0.2.1 as the 1pt optical-correction unit) earns its name; the badge now reads in tokens end-to-end
- add inline comments to both padding axes explaining the optical corrections (horizontal: `sm + xxs` for capsule sides, vertical: `xs + hairline` for capsule top/bottom) so a future reader sees the intent, not just the math
- add inline comments to the two fallback `opacity` values in `badgeBackground` explaining why they're different (`0.18` for the RT fallback on a solid background, `0.22` for the macOS 15 fallback on a translucent material)

## 0.2.8 (2026-07-29)

---

### Layout

- drop the misleading `GlassTokens.Radius.containerConcentric = 0` (it was a sentinel that resolved to nothing — the real concentric radius is the SwiftUI `.containerConcentric` `CornerStyle` value, not a `CGFloat`); the radius enum now holds only the three real values (`card`, `tile`, `terminal`)
- drop the unused `GlassTokens.Radius.popover = 24` (the popover background now uses a local `PopoverGeometry.cornerRadius` since it's the only consumer)
- drop the unused `GlassTokens.Radius.pill = 999` (no consumer; the refresh button uses `ButtonStyle.glass` which provides its own pill shape)
- add a private `PopoverGeometry` enum to `GrowattPopoverView` with `cornerRadius: CGFloat = 24` — the popover background's radius is now a local constant with a comment explaining the macOS 26+ `.containerConcentric` trade-off (the principled choice is `RoundedRectangle(...).corners(.containerConcentric())` but it's macOS 26+ only and the Package.swift floor is macOS 15, so a fixed 24pt is the reasonable approximation that works on both)
- update the `GlassTokens.Radius` doc comment to reflect the actual concentricity model: the popover uses a local constant, the hero card uses `card = 20`, the metric tile uses `tile = 14` — all three are nested, not container-filling

## 0.2.9 (2026-07-30)

---

### Polish

- add `.accessibilityElement(children: .combine)` and a custom `dataHeroAccessibilityLabel` to `dataHero` in `GrowattPopoverView` — VoiceOver now reads the data hero as a single utterance ("Battery at 73 percent, charging, updated 3m ago") instead of descending into the percentage, stale subtitle, and badge separately; closes Sam's last open red flag
- add `.help("Refresh the inverter reading. The popover auto-refreshes every 2 minutes.")` to `RefreshButton` — Alex now learns what the button does and that auto-poll exists on hover; closes 1 H10 point
- add a new `GlassTokens.Numeric` namespace with `hero: Font = .system(size: 44, weight: .bold, design: .rounded)` — the hero percentage font is now a single source of truth, used by both `dataHero` and `awaitingHero`; replaces the two raw `.font(.system(size: 44, ...))` literals that were the only remaining P3 affecting *users* (the fixed point means Dynamic Type does not scale the hero; this is a documented design trade-off)

## 0.2.10 (2026-07-30)

---

### Distill

- remove the redundant trailing `Spacer()` in the popover footer — the `HStack` sits inside a `VStack` that doesn't expand horizontally, so the button naturally hugs the leading edge; a comment now documents *why* the spacer was removed so the next reader doesn't add it back
- add an inline comment to `RefreshButton`'s rotation animation explaining that `1s` linear rotation is the platform's system-spinner convention (a full revolution per second), so the literal is no longer an unexplained magic number

## 0.2.11 (2026-07-30)

---

### Fix

- **fix(ui): remove text blur on the popover.** The popover's inner content
  was visibly soft — the title, the `Live` status pill, the battery
  percentage, the battery bar, and the `Home Load` tile all rendered
  fuzzy while the refresh button (at the bottom, outside the hero) was
  sharp. Two compounding causes:
  1. **`.regularMaterial` on the inner cards** (`heroBackground` in
     `GrowattPopoverView`, `background` in `ErrorBannerView`,
     `background` in `PowerMetricTileView`) applied a real-time blur
     (NSVisualEffectView) that visibly softened the text rendered on top.
  2. **`.glassContainer(spacing: GlassTokens.Spacing.lg)` on the popover
     body** put the entire popover content (including the header text,
     which has no material background) inside the macOS 26 shared
     sampling region, where the lensing effect subtly distorts all
     content within it.
  The fix:
  - Remove `.glassContainer(spacing:)` from the popover body. The popover
    background and the badge are now each their own glass surface,
    computed independently. The visual difference is negligible; the
    blur on the header text goes away.
  - Change all inner content backgrounds from `.regularMaterial` to
    `Color(nsColor: .controlBackgroundColor)`. The popover shell is
    the translucency layer; the inner cards are opaque. This is the
    standard macOS 26 Tahoe popover pattern (glass shell, opaque inner
    content) and it keeps the text sharp. Both the Reduce-Transparency
    on and off branches now resolve to the same opaque surface because
    the inner cards are not a translucency layer.
  - Updated the top doc comments on `GrowattPopoverView` and
    `PowerMetricTileView` to reflect the actual (opaque) behavior.
  The Liquid Glass character of the popover shell is preserved — the
  popover background still uses `.glassEffect(.clear, in: shape)` on
  macOS 26+, the badge still uses tinted glass, and the refresh button
  still uses `ButtonStyle.glass`. The lensing and specular highlights
  on the shell are intact; only the inner cards' material blur is gone.

## 0.2.12 (2026-07-30)

---

### Fix

- **fix(ui): restore the Liquid Glass character of the popover shell.**
  0.2.11 removed `.glassContainer(spacing:)` to fix the text blur, but
  removing the container weakened the lensing and specular highlights on
  the popover shell — the glass effect was no longer "perfect." The actual
  cause of the text blur was the `.regularMaterial` on the inner cards
  (real-time blur softens content on top), not the container. With the
  inner cards now opaque (`Color(nsColor: .controlBackgroundColor)` from
  0.2.11), the container can come back safely: the container's shared
  sampling region only affects the glass surfaces (the popover background
  and the badge), and the type on the opaque cards stays sharp.
  - Re-added `.glassContainer(spacing: GlassTokens.Spacing.lg)` to the
    popover body, with a comment that explains the relationship between
    the container and the opaque inner content.
  - The popover shell's lensing and specular highlights are back to the
    "perfect" character of the pre-0.2.11 design.
  - Build: 0 warnings, 0 errors.

## 0.2.13 (2026-07-30)

---

### Fix

- **fix(ui): eliminate popover content blur caused by GlassEffectContainer.** The popover's inner content (title, freshness pill, battery hero, metric tile) rendered blurred and milky while the glass shell looked correct. Three compounding root causes, all now fixed:
  1. **GlassEffectContainer wrapped the entire content tree** (`GrowattPopoverView.body`). Per Apple's docs, the `glassEffect(_:in:)` modifier "captures the content to send to the container to render" — the full-size background glass unioned with the badge and button glass, capturing all interior content into a shared lensing pass. Removed the `.glassContainer(spacing:)` call from the popover body and deleted the now-dead `GlassContainerModifier.swift`. This supersedes the incorrect 0.2.12 rationale ("the container only affects glass surfaces").
  2. **The shell used the `.clear` Liquid Glass variant** outside its documented preconditions (media-rich backdrop, dimming layer, bold/bright overlay content). Clear never applies the adaptive legibility treatment, washing out the header title and pill that sit directly on the glass. Switched to `.glassEffect(.regular, in:)`, which applies the system's automatic vibrant legibility treatment to all content above it.
  3. **`.clear` shell mixed with `.regular` badge** — Apple prohibits mixing variants ("incompatible lighting models"). The shell, badge, and refresh button are now all in the Regular family.
- Collapse the three identical `if reduceTransparency { X } else { X }` background branches in `GrowattPopoverView.heroBackground`, `PowerMetricTileView.background`, and `ErrorBannerView.background` into single fill expressions; remove the now-unused `@Environment(\.accessibilityReduceTransparency)` properties from `PowerMetricTileView` and `ErrorBannerView`. Zero behavior change — RT users keep the same opaque surface.
- Amend `DESIGN.md`: scope the `GlassEffectContainer` Do-rule to adjacent glass clusters only (never wrap content hierarchies or full-size background glass), document the popover-shell pattern (`.glassEffect(.regular, in:)` root background, opaque inner cards, no container), and add a Don't against wrapping content in a container.
- Update `GrowattPopoverView`'s top doc comment to describe the actual architecture (Regular glass shell, no container, opaque inner cards).
- Build: 0 warnings, 0 errors.

## 0.1.0 (2026-07-29)

---

### Features

- add inverter state enum (InverterState) with title, icon and accent color
- add inverter status model (InverterStatus) with soc clamping and power formatter
- add growatt api error type (GrowattAPIError) with localized descriptions
- add api service protocol (GrowattAPIServiceProtocol) abstraction
- add mock api service (MockGrowattAPIService) for previews, tests, and default runtime
- add growatt open api client (GrowattOpenAPIService) placeholder for real http integration
- add inverter view model (InverterViewModel) with observable state, polling and refresh
- add liquid glass card component (LiquidGlassCard) for translucent macos container
- add battery indicator view (BatteryIndicatorView) with state gradient
- add power flow badge view (PowerFlowBadgeView) for state pill and power subtitle
- add power metric tile view (PowerMetricTileView) for compact energy metrics
- add popover view (GrowattPopoverView) composing hero, power tiles and footer
- add status bar item view (StatusBarItemView) for menu bar soc and icon
- add toolbar app entry point (GrowattToolbarApp) with accessory activation policy
- add status bar controller (StatusBarController) managing status item and popover

### Tests

- add inverter status unit tests covering state metadata, soc bounds, and power formatting
- add api service unit tests covering mock success, error and state toggle
- add inverter view model unit tests for init, refresh, and error state

### Docs

- add project constitution (AGENTS.md) with stack, do/don't, and skills index
- add comprehensive implementation plan (PLAN.md) with 5 phases and checklist
- add changelog tracking every project change
- drop redundant root icon.svg and remove from directory tree

### Chore

- add macos and swift gitignore
- add swift package manifest (Package.swift) with two library and two executable targets
- add app icon (icon.svg) for menu bar status item
- add asset catalog (Assets.xcassets) with status icon template
- add ad-hoc test runner executable (GrowattToolbarTestRunner) for manual smoke checks
- bundle workflow skills under docs/skills for self-contained agent tooling
- keep legacy icon under resources as bundle fallback
- drop redundant root icon.svg; asset catalog remains canonical

### Refactor

- switch GrowattOpenAPIService to local `GET /status` endpoint with `x-api-key` auth and new DTO shape
- wire real /status service as InverterViewModel default and poll every 2 minutes via GROWATT_API_KEY env var
- drop batteryPowerKW, solarOutputKW, gridImportKW, homeLoadKW from InverterStatus; keep only the 4 fields the backend actually returns plus lastUpdated
- reduce InverterState to the two cases the /status endpoint emits (charging, discharging)
- drop unused .invalidURL case from GrowattAPIError
- drop .idle / .unknown gradient branches from BatteryIndicatorView
- rewrite GrowattPopoverView as a single Liquid Glass surface with a GlassEffectContainer on macOS 26; drop the unused mock-state tap gesture and the stale batteryPowerKW reference
- apply Liquid Glass correctly on macOS 26: only the popover surface itself is glass, hero content sits on a `.regularMaterial` card, the metric tile uses `.regularMaterial` (not glass), and the GlassEffectContainer is removed so glass surfaces no longer merge and wash out the text; drop the now-unused LiquidGlassCard
- switch the popover background and refresh button to the `.clear` Liquid Glass variant for a more transparent look
- add liquid glass design tokens (GlassTokens) shared across the popover hierarchy
- expose GlassTokens as public so the public component API can reference the shared radii and padding
- use real glassEffect in LiquidGlassCard on macOS 26 with reduceTransparency fallback to window background and .ultraThinMaterial on macOS 15
- use real glassEffect in PowerMetricTileView with the same reduceTransparency and macOS 15 fallback
- use tinted glassEffect in PowerFlowBadgeView with state accent color and the same reduceTransparency and macOS 15 fallback
- wrap GrowattPopoverView in GlassEffectContainer with real glass background and an interactive glass refresh button on macOS 26
- surface outputPowerKW on InverterStatus (mapped from /status consumption_watts) and render it in the Home Load tile
