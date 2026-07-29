# Changelog

All notable changes to **Growatt Toolbar Status** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

### Bug fixes

- make status bar button title reactive to InverterViewModel.status so it reflects the latest batterySoC without opening the popover

### Features

- add liquid glass design tokens (GlassTokens) shared across the popover hierarchy
- expose GlassTokens as public so the public component API can reference the shared radii and padding
