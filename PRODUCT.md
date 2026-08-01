# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

<!--
Platform `ios` covers iOS, iPadOS, macOS, and the rest of the Apple platform
family under a single Apple-native visual language. The Growatt Toolbar Status
executable targets macOS 15+ (`Package.swift: .macOS(.v15)`); Liquid Glass
opt-in is gated with `#available(macOS 26, *)`. Recorded as `ios` because
init's product schema has no `macos` value and Apple's platforms share one
design language and one toolchain.
-->

## Users

The primary user is **the developer themselves** — a personal tool, not a
distributed product. Confirmed by the user during init.

The secondary audience is the **open-source community** that may read, fork,
or build the project from the public repository. This audience does not shape
the design — they read the code — but their presence keeps the code legible
and the architecture honest.

## Product Purpose

Growatt Toolbar Status surfaces the current state of a Growatt battery
inverter directly inside the **macOS menu bar** so the user can read battery
level, charging / discharging state, and live output power **without switching
to the phone app, the web portal, or any other window**.

Success means: the user always knows the state of their home energy system in
under one second, and the menu bar item is never wrong, never stale, and never
in the way.

## Positioning

The product's meaningfully different mechanism is that it **lives in the macOS
menu bar** — the place the user already is, not the place they have to go to.
Neighboring products (Growatt phone app, ShineWeb, Home Assistant Growatt
integration) all require context switching to a phone, a browser, or a
dashboard window. This product removes that switching cost.

The claim a neighbor could not truthfully copy is not the data — the data is
the same `/status` endpoint — but the *placement*. The Mac menu bar is
Apple-shaped real estate; treating it as a first-class surface for home
energy, designed against Apple's current visual language (Liquid Glass on
macOS 26+), is the position.

## Operating Context

- **Surface:** the **macOS menu bar**, anchored to a single `NSStatusItem`
  with a transient `NSPopover`. A native settings window (sidebar-style
  `NavigationSplitView`) is the only other window the product ever opens —
  it appears automatically on first launch as onboarding and on demand from
  the status bar's right-click menu for returning users.
- **Environment:** the user's primary Mac, sitting at a desk, screen on,
  usually with other apps in the foreground. The menu bar is always visible.
- **Cadence:** the user glances at the menu bar many times a day. The popover
  is opened on demand, not by default. The popover does not steal focus.
- **Adjacent surfaces:** Growatt's own phone app, the ShineWeb web portal,
  Home Assistant Growatt integrations. The product does not replace any of
  these — it complements them by reducing how often the user needs to open
  them.
- **Deployment:** local macOS executable, run from `swift run
  GrowattToolbarApp`. Credentials are entered in the onboarding/settings
  window: the API key is stored in Keychain Services and the API URL in
  `UserDefaults`. The `GROWATT_API_KEY` environment variable remains a
  debug-time fallback for local development (per `AGENTS.md`).

## Capabilities and Constraints

### Confirmed capabilities

- Read three fields from `GET {baseURL}/status` with an `x-api-key` header:
  `level` (int, 0–100), `is_charging` (bool), `output_power` (number, watts).
- Map those fields to a 4-field domain model: `batterySoC`, `state`
  (`.charging` / `.discharging`), `outputPowerKW`, `lastUpdated`.
- Show battery percentage in the status bar item title and inside the popover.
- Show a power-flow badge (charging / discharging) and a numeric "X.X kW" line
  in the popover.
- Show a single metric tile for "Home Load" in the popover.
- Refresh on a polling cadence driven by the view model.
- Run as an `.accessory` macOS app (no Dock icon) once setup completes.
- Present a native settings/onboarding window on first launch and from the
  status bar menu, backed by a `NavigationSplitView` sidebar.
- Test draft credentials against `/status` before persisting them (a
  successful test is required before Save/Update is enabled).
- Persist the API key in Keychain Services and the API URL in
  `UserDefaults`, with the connection test never touching persistence.

### Confirmed constraints

- **Two surfaces: the menu bar popover and the settings window.** The
  popover is the glanceable surface; the settings/onboarding window is the
  only other window. No dashboard, no history, no charts.
- **Backend contract is fixed.** The 3-field `/status` payload is the only
  data source. Future work must design within these fields, not invent new
  server fields.
- **Minimum macOS 15** (`Package.swift` sets `.macOS(.v15)`). Liquid Glass
  APIs are gated with `#available(macOS 26, *)` and fall back to
  `.ultraThinMaterial` on macOS 15. The deployment target will not be raised.
- **Zero third-party dependencies.** All UI, networking, and state management
  use Apple system frameworks (SwiftUI, AppKit, Foundation). This is a
  deliberate constraint, recorded in `AGENTS.md`.
- **Secrets never committed.** Credentials are entered at runtime in the
  settings window; the API key is persisted in Keychain Services and never
  logged, copied to `UserDefaults`, or included in errors or accessibility
  text. `GROWATT_API_KEY` remains a debug-only environment fallback.
