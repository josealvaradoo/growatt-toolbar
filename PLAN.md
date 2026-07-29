# Growatt Toolbar Status — Comprehensive Implementation Plan

## 1. General Proposal
The **Growatt Toolbar Status** application is a lightweight, modern macOS menu bar (status item) application designed for macOS Tahoe 26. It connects to Growatt energy storage systems via API (with fallback / mock server capabilities) and presents real-time inverter metrics directly in the macOS menu bar and a Liquid Glass styled popover interface.

The application allows users to monitor key inverter metrics at a glance:
- **Battery Level (% State of Charge / SoC)**
- **Inverter Operating State**: `CHARGING` (when grid or solar power is supplying the battery) or `DISCHARGING` (when the battery is actively powering the household/loads), or `IDLE`.
- Additional contextual info such as active power flow (kW) and last synced timestamp.

---

## 2. Specific Objectives
1. **Menu Bar Integration**: Display a minimal status bar item with live battery percentage and dynamic icon indicator (charging/discharging).
2. **Liquid Glass Popover UI**: Build an NSPopover / SwiftUI popover leveraging macOS Tahoe 26 visual aesthetics (lensing glass background, `.glassEffect()`, `GlassEffectContainer`, custom glass cards, vibrant status accents, SF Symbols 6+).
3. **Data Layer & API Client**: Implement a robust modular architecture (SOLID) separating Network / API service layer (`GrowattAPIServiceProtocol`, `GrowattOpenAPIService`, `MockGrowattAPIService`) from models and view state logic.
4. **Reactive ViewModel**: Provide an `@Observable` `InverterViewModel` managing background polling (e.g. 30s refresh), state transitions, manual refresh, error handling, and mock mode toggling.
5. **Quality & Testability**: Write unit tests for data parsing, state transformations, network error handling, and view model reactivity across small, single-responsibility files.

---

## 3. Architecture & Coding Rules (Swift 6.2 & macOS Tahoe 26 Guidelines)
- **SOLID Principles**: Single responsibility for every class/struct, Dependency Inversion for services, Interface Segregation for UI protocols.
- **Granular File Structure**: Every model, protocol, view, and helper resides in its own isolated `.swift` file. No massive monolith files.
- **Swift 6 Concurrency & Reactivity**: Use modern `@Observable` macro, `@MainActor` isolation, async/await for data fetching.
- **macOS Tahoe 26 Liquid Glass Aesthetic**:
  - Translucent visual materials (`.ultraThinMaterial`, `.glassEffect()`).
  - Sleek glass cards for metrics display.
  - High-contrast typography and subtle micro-animations for power flow transitions.
  - Accessible VoiceOver labels and dynamic type scaling.
- **Testing**: Each component must be independently testable using Swift Testing framework (`import Testing` / `XCTest`).

---

## 4. Implementation Checklist

### Phase 1: Foundation & Data Models
- [ ] **Task 1.1**: Create `InverterState.swift` enum (`charging`, `discharging`, `idle`, `unknown`) with string representations, icon names, and badge colors.
- [ ] **Task 1.2**: Create `InverterStatus.swift` model struct (batterySoC: Int, state: InverterState, powerOutputKW: Double, batteryVoltage: Double, lastUpdated: Date).
- [ ] **Task 1.3**: Create `GrowattAPIError.swift` enum handling network failures, invalid JSON, unauthorized errors, and timeout states.
- [ ] **Task 1.4**: Unit test model parsing and state formatting in `InverterStatusTests.swift`.

### Phase 2: Network & Service Layer
- [ ] **Task 2.1**: Define `GrowattAPIServiceProtocol.swift` for fetching inverter status asynchronously.
- [ ] **Task 2.2**: Create `MockGrowattAPIService.swift` generating deterministic and toggleable mock battery data for offline testing & SwiftUI previews.
- [ ] **Task 2.3**: Create `GrowattOpenAPIService.swift` implementing real HTTP client requests to Growatt API endpoints with JSON decoding.
- [ ] **Task 2.4**: Unit test `MockGrowattAPIService` and response decoders in `GrowattAPIServiceTests.swift`.

### Phase 3: ViewModel & Application State
- [ ] **Task 3.1**: Create `@Observable` class `InverterViewModel.swift` with properties (`status`, `isLoading`, `errorMessage`, `isMockingData`, `lastRefreshTime`).
- [ ] **Task 3.2**: Implement periodic background refresh timer (Task-based async polling loop) and manual refresh command.
- [ ] **Task 3.3**: Unit test `InverterViewModel` state updates and refresh behavior in `InverterViewModelTests.swift`.

### Phase 4: macOS Tahoe 26 Liquid Glass UI
- [ ] **Task 4.1**: Create `LiquidGlassCard.swift` view component providing reusable glass backdrop card container.
- [ ] **Task 4.2**: Create `BatteryIndicatorView.swift` rendering modern visual battery level bar with state-based gradient fills.
- [ ] **Task 4.3**: Create `PowerFlowBadgeView.swift` showing animated charging/discharging status pill.
- [ ] **Task 4.4**: Create `GrowattPopoverView.swift` assembling header, status cards, refresh action buttons, and last-updated footer inside a Liquid Glass container.
- [ ] **Task 4.5**: Create `StatusBarItemView.swift` displaying high-density menu bar item representation.

### Phase 5: App Lifecycle & Menu Bar Integration
- [ ] **Task 5.1**: Create `GrowattToolbarApp.swift` (App entry point with `@NSApplicationDelegateAdaptor` or `MenuBarExtra`).
- [ ] **Task 5.2**: Implement `StatusBarController.swift` managing `NSStatusItem` and `NSPopover` positioning and click behavior.
- [ ] **Task 5.3**: Build and run test suite (`swift test` or `xcodebuild build`).

---

## 5. Verification & Testing Strategy
- Automated unit testing via `swift test` covering Data Models, Services, and ViewModels.
- Visual inspection of Liquid Glass popover styling, theme response (Dark/Light mode), and menu bar status updates.
