# Growatt Toolbar Status

Growatt Toolbar Status is a native macOS menu bar application that surfaces the current state of a Growatt inverter (battery level, charging / discharging / idle state, and the surrounding power flow) directly in the macOS status bar. The app fetches data through a `GrowattAPIServiceProtocol`-backed layer and renders it inside a Liquid Glass popover built with SwiftUI. The current build runs against an in-process `MockGrowattAPIService`; a real Growatt OpenAPI client exists as a placeholder and is wired up but not yet credentialed.

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
    |  |_ MockGrowattAPIService.swift
    |_ ViewModels/
    |  |_ InverterViewModel.swift
    |_ Views/
      |_ GrowattPopoverView.swift
      |_ StatusBarItemView.swift
      |_ Components/
        |_ LiquidGlassCard.swift
        |_ BatteryIndicatorView.swift
        |_ PowerFlowBadgeView.swift
        |_ PowerMetricTileView.swift
|_ Tests/
  |_ GrowattToolbarTests/
  |  |_ GrowattAPIServiceTests.swift
  |  |_ InverterStatusTests.swift
  |  |_ InverterViewModelTests.swift
  |_ GrowattToolbarTestRunner/
     |_ main.swift
```

The codebase is split into two SwiftPM targets: **`GrowattToolbarCore`** (a library holding models, services, view models and SwiftUI views) and **`GrowattToolbarApp`** (a thin executable that owns the `NSStatusItem` / `NSPopover` lifecycle via `StatusBarController`). A third executable, `GrowattToolbarTestRunner`, is reserved for ad-hoc test execution. **One type per file** is the rule — no file ever holds more than one `struct`, `class`, `enum`, or `protocol` of project significance.

## Main commands

- **swift build** — compile every target in the package.
- **swift run GrowattToolbarApp** — build and launch the menu bar app.
- **swift test** — execute the full unit-test suite (Swift Testing).
- **swift build -c release** — produce a release build for distribution.

## Technologies Used

- **Swift 6.2+** — modern concurrency (`async` / `await`, structured `Task`s, `@MainActor`).
- **SwiftUI + AppKit** — UI on top of a `NSStatusItem` / `NSPopover` shell.
- **`@Observable` macro** — reactive state on view models (no `ObservableObject`).
- **macOS 26 Liquid Glass** — `.glassEffect()`, `GlassEffectContainer`, vibrant accents, with a `.ultraThinMaterial` fallback on macOS 15.
- **Swift Testing** — `import Testing`, `@Test`, `#expect(...)`. Existing XCTest files are being migrated.
- **`GrowattAPIServiceProtocol`** — `Sendable` abstraction over the upstream with a `MockGrowattAPIService` for tests, previews, and the default runtime path.

## Architecture

Responsibilities are split along the SwiftUI feature/role convention used by the rest of the community:

- **`Models/`** — Plain value types. `InverterStatus` and `InverterState` are `Sendable`, `Equatable`, `Codable`. No behavior beyond formatting helpers and validation clamping (e.g. `batterySoC` is clamped to `0...100` in the init).
- **`Services/`** — Transport-agnostic data layer. `GrowattAPIServiceProtocol` exposes a single `fetchInverterStatus() async throws -> InverterStatus`. `MockGrowattAPIService` returns deterministic data and is the default implementation injected into the view model. `GrowattOpenAPIService` is the placeholder for the real HTTP client. `GrowattAPIError` is the typed error surface.
- **`ViewModels/`** — `@Observable @MainActor` types that own polling lifecycle, loading / error state, and mock-mode toggling. They never import AppKit and never touch `NSStatusItem`.
- **`Views/`** — SwiftUI views, one per file. Composition happens in `GrowattPopoverView`; small atoms live under `Views/Components/`. The menu-bar popover is hosted inside an `NSPopover` from `StatusBarController`.
- **`GrowattToolbarApp/`** — The executable shell. `AppDelegate` sets the activation policy to `.accessory` (no Dock icon) and instantiates `StatusBarController` with the shared `InverterViewModel`.

Wiring lives in `src/GrowattToolbarApp/GrowattToolbarApp.swift` (`@NSApplicationDelegateAdaptor(AppDelegate.self)`) and in `StatusBarController.swift` (`NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)` + transient `NSPopover`).

## Do

