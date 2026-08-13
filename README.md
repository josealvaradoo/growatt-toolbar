# Growatt Toolbar Status

Growatt Toolbar Status is a small, native macOS menu bar app for people who
want a quick view of their Growatt inverter without opening a dashboard. It
shows:

- Battery state of charge.
- Charging or discharging state.
- Current home consumption in kW.
- Whether the reading is live, stale, awaiting data, or offline.

The app lives in the menu bar and opens a compact Liquid Glass-style popover.
It is built for technology enthusiasts who are comfortable providing a local
API endpoint and troubleshooting their own inverter/network setup.

> **Not an official Growatt product.** This is an independent, community-made
> tool and is not affiliated with, endorsed by, or supported by Growatt. Use it
> at your own risk. It is a read-only status viewer, not an inverter control
> or safety system.

## Requirements

- macOS 15 Sequoia or newer.
- A Growatt inverter or gateway exposing the compatible local `/status`
  endpoint.
- An API URL and API key accepted by that endpoint.
- Xcode command-line tools, or Xcode, for building from source.
- Swift 6 toolchain for development.

macOS 26 Tahoe uses the app's Liquid Glass APIs. macOS 15 uses the supported
material and system-color fallbacks.

## Install and Configure

The app has a native first-launch setup window:

1. Launch the app.
2. Enter the base API URL and API key.
3. Select **Test Connection**.
4. Select **Save & Start Monitoring** after the test succeeds.

The API key is stored in the macOS Keychain. The API URL is stored in
`UserDefaults`. The key is not logged or sent anywhere except the configured
API endpoint. Reopen setup by right-clicking the menu bar item and choosing
**Settings…**. Saving requires a successful test against the exact current
draft values.

The app expects a response shaped like this from `GET {API_URL}/status`:

```json
{
  "data": {
    "level": 73,
    "is_charging": true,
    "output_power": 3200
  }
}
```

`level` is treated as a percentage and clamped to 0–100. `output_power` is
interpreted as watts of home consumption and displayed in kilowatts. The
request uses `GET`, an `Accept: application/json` header, and the
`x-api-key` header.

## Build From Source

```sh
swift build
swift test
swift run GrowattToolbarApp
```

For a release build and a locally packaged app or DMG:

```sh
make build
make app
make dmg
```

Build output is placed under `dist/`. The packaged app is ad-hoc signed, so
macOS may require confirmation in **Privacy & Security** on first launch.

For debug development, copy `.env.example` to `.env` and provide values for
`API_KEY` and `API_URL`. `.env` loading is debug-only; release builds use the
onboarding/settings flow and persisted credentials instead.

## Runtime Behavior

- Background polling runs every two minutes.
- The manual refresh button requests a non-cached reading with
  `?cache=false`; background polling leaves upstream caching enabled.
- Concurrent refreshes are serialized, so polling and manual refresh cannot
  overwrite each other unpredictably.
- Before the first successful response, the UI shows a connecting placeholder
  rather than fake zero values.
- Network, authorization, server, decoding, and Keychain failures are typed
  and mapped to credential-safe user messages.
- A right-click on the status item opens **Settings…** and **Quit**.

The status item shows the current battery percentage. The popover includes the
battery level, charging direction, home load, freshness signal, and recovery
refresh action. Accessibility labels, Reduce Motion, Reduce Transparency, and
system appearance are respected.

## Project Layout

- `src/GrowattToolbarCore/` contains models, services, view models, and SwiftUI
  views. It has no menu bar lifecycle code.
- `src/GrowattToolbarApp/` contains the AppKit shell, status item, popover
  hosting, settings window lifecycle, and packaging resources.
- `Tests/GrowattToolbarCoreTests/` contains service and settings/view-model
  tests, including mocked HTTP responses.
- `CHANGELOG.md` records the project's implementation history.

The service boundary is `GrowattAPIServiceProtocol`. The runtime client is
`GrowattOpenAPIService`; UI state is owned by `@Observable` main-actor view
models. The project intentionally has no third-party dependencies.

## Troubleshooting

- **The connection test fails:** confirm the base URL is reachable from the
  Mac, uses `http://` or `https://`, and that `/status` returns the documented
  JSON shape.
- **Unauthorized:** verify the API key and confirm it is accepted by the
  inverter's local API.
- **The reading is stale or offline:** check local network reachability and use
  the popover refresh button to request a fresh reading.
- **The app does not appear:** launch it again and check the menu bar; it runs
  as an accessory app and intentionally does not create a Dock icon.

## License and Responsibility

This repository is an independent hobbyist project. Review the source,
network behavior, and packaging scripts before using it on your system. Do not
rely on this app for electrical, battery, backup-power, or safety decisions.
