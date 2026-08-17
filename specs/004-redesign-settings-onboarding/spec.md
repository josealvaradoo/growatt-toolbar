# Redesign Settings and Onboarding

## Problem

The current settings experience is a fixed 400x300 form with weak hierarchy, no onboarding value proposition, insufficient validation, and no connection test. Users can persist credentials that have not been verified, while product documentation incorrectly states that no settings window exists.

## Goals

- Provide distinct first-launch onboarding and returning-user settings experiences.
- Use a native macOS sidebar settings shell.
- Test credentials against `/status` before persistence.
- Preserve drafts and provide actionable, safe errors.
- Support macOS 15 through macOS 26 with adaptive system appearance.
- Keep Core free of AppKit and avoid third-party dependencies.
- Update `PRODUCT.md` to reflect the settings window.

## Non-goals

- Redesigning the menu-bar popover.
- Adding backend endpoints or changing the `/status` payload.
- Adding analytics, credential logging, or credential export.
- Adding third-party dependencies.
- Adding sidebar sections beyond Connection.

## User journeys

### First launch

1. The app launches without saved credentials.
2. An onboarding window opens with a welcome/value proposition.
3. The user sees setup context and a Connection navigation item.
4. The user enters an API URL and API key.
5. Local validation runs continuously.
6. The user tests the connection.
7. Successful testing enables Save and shows inline success.
8. Save persists credentials and starts the status-bar service.
9. Failed testing preserves input and shows safe guidance.

### Returning settings

1. The user opens Settings from the status-bar menu.
2. Existing API URL and API key are prefilled.
3. Editing either value invalidates the previous test.
4. The user must test again before Save/Update is enabled.
5. Closing with unsaved edits requires confirmation.
6. Successful update reconfigures the runtime service.

## UX behavior

- Use `NavigationSplitView` for a native macOS settings structure.
- The sidebar initially contains only a Connection item, backed by an extensible destination model.
- Use a solid adaptive system background; do not paint a floating rounded glass rectangle around the window.
- Onboarding includes restrained Growatt-G branding when the existing asset is valid, concise value proposition copy, an explanation for credential collection, setup progress/context, and one prominent CTA.
- Settings mode omits onboarding marketing copy and focuses on the connection form.
- The API key remains a `SecureField`; the existing key is displayed in the masked field when settings reopen.
- The API URL is edited as a URL-oriented text field.
- Local validation requires a non-empty trimmed API key and an `http` or `https` URL with a non-empty host.
- Test Connection constructs a temporary service from current draft values. Testing never persists credentials.
- Save is enabled only when local validation passes, the latest test succeeded, tested values equal current draft values, and no operation is active.
- Loading state disables duplicate tests and saves.
- Persistence failure keeps the draft visible and shows an actionable error.
- Onboarding cannot complete without successful test and save.
- Onboarding close/Escape remains available but explains that setup is required and keeps the setup flow active.
- Returning-settings close/Escape discards edits only after confirmation.
- API key values must not appear in logs, errors, accessibility announcements, or analytics.

## EARS acceptance criteria

- **When** the app launches without completed onboarding, **the system shall** present the onboarding-mode settings window.
- **When** onboarding is complete and stored credentials exist, **the system shall** launch the status-bar service without presenting onboarding.
- **When** the user opens settings after setup, **the system shall** present settings mode with current values prefilled.
- **When** the user selects Connection, **the system shall** display the connection form.
- **When** the API key is empty, **the system shall** disable Test Connection and Save/Update.
- **When** the URL lacks an `http`/`https` scheme or host, **the system shall** display URL validation feedback and disable Test Connection.
- **When** the user changes either draft field after a successful test, **the system shall** invalidate the prior test.
- **When** Test Connection starts, **the system shall** construct a temporary service using only current draft values.
- **While** a connection test is running, **the system shall** show progress and prevent duplicate tests and saves.
- **When** the test succeeds, **the system shall** show inline success and enable Save/Update.
- **If** authentication fails, **the system shall** explain that the API key may be invalid without exposing the key.
- **If** the network request fails, **the system shall** explain that the endpoint could not be reached and suggest checking URL/network access.
- **If** the response cannot be decoded, **the system shall** explain that the endpoint returned an unexpected response.
- **If** the server returns another error status, **the system shall** show a generic server-error message without leaking response details.
- **When** Save/Update succeeds, **the system shall** persist the key in Keychain and URL in UserDefaults.
- **If** persistence fails, **the system shall** preserve the draft and keep onboarding incomplete or runtime configuration unchanged.
- **When** onboarding Save succeeds, **the system shall** mark onboarding complete and initialize the status-bar service.
- **When** settings Save/Update succeeds, **the system shall** reconfigure the runtime service with the new credentials.
- **If** onboarding is dismissed before completion, **the system shall** explain that setup is required and keep setup active.
- **When** returning settings contain unsaved edits, **the system shall** request confirmation before discarding them.
- **The system shall** support keyboard focus traversal, default-button behavior, and native Escape handling where applicable.
- **The system shall** expose VoiceOver labels and hints for fields, actions, validation, progress, and errors.
- **The system shall** support Dynamic Type, dark mode, Increase Contrast, Reduce Transparency, and Reduce Motion.
- **The system shall** provide a macOS 15 fallback without unguarded macOS 26-only APIs.
- **The system shall** build and pass automated tests with `swift build` and `swift test`.

## Risks and resolved decisions

- Use a dedicated injectable connection-testing abstraction rather than coupling SwiftUI to the concrete service.
- Refactor service construction away from `fatalError`; invalid draft URLs must be typed failures.
- Map typed failures to safe UI messages rather than exposing technical details.
- Keep the window at a fixed native size and use internal scrolling for larger accessibility text.
- Fall back to restrained SF Symbols/text if the existing branding asset is unsuitable.
- Update `PRODUCT.md`; its previous no-settings-window constraint is obsolete.
