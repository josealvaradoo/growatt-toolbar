import SwiftUI

/// Animated visual battery gauge displaying state of charge percentage with
/// state-based gradient fills.
///
/// The gradient stops are **semantic system colors** (`.green` / `.orange`)
/// so the bar automatically respects `accessibilityIncreaseContrast`,
/// Light / Dark appearance, and the user's chosen accent. The spring
/// animation that drives the fill width on level changes is gated on
/// `accessibilityReduceMotion` — users who opt out of motion still see
/// the new level communicated through the fill width and the parent
/// accessibility label, just without the spring.
public struct BatteryIndicatorView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    public let levelPercentage: Int
    public let state: InverterState

    public init(levelPercentage: Int, state: InverterState) {
        self.levelPercentage = min(max(levelPercentage, 0), 100)
        self.state = state
    }

    /// Semantic gradient stops for the current battery state. Both stops
    /// are system colors (`Color.green` / `Color.orange`) modulated by
    /// opacity, so the bar tracks the user's contrast preference, the
    /// chosen accent, and the current appearance without code changes.
    private var gradientColors: [Color] {
        switch state {
        case .charging:
            return [.green, .green.opacity(0.8)]
        case .discharging:
            return [.orange, .orange.opacity(0.8)]
        }
    }

    /// `nil` when `accessibilityReduceMotion` is on — passing `nil` to
    /// `.animation(_:value:)` disables the animation for that value change
    /// without removing the modifier from the view tree.
    private var levelAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.8)
    }

    private var stateAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.3)
    }

    public var body: some View {
        HStack(spacing: GlassTokens.Spacing.xs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: BatteryGeometry.trackCornerRadius, style: .continuous)
                        .fill(.black.opacity(0.4))
                        .overlay {
                            RoundedRectangle(cornerRadius: BatteryGeometry.trackCornerRadius, style: .continuous)
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        }

                    RoundedRectangle(cornerRadius: BatteryGeometry.fillCornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(BatteryGeometry.fillInset)
                        .frame(width: max(0, (geometry.size.width - BatteryGeometry.fillInset * 2) * CGFloat(levelPercentage) / 100.0))
                        .animation(levelAnimation, value: levelPercentage)
                        .animation(stateAnimation, value: state)
                }
            }
            .frame(height: BatteryGeometry.barHeight)

            RoundedRectangle(cornerRadius: GlassTokens.Radius.terminal, style: .continuous)
                .fill(.white.opacity(0.3))
                .frame(width: BatteryGeometry.tipWidth, height: BatteryGeometry.tipHeight)
        }
        // Combine so VoiceOver reads the parent label as a single
        // utterance, not as "rounded rectangle, rounded rectangle, 73, charging".
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Battery Level \(levelPercentage) percent, \(state.title)")
    }
}

/// Geometric constants for the battery indicator. Kept local to this
/// component because the values are specific to the battery bar's
/// physical proportions; promoting them to `GlassTokens` would be
/// system abstraction for one local exception. (`GlassTokens.Radius.terminal`
/// earns its token status because both `BatteryIndicatorView` and
/// `BatteryIndicatorPlaceholder` use it.)
private enum BatteryGeometry {
    /// Outer track corner radius (the dark capsule behind the fill).
    static let trackCornerRadius: CGFloat = 12
    /// Inner fill corner radius — 2pt less than the track so the fill
    /// sits cleanly inside the track's rounded interior.
    static let fillCornerRadius: CGFloat = 10
    /// Inset on all four sides of the fill, so it sits inside the track
    /// stroke with a 3pt margin. Doubled for the fill width math.
    static let fillInset: CGFloat = 3
    /// Bar height in points.
    static let barHeight: CGFloat = 38
    /// Battery terminal nub width.
    static let tipWidth: CGFloat = 5
    /// Battery terminal nub height.
    static let tipHeight: CGFloat = 16
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
