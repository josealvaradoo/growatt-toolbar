import SwiftUI

/// Status pill for the active inverter battery state.
///
/// The pill surface uses a tinted Liquid Glass effect on macOS 26
/// (`.glassEffect(.regular.tint(accentColor))`) and falls back to a
/// state-tinted solid on macOS 15. Honors `accessibilityReduceTransparency`.
///
/// Pure state indicator — shows only the battery direction (Charging /
/// Discharging) and the state icon. The home consumption value lives
/// in the `PowerMetricTileView` ("Home Load") in the popover's metrics
/// row, which is its single labeled reading. Keeping the value out of
/// the badge avoids duplicating it in the hero.
public struct PowerFlowBadgeView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    public let state: InverterState

    public init(state: InverterState) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: GlassTokens.Spacing.md) {
            Image(systemName: state.iconName)
                .font(.caption.bold())
            Text(state.title)
                .font(.caption.bold())
                .fontDesign(.rounded)
        }
        .foregroundStyle(.primary)
        // 10pt horizontal: 8pt sm + 2pt xxs optical correction (capsule sides)
        .padding(.horizontal, GlassTokens.Spacing.sm + GlassTokens.Spacing.xxs)
        // 5pt vertical: 4pt xs + 1pt hairline optical correction (capsule top/bottom)
        .padding(.vertical, GlassTokens.Spacing.xs + GlassTokens.Spacing.hairline)
        .background { badgeBackground }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Battery \(state.title)")
    }

    @ViewBuilder
    private var badgeBackground: some View {
        if reduceTransparency {
            // RT fallback: lower opacity because the background is already solid
            Capsule().fill(state.accentColor.opacity(0.18))
        } else if #available(macOS 26, *) {
            Capsule()
                .fill(Color.clear)
                .glassEffect(.regular.tint(state.accentColor), in: Capsule())
        } else {
            // macOS 15 fallback: slightly higher opacity since the capsule
            // sits on a translucent material, not a solid surface
            Capsule().fill(state.accentColor.opacity(0.22))
        }
    }
}

struct PowerFlowBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .trailing, spacing: GlassTokens.Spacing.lg) {
            PowerFlowBadgeView(state: .charging)
            PowerFlowBadgeView(state: .discharging)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
