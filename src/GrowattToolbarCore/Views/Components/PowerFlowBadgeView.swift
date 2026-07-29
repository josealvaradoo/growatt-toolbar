import SwiftUI

/// Badge component displaying the current inverter state pill and active power rate description.
public struct PowerFlowBadgeView: View {
    public let state: InverterState
    public let powerDescription: String

    public init(state: InverterState, powerDescription: String) {
        self.state = state
        self.powerDescription = powerDescription
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Status Pill Badge
            HStack(spacing: 6) {
                Image(systemName: state.iconName)
                    .font(.caption.bold())
                Text(state.title)
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(Color.black.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                state.accentColor,
                                state.accentColor.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: state.accentColor.opacity(0.6), radius: 8, x: 0, y: 2)
            }

            // Power Description Subtitle
            Text(powerDescription)
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(.secondary)
        }
    }
}

struct PowerFlowBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            PowerFlowBadgeView(state: .charging, powerDescription: "+3.2 kW grid power")
                .padding()
        }
    }
}
