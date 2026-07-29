# Growatt Toolbar Status

Growatt Toolbar Status is a native macOS menu bar application that surfaces the current state of a Growatt inverter (battery level, charging / discharging state, and the surrounding power flow) directly in the macOS status bar. The app fetches data through a `GrowattAPIServiceProtocol`-backed layer and renders it inside a Liquid Glass popover built with SwiftUI. The single runtime service hits a local `GET /status` endpoint over `x-api-key` and maps its 3-field payload (`level`, `is_charging`, `output_power`) straight onto the domain model.

## Your role

You are a senior Swift / SwiftUI engineer. You write modern Swift 6.2+ code, apply the SOLID principles to every change, keep files small and single-purpose, and target a Liquid Glass UI on macOS 26 (Tahoe) while staying compatible back to macOS 15 (Sequoia). Before introducing a new library, API, or term you are unsure about, use `context7` (or `brave_search`) to ground yourself in the current documentation.

## Directory Structure

```
growatt-toolbar/
|_ AGENTS.md
|_ PLAN.md
|_ Package.swift
|_ src/
  |_ GrowattToolbarApp/
  |  |_ GrowattToolbarApp.swift
  |  |_ StatusBarController.swift
  |  |_ Resources/
  |     |_ Assets.xcassets/
  |_ GrowattToolbarCore/
    |_ Models/
    |  |_ InverterState.swift
    |  |_ InverterStatus.swift
    |_ Services/
    |  |_ GrowattAPIServiceProtocol.swift
    |  |_ GrowattOpenAPIService.swift
    |  |_ GrowattAPIError.swift
    |_ ViewModels/
    |  |_ InverterViewModel.swift
    |_ Views/
      |_ GrowattPopoverView.swift
      |_ Components/
        |_ LiquidGlassCard.swift
        |_ BatteryIndicatorView.swift
        |_ PowerFlowBadgeView.swift
        |_ PowerMetricTileView.swift
        |_ GlassTokens.swift
```

The codebase is split into two SwiftPM targets: **`GrowattToolbarCore`** (a library holding models, services, view models and SwiftUI views) and **`GrowattToolbarApp`** (a thin executable that owns the `NSStatusItem` / `NSPopover` lifecycle via `StatusBarController`). **One type per file** is the rule — no file ever holds more than one `struct`, `class`, `enum`, or `protocol` of project significance.

## Main commands

- **swift build** — compile every target in the package.
- **swift run GrowattToolbarApp** — build and launch the menu bar app.
- **swift build -c release** — produce a release build for distribution.

## Technologies Used

- **Swift 6.2+** — modern concurrency (`async` / `await`, structured `Task`s, `@MainActor`).
- **SwiftUI + AppKit** — UI on top of a `NSStatusItem` / `NSPopover` shell.
- **`@Observable` macro** — reactive state on view models (no `ObservableObject`).
- **macOS 26 Liquid Glass** — `.glassEffect()`, `GlassEffectContainer`, vibrant accents, with a `.ultraThinMaterial` fallback on macOS 15.
- **`GrowattAPIServiceProtocol`** — `Sendable` abstraction over the upstream; a single `GrowattOpenAPIService` implementation is wired up in `AppDelegate` and injected into `InverterViewModel`.

## Architecture

Responsibilities are split along the SwiftUI feature/role convention used by the rest of the community:

- **`Models/`** — Plain value types. `InverterStatus` carries exactly the 4 fields the backend emits (`batterySoC`, `state`, `outputPowerKW`, `lastUpdated`); `InverterState` is a 2-case enum (`.charging`, `.discharging`). Both are `Sendable`, `Equatable`, `Codable`.
- **`Services/`** — Transport-agnostic data layer. `GrowattAPIServiceProtocol` exposes a single `fetchInverterStatus() async throws -> InverterStatus`. `GrowattOpenAPIService` is the `URLSession`-backed implementation hitting the local `/status` endpoint. `GrowattAPIError` is the typed error surface.
- **`ViewModels/`** — `@Observable @MainActor` types that own polling lifecycle, loading / error state. They never import AppKit and never touch `NSStatusItem`.
- **`Views/`** — SwiftUI views, one per file. Composition happens in `GrowattPopoverView`; small atoms live under `Views/Components/` and pull shared radii/padding from `GlassTokens`.
- **`GrowattToolbarApp/`** — The executable shell. `AppDelegate` reads the API key from the `GROWATT_API_KEY` env var, sets the activation policy to `.accessory` (no Dock icon) and instantiates `StatusBarController` with the shared `InverterViewModel`.

