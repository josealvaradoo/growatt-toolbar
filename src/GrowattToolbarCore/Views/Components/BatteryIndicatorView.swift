import SwiftUI

/// A thin, neutral battery gauge — a Control Center tile that shows state of
/// charge only (how full), not state direction (charging vs. discharging).
/// The fill and track use system-neutral opacities so the bar reads as a
/// gauge rather than a status indicator; state direction is conveyed by the
/// accent label in the parent state row, never by bar colour.
///
/// The fill-width spring animation is gated on `accessibilityReduceMotion` —
/// users who opt out of motion still see the new level communicated through
/// the fill width and the parent accessibility label, just without animation.
public struct BatteryIndicatorView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    public let levelPercentage: Int
    public let state: InverterState

    public init(levelPercentage: Int, state: InverterState) {
        self.levelPercentage = min(max(levelPercentage, 0), 100)
        self.state = state
    }

    /// `nil` when `accessibilityReduceMotion` is on — passing `nil` to
    /// `.animation(_:value:)` disables the animation for that value change
    /// without removing the modifier from the view tree.
    private var levelAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.8)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: BatteryGeometry.trackCornerRadius, style: .continuous)
                    .fill(.primary.opacity(0.12))

                RoundedRectangle(cornerRadius: BatteryGeometry.fillCornerRadius, style: .continuous)
                    .fill(.primary.opacity(0.6))
                    .frame(width: max(0, (geometry.size.width - BatteryGeometry.fillInset * 2) * CGFloat(levelPercentage) / 100.0))
                    .padding(BatteryGeometry.fillInset)
                    .animation(levelAnimation, value: levelPercentage)
            }
        }
        .frame(height: BatteryGeometry.barHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Battery Level \(levelPercentage) percent, \(state.title)")
    }
}

/// Geometric constants for the thin neutral battery gauge.
private enum BatteryGeometry {
    static let trackCornerRadius: CGFloat = 6
    static let fillCornerRadius: CGFloat = 5
    static let fillInset: CGFloat = 2
    static let barHeight: CGFloat = 12
}

struct BatteryIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: GlassTokens.Spacing.xl) {
                BatteryIndicatorView(levelPercentage: 85, state: .charging)
                BatteryIndicatorView(levelPercentage: 42, state: .discharging)
            }
            .padding()
            .frame(width: 300)
        }
    }
}
