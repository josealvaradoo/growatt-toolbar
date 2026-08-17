# Implementation Tasks

## Phase 1 — Foundation

- [ ] **T-001: Add test target and test infrastructure**
  - Files: `Package.swift`, `Tests/...`
  - Depends on: none
  - Acceptance: `swift test` discovers the new target.

- [ ] **T-002: Define settings mode and connection-test protocol**
  - Files: `SettingsMode.swift`, `GrowattConnectionTesterProtocol.swift`
  - Depends on: T-001
  - Acceptance: public Core types compile and remain AppKit-free.

- [ ] **T-003: Make service construction safe**
  - Files: `GrowattOpenAPIService.swift`, `GrowattAPIError.swift`
  - Depends on: T-002
  - Acceptance: invalid URL input produces a typed failure; no production `fatalError` remains in this path.

- [ ] **T-004: Implement temporary connection tester**
  - Files: `GrowattConnectionTester.swift`
  - Depends on: T-003
  - Acceptance: tester calls `/status` with draft credentials and performs no persistence.

## Phase 2 — State and persistence

- [ ] **T-005: Implement settings view model**
  - Files: `SettingsViewModel.swift`
  - Depends on: T-002, T-004
  - Acceptance: validation, loading, success, invalidation, and failure states are testable.

- [ ] **T-006: Harden preferences save boundaries**
  - Files: `AppPreferences.swift`
  - Depends on: T-005
  - Acceptance: failed persistence preserves draft state and does not mark onboarding complete.

- [ ] **T-007: Add lifecycle and security unit tests**
  - Files: `SettingsViewModelTests.swift`, test doubles
  - Depends on: T-005, T-006
  - Acceptance: tests cover test-before-save, edit invalidation, duplicate prevention, persistence boundaries, and safe error mapping.

## Phase 3 — SwiftUI composition

- [ ] **T-008: Build native sidebar shell**
  - Files: `SettingsView.swift`, `SettingsSidebarView.swift`
  - Depends on: T-005
  - Acceptance: `NavigationSplitView` renders Connection and supports future destinations.

- [ ] **T-009: Build onboarding content**
  - Files: `OnboardingContentView.swift`
  - Depends on: T-008
  - Acceptance: welcome copy, value proposition, branding fallback, progress context, and CTA exist.

- [ ] **T-010: Build connection form and status feedback**
  - Files: `ConnectionFormView.swift`, `ConnectionStatusView.swift`
  - Depends on: T-005, T-008
  - Acceptance: SecureField, URL field, validation, Test Connection, Save/Update, loading, success, and error states work.

- [ ] **T-011: Add accessibility and appearance behavior**
  - Files: settings view files
  - Depends on: T-009, T-010
  - Acceptance: VoiceOver labels/hints, keyboard navigation, Dynamic Type, dark mode, Increase Contrast, Reduce Transparency, and Reduce Motion are addressed.

## Phase 4 — AppKit integration

- [ ] **T-012: Update SettingsWindowController**
  - Files: `SettingsWindowController.swift`
  - Depends on: T-008 through T-011
  - Acceptance: fixed native window presents the correct mode and handles close/Escape rules.

- [ ] **T-013: Update AppDelegate lifecycle**
  - Files: `GrowattToolbarApp.swift`
  - Depends on: T-006, T-012
  - Acceptance: onboarding completion starts runtime service; settings updates replace runtime configuration; failed saves do not.

- [ ] **T-014: Verify macOS 15/26 compatibility**
  - Files: settings views and window controller
  - Depends on: T-012, T-013
  - Acceptance: macOS 15 uses a solid adaptive system background and no unguarded macOS 26-only APIs exist.

## Phase 5 — Documentation and verification

- [ ] **T-015: Update product documentation**
  - Files: `PRODUCT.md`
  - Depends on: T-013
  - Acceptance: documentation states that a settings/onboarding window exists and accurately describes its role.

- [ ] **T-016: Run full verification**
  - Files: repository-wide
  - Depends on: all previous tasks
  - Acceptance: `swift build`, `swift test`, and `swift build -c release` pass without warnings; manual accessibility and appearance checks pass; no credential leakage is found.

- [ ] **T-017: Append changelog entry**
  - Files: `CHANGELOG.md`
  - Depends on: T-016
  - Acceptance: dated `MAJOR.MINOR.PATCH` entry documents the redesign.