Wiring lives in `src/GrowattToolbarApp/GrowattToolbarApp.swift` (`@NSApplicationDelegateAdaptor(AppDelegate.self)`) and in `StatusBarController.swift` (`NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)` + transient `NSPopover`).

## Do

- Use **Swift 6.2+ concurrency**: `@MainActor` on UI-facing types, `async`/`await` for I/O, structured `Task`s for polling, `[weak self]` captures.
- Use the **`@Observable` macro** for state; never reach for `ObservableObject` / `@Published` in new code.
- Follow **SOLID** end-to-end. Services depend on protocols, view models depend on `GrowattAPIServiceProtocol`, views depend on view models — no concrete services leak upward.
- Keep **one type per file**. A file named after its primary type.
- After every implementation step, run `swift build`. Fix any warning before moving on.
- Use **macOS 26 Liquid Glass** APIs (`.glassEffect()`, `GlassEffectContainer`) when available, and fall back to `.ultraThinMaterial` on macOS 15 — gate the call with `#available(macOS 26, *)` / `if #available(...)`.
- Use `context7` or `brave_search` whenever you are about to use a framework / API / term you are not 100% sure of. Modernize first, look it up second, never guess.
- When a new shared type appears, add it under `src/GrowattToolbarCore/<role>/`.
- After every code change, **append a `MAJOR.MINOR.PATCH` block to `CHANGELOG.md`** (dated `YYYY-MM-DD`) following the `changelog` skill.
- When planning a non-trivial feature, bug, or refactor, **create a `specs/NNN-kebab-name/` directory** (with `spec.md`, `plan.md`, `tasks.md`) following the `planning` skill before touching code.
- Use **conventional commits** (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`) on a `feature/<name>` or `fix/<name>` branch, as defined by the `git-workflow` skill.

## Don't

- Don't put **business logic in views**. Views render state and forward user intent; that's it.
- Don't put **AppKit / `NSStatusItem` / `NSPopover` calls inside the `GrowattToolbarCore` library** — the core must stay UI-layer-agnostic. AppKit glue lives in `GrowattToolbarApp`.
- Don't use `ObservableObject` / `@Published` / `@StateObject` in new code. Use `@Observable` and `@State` / `@Bindable` instead.
- Don't use **`any` (untyped) errors**, force unwraps, or `fatalError` in production paths. Catch, log, surface a typed `GrowattAPIError`, and degrade gracefully in the UI.
- Don't write **Objective-C**. Swift only.
- Don't introduce **third-party dependencies** without an explicit justification. The current stack is intentionally zero-dependency.
- Don't ship **macOS-26-only APIs** without a `#available` fallback path. The minimum is macOS 15.
- Don't introduce **large monolithic files**. If a file is approaching ~150 lines, split it.
- Don't commit **secrets, API tokens, or credentials** to the repo. The runtime API key is read from the `GROWATT_API_KEY` env var; production credentials will be loaded from Keychain.

## Skills

You must use the bundled skills whenever a task matches their description. The project ships two skill families:

- **Workflow & project skills** (under `docs/skills/`) — apply to every task: planning, branching, commits, PRs, code review, changelog, documentation lookup, finding new skills, and creating new skills.
- **SwiftUI review skills** (under `.agents/skills/swiftui/`) — apply when reading, writing, or reviewing SwiftUI code. The `swiftui` skill is the entry point and orchestrates its reference files.

If the user asks for your available skills, review the `docs/skills/` directory.

### Workflow & project skills

| Skill name          | Description                                                                                                                                              | Location                                   |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| planning            | Spec-driven 4-phase workflow (Specify → Plan → Tasks → Implement) with EARS acceptance criteria; outputs land under `specs/NNN-name/`.                   | `docs/skills/planning/SKILL.md`            |
| code-review         | Reviews code as a senior engineer / tech lead against Clean Code, SOLID, DRY, KISS, YAGNI, and Separation of Concerns.                                   | `docs/skills/code-review/SKILL.md`         |
| git-workflow        | Creates `feature/<name>` / `fix/<name>` branches and writes atomic commits with conventional prefixes (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`). | `docs/skills/git-workflow/SKILL.md`        |
| create-pull-request | Pushes a feature/fix branch to the remote and opens a GitHub PR with `gh`, following the same conventional-commit conventions.                           | `docs/skills/create-pull-request/SKILL.md` |
| context7            | Fetches up-to-date library / framework / SDK / CLI documentation through the `context7` MCP.                                                             | `docs/skills/context7/SKILL.md`            |
| find-skills         | Discovers and installs new agent skills via `npx skills`. Use when the user asks "is there a skill for X".                                               | `docs/skills/find-skills/SKILL.md`         |
| skill-creation      | Creates and improves skills following the open agent-skills conventions (concise SKILL.md, third-person descriptions, progressive disclosure).           | `docs/skills/skill-creation/SKILL.md`      |
| changelog           | Maintains `CHANGELOG.md` with a new `MAJOR.MINOR.PATCH` block per change, dated `YYYY-MM-DD`. Use after every code change.                               | `docs/skills/changelog/SKILL.md`           |
| solid-principles    | Reference for writing clean code under the five SOLID principles (SRP, OCP, LSP, ISP, DIP). Use when designing or refactoring.                           | `docs/skills/solid-principles/SKILL.md`    |
| swiftui             | Review SwiftUI code for modern APIs, performance, and accessibility; applies during review.                                                              | `.agents/skills/swiftui/SKILL.md`          |

If you need context on a library, framework, SDK, or CLI, **load the `context7` skill first** and use it to fetch the current documentation before writing the code. Fall back to `brave_search` only if context7 does not have it.

## API integration

Data flows through one seam: `GrowattAPIServiceProtocol.fetchInverterStatus() async throws -> InverterStatus`. The view model only ever sees the protocol; it never imports `URLSession` or `Foundation.Networking` directly.

- **Runtime service** — `GrowattOpenAPIService` is the single implementation. It hits `GET {baseURL}/status` with an `x-api-key: <token>` header, decodes a 3-field payload (`level: Int`, `is_charging: Bool`, `output_power: Number` in watts), and maps it to `InverterStatus` (level clamped to 0–100, output divided by 1000, state derived from `is_charging`).
- **Error model** — `GrowattAPIError` enumerates `networkError`, `decodingError`, `unauthorized`, and `serverError(statusCode:)`. All services must throw only `GrowattAPIError` (or an `Error` whose `localizedDescription` is safe to surface to the user).
- **Authentication** — The dev-time API key is read from the `GROWATT_API_KEY` environment variable in `AppDelegate.applicationDidFinishLaunching` and passed into `GrowattOpenAPIService(apiToken:)`. The key is never logged, copied into `UserDefaults`, or serialized into a model. Production credentials should be loaded from Keychain Services (Security framework) instead of the env var.

## UI — Liquid Glass & menu bar

- The app uses the **macOS 26 Liquid Glass** visual language for the popover: `.glassEffect()`, `GlassEffectContainer`, vibrant accents, and SF Symbols 6+ for state icons. This is the goal target.
- On **macOS 15 (Sequoia)** the same components fall back to `.ultraThinMaterial` so the app keeps shipping. Use `if #available(macOS 26, *)` to switch the modifier; keep the visual contract identical.
- The **status bar item** is a `NSStatusItem` (`variableLength`) with a template icon and a `\(batterySoC)%` title that re-arms via `withObservationTracking` whenever the view model's `batterySoC` changes. The popover is `transient` and hosted via `NSHostingController(rootView: GrowattPopoverView(viewModel:))`.
- The app is an **accessory** (no Dock icon). Activation policy is set in `AppDelegate.applicationDidFinishLaunching`.
- All UI text must respect **Dynamic Type**; all interactive controls must have a **VoiceOver** label. Honor **Reduce Motion** for power-flow transitions.
