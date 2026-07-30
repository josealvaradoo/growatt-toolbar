import SwiftUI

/// Indeterminate battery bar shown in the popover's `.awaiting` state.
///
/// A thin track with a soft shimmer that sweeps left-to-right, telling the
/// user the reading is in flight without lying about the percentage. The
/// shimmer is a CSS-style linear gradient masked to a 35%-wide capsule,
/// offset by a time-driven phase so it animates without driving SwiftUI
/// state changes (the view re-renders naturally on the parent's
/// `TimelineView` tick).
///
/// Honors `accessibilityReduceMotion` by holding the shimmer offscreen.
public struct BatteryIndicatorPlaceholder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public var body: some View {
        HStack(spacing: GlassTokens.Spacing.xs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.black.opacity(0.18))

                    if !reduceMotion {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.0),
                                        .white.opacity(0.45),
                                        .white.opacity(0.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * 0.35)
                            .offset(x: shimmerOffset(in: geometry.size.width))
                    }
                }
            }
            .frame(height: 38)

            RoundedRectangle(cornerRadius: GlassTokens.Radius.terminal, style: .continuous)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 5, height: 16)
        }
        .accessibilityHidden(true)
    }

    private func shimmerOffset(in width: CGFloat) -> CGFloat {
        let span = width * 1.35
        let phase = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 1.6) / 1.6
        return -width * 0.35 + span * phase
    }
}

struct BatteryIndicatorPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: GlassTokens.Spacing.xl) {
            BatteryIndicatorPlaceholder()
                .frame(width: 280)
        }
        .padding()
        .background(Color.black)
    }
}
