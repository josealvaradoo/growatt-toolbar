import SwiftUI

/// Status pill for the active inverter state. The pill surface uses a tinted
/// Liquid Glass effect on macOS 26 (`.glassEffect(.regular.tint(accentColor))`)
/// and falls back to a state-tinted solid on macOS 15. Honors
/// `accessibilityReduceTransparency`.
public struct PowerFlowBadgeView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    public let state: InverterState
    public let powerDescription: String

    public init(state: InverterState, powerDescription: String) {
        self.state = state
        self.powerDescription = powerDescription
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: state.iconName)
                    .font(.caption.bold())
                Text(state.title)
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background { badgeBackground }

            Text(powerDescription)
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var badgeBackground: some View {
        if reduceTransparency {
            Capsule().fill(state.accentColor.opacity(0.18))
        } else if #available(macOS 26, *) {
            Capsule()
                .fill(Color.clear)
                .glassEffect(.regular.tint(state.accentColor), in: Capsule())
        } else {
            Capsule().fill(state.accentColor.opacity(0.22))
        }
    }
}

struct PowerFlowBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            PowerFlowBadgeView(state: .charging, powerDescription: "+3.2 kW grid power")
                .padding()
        }
    }
}
