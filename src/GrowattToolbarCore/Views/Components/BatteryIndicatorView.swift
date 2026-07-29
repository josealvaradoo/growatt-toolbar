import SwiftUI

/// Animated visual battery gauge displaying state of charge percentage with
/// state-based gradient fills.
public struct BatteryIndicatorView: View {
    public let levelPercentage: Int
    public let state: InverterState

    public init(levelPercentage: Int, state: InverterState) {
        self.levelPercentage = min(max(levelPercentage, 0), 100)
        self.state = state
    }

    private var gradientColors: [Color] {
        switch state {
        case .charging:
            return [Color(red: 0.15, green: 0.85, blue: 0.45), Color(red: 0.25, green: 0.95, blue: 0.55)]
        case .discharging:
            return [Color.orange, Color(red: 1.0, green: 0.65, blue: 0.2)]
        }
    }

    public var body: some View {
        HStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        }

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(3)
                        .frame(width: max(0, (geometry.size.width - 6) * CGFloat(levelPercentage) / 100.0))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: levelPercentage)
                        .animation(.easeInOut(duration: 0.3), value: state)
                }
            }
            .frame(height: 38)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.white.opacity(0.3))
                .frame(width: 5, height: 16)
        }
        .accessibilityLabel("Battery Level \(levelPercentage) percent, \(state.title)")
    }
}

struct BatteryIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                BatteryIndicatorView(levelPercentage: 85, state: .charging)
                BatteryIndicatorView(levelPercentage: 42, state: .discharging)
            }
            .padding()
            .frame(width: 300)
        }
    }
}
