import SwiftUI

/// Compact inline indicator that surfaces the current `Freshness` of the
/// inverter reading. Rendered as an unadorned dot + text pair — no background
/// capsule — so it blends into the parent surface (the popover's glass shell).
///
/// The dot is a binary trust signal in Apple's system colors: green while the
/// reading is `live`, red for every other category (awaiting / stale / error).
/// Copy still differentiates the non-live categories:
///
/// - awaiting: pulsing red dot  + "Connecting…"
/// - live:     steady green dot + "Live"
/// - stale:    steady red dot   + "Stale"
/// - error:    steady red dot   + "Offline"
///
/// The dot's pulse animation uses SwiftUI's built-in `.symbolEffect(.pulse)`
/// on the leading SF Symbol — Apple handles Reduce Motion automatically.
/// The pulse is additionally gated on `accessibilityReduceMotion` for safety.
///
/// Time-aware copy ("Updated Nm ago" in the stale state) is rendered inline
/// in the hero, not in this indicator, so this stays a compact trust signal.
struct FreshnessIndicatorView: View {
    let freshness: Freshness
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: GlassTokens.Spacing.xs) {
            dot
            Text(freshness.displayTitle)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(freshness.accessibilityLabel())
    }

    @ViewBuilder
    private var dot: some View {
        Image(systemName: freshness.leadingSymbol)
            .font(.caption2)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(tint)
            .modifier(PulseIfActiveModifier(
                isActive: freshness == .awaiting && !reduceMotion
            ))
    }

    /// Binary trust signal in Apple Design System colors: `systemGreen` while
    /// live, `systemRed` for any degraded category. The state signal
    /// (charging/discharging) in `PowerFlowBadgeView` uses the accent only —
    /// the two axes are intentionally independent per the design spec.
    private var tint: Color {
        freshness == .live ? .green : .red
    }
}

/// Pulses the modified view while `isActive` is true. Static when false.
/// Built on SwiftUI's `.symbolEffect(.pulse.byLayer)` so the system handles
/// Reduce Motion without us re-implementing the toggle.
private struct PulseIfActiveModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content.symbolEffect(.pulse.byLayer, options: .repeating)
        } else {
            content
        }
    }
}

struct FreshnessIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .trailing, spacing: GlassTokens.Spacing.md) {
            FreshnessIndicatorView(freshness: .awaiting)
            FreshnessIndicatorView(freshness: .live)
            FreshnessIndicatorView(freshness: .stale)
            FreshnessIndicatorView(freshness: .error)
        }
        .padding()
        .frame(width: 240)
    }
}
