import SwiftUI

/// Header pill that surfaces the current `Freshness` of the inverter reading.
///
/// Renders one of four small, monospaced pairings:
///
/// - awaiting: pulsing neutral dot + "Connecting…"
/// - live:     steady green dot  + "Live"
/// - stale:    steady amber dot  + "Stale"
/// - error:    steady red dot    + "Offline"
///
/// The dot's pulse animation uses SwiftUI's built-in `.symbolEffect(.pulse)`
/// on the leading SF Symbol — Apple handles Reduce Motion automatically.
///
/// Time-aware copy ("Updated Nm ago" in the stale state) is rendered inline
/// in the hero, not in this pill, so the pill stays a compact trust signal.
struct FreshnessIndicatorView: View {
    let freshness: Freshness
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: GlassTokens.Spacing.md) {
            dot
            Text(freshness.displayTitle)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, GlassTokens.Spacing.sm)
        .padding(.vertical, GlassTokens.Spacing.xs)
        .background {
            Capsule()
                .fill(.quaternary.opacity(0.5))
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

    private var tint: Color {
        switch freshness {
        case .awaiting: return .secondary
        case .live:     return .green
        case .stale:    return .orange
        case .error:    return .red
        }
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
