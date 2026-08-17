# 001 Liquid Glass Popover Content Blur — Tasks

Each task is atomic, independently shippable, and verifiable. Execute in order. Stop and update the spec if a task reveals new requirements. Work on branch `fix/liquid-glass-popover-content-blur` and commit after each task with a conventional message referencing `specs/001-liquid-glass-popover-content-blur/` (see `git-workflow` skill).

## T-001: Remove the `GlassEffectContainer` from the popover content tree

- **Objective**: Delete the `.glassContainer(spacing: GlassTokens.Spacing.lg)` modifier call — and its 7-line comment block — from `GrowattPopoverView.body` so no interior content is captured into a glass rendering pass (fixes RC-1, the primary defect).
- **Depends on**: (none)
- **Inputs**: `specs/001-liquid-glass-popover-content-blur/spec.md` (RC-1); `src/GrowattToolbarCore/Views/GrowattPopoverView.swift` lines 38–46.
- **Outputs**: `src/GrowattToolbarCore/Views/GrowattPopoverView.swift` (modifier call + comment block removed; `.background { popoverBackground }` becomes the last modifier on the root `VStack`).
- **Acceptance check**:
  - [ ] `GrowattPopoverView.swift` contains no `.glassContainer(` call (maps to EARS Ubiquitous #3, Event-driven #1).
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `fix(ui): remove GlassEffectContainer from popover content tree` (refs spec).

## T-002: Switch the shell glass variant from `.clear` to `.regular`

- **Objective**: In `GrowattPopoverView.popoverBackground`, change `.glassEffect(.clear, in: shape)` to `.glassEffect(.regular, in: shape)` and replace the surrounding comment with the Regular-variant rationale (fixes RC-2 and RC-3).
- **Depends on**: T-001
- **Inputs**: spec.md (RC-2, RC-3); plan.md (Decision D-2, D-3, target code shape); `src/GrowattToolbarCore/Views/GrowattPopoverView.swift` (`popoverBackground`).
- **Outputs**: `src/GrowattToolbarCore/Views/GrowattPopoverView.swift` (variant switch + comment); the RT (`windowBackgroundColor`) and macOS 15 (`.ultraThinMaterial`) branches untouched.
- **Acceptance check**:
  - [ ] `grep -R "\.clear, in:" src/` returns zero hits (maps to EARS Ubiquitous #4, Unwanted #2).
  - [ ] `popoverBackground`'s macOS 26 branch uses `.glassEffect(.regular, in: shape)`; the other two branches are byte-identical to before (maps to EARS Event-driven #2, State-driven #1).
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `fix(ui): use regular Liquid Glass variant for popover shell` (refs spec).

## T-003: Delete the dead `GlassContainerModifier`

- **Objective**: Delete `src/GrowattToolbarCore/Views/Components/GlassContainerModifier.swift` in full — its sole call site was removed in T-001, and keeping the modifier invites a third regression.
- **Depends on**: T-001
- **Inputs**: plan.md (Decision D-1); `src/GrowattToolbarCore/Views/Components/GlassContainerModifier.swift`.
- **Outputs**: file deleted; no other file references it.
- **Acceptance check**:
  - [ ] `grep -R "GlassEffectContainer\|glassContainer" src/` returns zero hits (maps to EARS Ubiquitous #3, Unwanted #1).
  - [ ] `swift build` passes with 0 errors, 0 warnings (proves no dangling references).
  - [ ] Committed as `refactor(ui): delete unused GlassContainerModifier` (refs spec).

## T-004: Collapse identical Reduce-Transparency background branches

- **Objective**: In `GrowattPopoverView.heroBackground`, `PowerMetricTileView.background`, and `ErrorBannerView.background`, collapse the `if reduceTransparency { X } else { X }` branches (both return the same opaque fill) into a single `RoundedRectangle(...).fill(Color(nsColor: .controlBackgroundColor))` expression; remove the now-unused `@Environment(\.accessibilityReduceTransparency)` property from `PowerMetricTileView` and `ErrorBannerView` only (`GrowattPopoverView` keeps its property — still used by `popoverBackground`). Pure hygiene; zero behavior change.
- **Depends on**: T-002
- **Inputs**: plan.md (Decision D-4, target code shape); the three component files.
- **Outputs**: `src/GrowattToolbarCore/Views/GrowattPopoverView.swift`, `src/GrowattToolbarCore/Views/Components/PowerMetricTileView.swift`, `src/GrowattToolbarCore/Views/Components/ErrorBannerView.swift`.
- **Acceptance check**:
  - [ ] Each of the three backgrounds is a single fill expression with no `if/else`; `controlBackgroundColor` preserved (maps to EARS State-driven #1, FR-4).
  - [ ] No unused `reduceTransparency` properties remain in the two component files.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `refactor(ui): collapse identical reduce-transparency background branches` (refs spec).

## T-005: Update code comments and amend the `DESIGN.md` container rule

- **Objective**: (a) Update `GrowattPopoverView`'s top doc comment so it describes the actual architecture (Regular glass shell as a root background, no container, opaque inner cards). (b) Amend the `DESIGN.md` Do-rule "Wrap every group of two or more nearby glass elements in a `GlassEffectContainer(spacing:)`" to its correct scope, and document the popover-shell pattern.
- **Depends on**: T-004
- **Inputs**: spec.md (RC-1 evidence); plan.md (Decision D-1); `DESIGN.md` (Do's and Don'ts); `GrowattPopoverView.swift` top doc comment.
- **Outputs**: `DESIGN.md`; `src/GrowattToolbarCore/Views/GrowattPopoverView.swift`.
- **Acceptance check**:
  - [ ] `DESIGN.md` states that a `GlassEffectContainer` is scoped **only** to clusters of adjacent glass elements that must blend/morph, must never wrap a content hierarchy or a full-size background glass, and that `glassEffect` captures content sent to the container (maps to FR-6).
  - [ ] `DESIGN.md` documents the popover-shell pattern: one `.glassEffect(.regular, in:)` root background, opaque inner cards, no container.
  - [ ] `GrowattPopoverView`'s doc comment contains no reference to a shared sampling region / `glassContainer`.
  - [ ] `swift build` passes with 0 errors, 0 warnings.
  - [ ] Committed as `docs: scope GlassEffectContainer rule and document popover shell pattern` (refs spec).

## T-006: Append the `0.2.13` block to `CHANGELOG.md`

- **Objective**: Add a `## 0.2.13 (2026-07-30)` block with a `### Fix` section describing the three root causes and the fix, per the `changelog` skill and the existing file's style.
- **Depends on**: T-005
- **Inputs**: spec.md (Root-Cause Analysis); `CHANGELOG.md` (style of the `0.2.11`/`0.2.12` entries).
- **Outputs**: `CHANGELOG.md`.
- **Acceptance check**:
  - [ ] New dated `0.2.13` block at the top of the versions list (after the header, before `0.2.12`), `### Fix` section, entries covering: container removal, `.clear`→`.regular` switch, `GlassContainerModifier` deletion, dead-branch collapse, DESIGN.md amendment — and explicitly noting this supersedes the incorrect `0.2.12` rationale.
  - [ ] Committed as `docs: changelog 0.2.13 liquid glass content blur fix` (refs spec).

## T-007: Full verification pass

- **Objective**: Run every gate from the plan's Test Strategy and confirm the spec's symptom table is fully resolved.
- **Depends on**: T-006
- **Inputs**: plan.md (Test Strategy); spec.md (Symptom table, EARS).
- **Outputs**: verification results noted in the PR description; no code changes expected.
- **Acceptance check**:
  - [ ] `swift build` — 0 errors, 0 warnings.
  - [ ] `grep -R "GlassEffectContainer\|glassContainer" src/` → zero hits; `grep -R "\.clear, in:" src/` → zero hits.
  - [ ] `swift run GrowattToolbarApp`, open popover: title, `Live` pill, `100%` numeral, battery bar, `Home Load` tile all sharp (compare with pre-fix screenshot) — maps to EARS Ubiquitous #1.
  - [ ] Shell translucency, specular rim, and desktop sampling intact — maps to EARS Ubiquitous #2.
  - [ ] Badge tint correct on state switch; refresh button glass + spinner correct; no ghost/smear under the popover arrow.
  - [ ] Dark and Light appearances both legible with no manual color overrides — maps to EARS Optional #1.
  - [ ] Reduce Transparency ON → opaque fallbacks, sharp; OFF → glass restored — maps to EARS State-driven #1.
  - [ ] Freshness states checked where feasible: `.awaiting` (launch), `.live`, `.stale` (stop local API), `.error` (bad `GROWATT_API_KEY`) — all sharp.
  - [ ] macOS 15 code path verified by inspection: `#available` fallbacks untouched by the diff — maps to EARS Event-driven #2.

## Verification (after all tasks)

- [ ] Every EARS acceptance criterion from spec.md is covered by a passing check above.
- [ ] `swift build` passes with 0 errors, 0 warnings.
- [ ] Manual visual smoke test (T-007) passes in full.
- [ ] `git-workflow` skill conventions followed: `fix/liquid-glass-popover-content-blur` branch, conventional commits, each referencing `specs/001-liquid-glass-popover-content-blur/`.
- [ ] PR description references `specs/001-liquid-glass-popover-content-blur/` and includes before/after screenshots (see `create-pull-request` skill).
