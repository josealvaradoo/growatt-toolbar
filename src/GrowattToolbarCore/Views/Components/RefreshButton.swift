import SwiftUI

/// Refresh control used by both the popover footer and the error banner.
///
/// Single source of truth for the refresh affordance. Replaces the two
/// byte-identical 33-line hand-rolled glass blocks that lived in
/// `GrowattPopoverView` and `ErrorBannerView` before the polish pass.
///
/// Behavior contract:
/// - On macOS 26+: uses the system `ButtonStyle.glass`, which provides
///   the liquid-glass material, hover/press/disabled states, and a
///   compact hit target via `controlSize(.small)` that fits the
///   280pt popover's state row.
/// - On macOS 15: falls back to `ButtonStyle.bordered` (a system style
///   with proper hit target and disabled state) — no hand-rolled glass.
/// - The rotation animation is gated on `accessibilityReduceMotion` so
///   the spinner holds still for users who opt out of motion.
/// - The button is disabled while `isLoading` is true, so the user gets
///   a clear visual cue that the request is in flight (no more
///   "I clicked it, nothing happened" perception).
public struct RefreshButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    public let isLoading: Bool
    public let action: () -> Void

    public init(isLoading: Bool, action: @escaping () -> Void) {
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.clockwise")
                .font(.body.bold())
                .rotationEffect(.degrees(isLoading && !reduceMotion ? 360 : 0))
                // 1s linear rotation: matches Apple's system spinners
                // (1 full revolution per second is the platform convention).
                .animation(
                    isLoading && !reduceMotion
                    ? .linear(duration: 1).repeatForever(autoreverses: false)
                    : .default,
                    value: isLoading
                )
        }
        .controlSize(.small)
        .disabled(isLoading)
        .accessibilityLabel("Refresh")
        // Tooltip teaches the user what the button does and that the
        // popover auto-refreshes every 2 minutes — closes 1 H10 point
        // (Alex learns the manual refresh isn't the only mechanism).
        .help("Refresh the inverter reading. The popover auto-refreshes every 2 minutes.")
        .modifier(RefreshButtonStyle())
    }
}

/// Applies the platform-appropriate button style. On macOS 26+ the
/// system `ButtonStyle.glass` is used; on macOS 15 the fallback is
/// `ButtonStyle.bordered` (a system style that still provides proper
/// hit target and disabled state).
private struct RefreshButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
    }
}

struct RefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: GlassTokens.Spacing.xl) {
            HStack(spacing: GlassTokens.Spacing.md) {
                RefreshButton(isLoading: false) {}
                RefreshButton(isLoading: true) {}
            }
        }
        .padding()
    }
}
