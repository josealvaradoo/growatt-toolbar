import SwiftUI

/// Compact menu bar status item view displaying battery icon indicator and percentage.
public struct StatusBarItemView: View {
    public let soc: Int
    public let state: InverterState

    public init(soc: Int, state: InverterState) {
        self.soc = soc
        self.state = state
    }

    public var body: some View {
        HStack(spacing: 5) {
            Image(systemName: state == .charging ? "bolt.batteryblock.fill" : "batteryblock.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(state.accentColor)

            Text("\(soc)%")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 4)
    }
}

struct StatusBarItemView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarItemView(soc: 85, state: .charging)
    }
}