- **No use of `ObservableObject` / `@Published`.** New code uses the
  `@Observable` macro and `@State` / `@Bindable` (per `AGENTS.md`).
- **One type per file** in the `GrowattToolbarCore` library. No file holds
  more than one `struct`, `class`, `enum`, or `protocol` of project
  significance.

### Open decisions

- Whether the popover will ever grow additional tiles (solar production, grid
  flow). Recorded as open; the popover is currently a single glanceable
  surface, but the user may revisit this.
- The product icon. None defined yet. The asset catalog exists at
  `src/GrowattToolbarApp/Resources/Assets.xcassets/` and is empty.

## Brand Commitments

No brand commitments are recorded. The product has no published name beyond
the repository name "Growatt Toolbar Status," no logo, no voice, and no
public-facing copy. "Growatt" is a trademark of Growatt New Energy Technology
CO., LTD; this is a third-party utility and is not affiliated with Growatt.

The product is open-source; the lack of brand identity is a feature, not an
oversight — a personal tool for a single user does not need a brand.

## Evidence on Hand

- `Package.swift` — two SwiftPM targets, `.macOS(.v15)`, zero external
  dependencies, executable + library split.
- `AGENTS.md` — the project's authoring contract: Swift 6.2+ concurrency,
  `@Observable`, `#available(macOS 26, *)` for Liquid Glass with
  `.ultraThinMaterial` fallback, one type per file, SOLID throughout.
- `src/GrowattToolbarCore/Models/InverterStatus.swift` — the 4-field domain
  model and its only client-side derivations (clamp, formatter).
- `src/GrowattToolbarCore/Models/InverterState.swift` — the 2-case enum
  (`.charging`, `.discharging`) and its SF Symbol + color mappings.
- `src/GrowattToolbarCore/Views/GrowattPopoverView.swift` — the live
  popover implementation: 360pt wide, glass background on macOS 26+, fallback
  to `.ultraThinMaterial` on macOS 15, `.regularMaterial` for inner content
  cards so text stays legible (no glass-on-glass stacking).
- `src/GrowattToolbarCore/Views/Components/GlassTokens.swift` — the
  centralized Liquid Glass tokens used by the popover and its sub-views
  (radii, padding, control sizes).
- `src/GrowattToolbarCore/ViewModels/SettingsViewModel.swift` — the
  settings/onboarding state machine (draft validation, connection testing,
  safe error mapping, persistence boundaries).
- `DESIGN.md` (Apple Liquid Glass) — the design system tokens, components,
  and do's-and-don'ts already in place. Recorded by an earlier session.

## Product Principles

1. **At-a-glance, not in-your-face.** The menu bar item is a glance; the
   popover is a deliberate look. Both should resolve in under one second and
   never demand attention.
2. **The menu bar is the surface.** The menu bar item and popover are the
   primary glanceable surface; the settings/onboarding window is a brief,
   native sidebar-style detour for connection setup. No Dock icon.
3. **Apple-native, not a port.** Designed against the current macOS visual
   language. Looks like a system app, not a third-party widget. Liquid Glass
   when the host supports it; faithful fallback when it does not.
4. **Live data, never stale.** Polling cadence is fast enough that the user
   never sees a number more than one refresh cycle old. Errors surface
   honestly — never silently fall back to a fake value.
5. **Single source of truth in code.** One type per file. Services depend on
   protocols, not concrete implementations. View models never import AppKit.
   No business logic in views.

## Accessibility & Inclusion

- **Dynamic Type:** all text scales with the user's preferred reading size
  (the popover uses semantic font styles: `.title3`, `.caption`, `.caption2`;
  the settings window uses semantic styles throughout and scrolls internally
  at larger sizes).
- **VoiceOver:** the status bar item and the refresh button carry explicit
  accessibility labels (`"Refresh"`); the popover's "Connected" / "Offline"
  status and the "Last synced: …" footer are readable. Settings fields,
  buttons, validation feedback, and connection-test status all carry labels
  and hints, and never include the API key in announcements.
- **Reduce Transparency:** the popover, the hero card, and the refresh
  button all read `\.accessibilityReduceTransparency` and fall back to
  `Color(nsColor: .windowBackgroundColor)` instead of glass / material. This
  is automatic; nothing in the code overrides the system setting.
- **Liquid Glass itself** ships with built-in accessibility: Reduced
  Transparency increases frosting, Increase Contrast adds borders, Reduce
  Motion disables elastic effects. `.glassEffect()` participates in all of
  these for free.
- **High contrast:** text colors use Apple system semantic colors
  (`.primary`, `.secondary`, `.tertiary`) so the popover adapts to Increase
  Contrast and to light / dark appearance without code changes.

## Out of scope (recorded so future work does not reinvent it)

- Historical charts, energy history, daily / weekly / monthly aggregates.
- A Growatt account login flow, multi-inverter support, multi-site support.
- Notifications, banners, or any background alert system.
- iOS / iPadOS / visionOS versions. The product is macOS-only.
- The Mac App Store. The product is a personal tool, not distributed.
