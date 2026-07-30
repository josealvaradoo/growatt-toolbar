import SwiftUI

/// Compact flat accent-colored state label that lives inline in the popover's
/// state row (not the hero). Renders a leading SF Symbol direction icon, a
/// small accent dot, and the state title in a tight HStack with no background
/// of its own — the parent state row provides the glass surface.
///
/// Colors the state dot with the model's semantic `accentColor` — green for
/// charging, orange for discharging.
public struct PowerFlowBadgeView: View {
    public let state: InverterState

    public init(state: InverterState) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: GlassTokens.Spacing.xs) {
            Image(systemName: state.iconName)
                .font(.caption2)
            Circle()
                .fill(state.accentColor)
                .frame(width: 6, height: 6)
            Text(state.title)
                .font(.caption)
        }
        .foregroundStyle(.primary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Battery \(state.title)")
    }
}

struct PowerFlowBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.md) {
            PowerFlowBadgeView(state: .charging)
            PowerFlowBadgeView(state: .discharging)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