- Use **Swift 6.2+ concurrency**: `@MainActor` on UI-facing types, `async`/`await` for I/O, structured `Task`s for polling, `[weak self]` captures.
- Use the **`@Observable` macro** for state; never reach for `ObservableObject` / `@Published` in new code.
- Follow **SOLID** end-to-end. Services depend on protocols, view models depend on `GrowattAPIServiceProtocol`, views depend on view models — no concrete services leak upward.
- Keep **one type per file**. A file named after its primary type.
- Write tests with **Swift Testing** (`@Test`, `#expect(...)`). New tests must use it; the few remaining XCTest cases are scheduled for migration.
- After every implementation step, run `swift build` and `swift test`. Fix any warning before moving on.
- Use **macOS 26 Liquid Glass** APIs (`.glassEffect()`, `GlassEffectContainer`) when available, and fall back to `.ultraThinMaterial` on macOS 15 — gate the call with `#available(macOS 26, *)` / `if #available(...)`.
- Use `context7` or `brave_search` whenever you are about to use a framework / API / term you are not 100% sure of. Modernize first, look it up second, never guess.
- When a new shared type appears, add it under `src/GrowattToolbarCore/<role>/`.
- After every code change, **append a `MAJOR.MINOR.PATCH` block to `CHANGELOG.md`** (dated `YYYY-MM-DD`) following the `changelog` skill.
- When planning a non-trivial feature, bug, or refactor, **create a `specs/NNN-kebab-name/` directory** (with `spec.md`, `plan.md`, `tasks.md`) following the `planning` skill before touching code.
- Use **conventional commits** (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`) on a `feature/<name>` or `fix/<name>` branch, as defined by the `git-workflow` skill.

## Don't

- Don't put **business logic in views**. Views render state and forward user intent; that's it.
- Don't put **AppKit / `NSStatusItem` / `NSPopover` calls inside the `GrowattToolbarCore` library** — the core must stay UI-layer-agnostic so it can be unit-tested and previewed. AppKit glue lives in `GrowattToolbarApp`.
- Don't use `ObservableObject` / `@Published` / `@StateObject` in new code. Use `@Observable` and `@State` / `@Bindable` instead.
- Don't use **`any` (untyped) errors**, force unwraps, or `fatalError` in production paths. Catch, log, surface a typed `GrowattAPIError`, and degrade gracefully in the UI.
- Don't write **Objective-C**. Swift only.
- Don't introduce **third-party dependencies** without an explicit justification. The current stack is intentionally zero-dependency.
- Don't ship **macOS-26-only APIs** without a `#available` fallback path. The minimum is macOS 15.
- Don't introduce **large monolithic files**. If a file is approaching ~150 lines, split it.
- Don't commit **secrets, API tokens, or credentials** to the repo. Real Growatt credentials will be loaded from Keychain (see "API integration" below) — never inlined.

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
| swiftui             | Review SwiftUI code for modern APIs, performance, and accessibility; applies during review.                                                              | `.agents/skills/swiftui/SKILL.md`          |

If you need context on a library, framework, SDK, or CLI, **load the `context7` skill first** and use it to fetch the current documentation before writing the code. Fall back to `brave_search` only if context7 does not have it.

## API integration

Data flows through one seam: `GrowattAPIServiceProtocol.fetchInverterStatus() async throws -> InverterStatus`. The view model only ever sees the protocol; it never imports `URLSession` or `Foundation.Networking` directly.

- **Current runtime path** — `MockGrowattAPIService`. It returns deterministic telemetry, supports a `shouldThrowError` flag for negative-path tests, and exposes `toggleState()` for SwiftUI previews and UI demos. It is the default injected into `InverterViewModel` and what the app actually runs on today.
- **Real client (placeholder)** — `GrowattOpenAPIService` conforms to the same protocol and is the place where a real `URLSession`-based implementation will live. It is not yet wired up to credentials.
- **Error model** — `GrowattAPIError` enumerates the failure cases (network, decoding, unauthorized, timeout, unknown). All services must throw only `GrowattAPIError` (or an `Error` whose `localizedDescription` is safe to surface to the user).
- **Authentication (TODO)** — Real Growatt credentials are **not** in scope yet. When implemented they must be:
  1. Loaded from **Keychain Services** (Security framework), never from `Info.plist`, environment variables, or source code.
  2. Read once at app launch and held by a single `@MainActor`-isolated credential store.
  3. Never logged, never copied into `UserDefaults`, never serialized into a model.
  4. Cleared on sign-out / uninstall.

Until that lands, `GrowattOpenAPIService` is allowed to compile but must not be the default in `InverterViewModel`.

## UI — Liquid Glass & menu bar

- The app uses the **macOS 26 Liquid Glass** visual language for the popover: `.glassEffect()`, `GlassEffectContainer`, vibrant accents, and SF Symbols 6+ for state icons. This is the goal target.
- On **macOS 15 (Sequoia)** the same components fall back to `.ultraThinMaterial` so the app keeps shipping. Use `if #available(macOS 26, *)` to switch the modifier; keep the visual contract identical.
- The **status bar item** is a `NSStatusItem` (`variableLength`) with a template icon and a `\(batterySoC)%` title. The popover is `transient` and hosted via `NSHostingController(rootView: GrowattPopoverView(viewModel:))`.
- The app is an **accessory** (no Dock icon). Activation policy is set in `AppDelegate.applicationDidFinishLaunching`.
- All UI text must respect **Dynamic Type**; all interactive controls must have a **VoiceOver** label. Honor **Reduce Motion** for power-flow transitions.

## Testing

- Framework: **Swift Testing** (`import Testing`, `@Test`, `#expect(...)`).
- Test target: `Tests/GrowattToolbarTests/`. The runner executable `Tests/GrowattToolbarTestRunner/main.swift` is reserved for ad-hoc execution.
- What to test:
  - `InverterStatus` clamping and `formattedPowerDescription` per state.
  - `MockGrowattAPIService` happy path and the `shouldThrowError: true` path.
  - `InverterViewModel` initial state, `refreshData()` success, `refreshData()` failure, and polling lifecycle.
- After every implementation step: run `swift test` and confirm the suite is green before moving on.
