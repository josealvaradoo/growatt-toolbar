import SwiftUI

/// First-launch content: welcome copy, value proposition, an explanation of
/// what credentials are collected and why, and setup progress. Rendered above
/// the connection form in onboarding mode. No bundled branding asset exists
/// in the Core bundle, so the mark falls back to a restrained SF Symbol.
public struct OnboardingContentView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.md) {
            HStack(spacing: GlassTokens.Spacing.md) {
                Image(systemName: "bolt.batteryblock.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: GlassTokens.Spacing.xxs) {
                    Text("Welcome to Growatt Toolbar")
                        .font(.title3.bold())
                        .accessibilityLabel("Welcome to Growatt Toolbar")
                    Text("Your inverter, one glance away.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text("This app puts your Growatt inverter's battery level, charging state, and home power draw in the macOS menu bar. To fetch that data it needs a single connection: your inverter's local API.")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Text("What we ask for: only your API URL and API key. The key is stored securely in your Mac's Keychain and is never logged, shared, or sent anywhere except your inverter's own API.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Label("Step 1 of 1 — Connect your inverter", systemImage: "1.circle.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Step 1 of 1. Connect your inverter.")
        }
    }
}
