import SwiftUI

/// Main popover view presenting Growatt inverter status inside macOS Tahoe Liquid Glass container.
public struct GrowattPopoverView: View {
    @Bindable public var viewModel: InverterViewModel

    public init(viewModel: InverterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Header Bar
            HStack {
                Text("Growatt Inverter")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)

                Spacer()

                // Connected Indicator Dot
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.errorMessage == nil ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                        .shadow(color: (viewModel.errorMessage == nil ? Color.green : Color.red).opacity(0.8), radius: 4)

                    Text(viewModel.errorMessage == nil ? "Connected" : "Offline")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    viewModel.toggleMockState()
                }
            }

            // Main Hero Battery Card
            LiquidGlassCard(cornerRadius: 18) {
                VStack(spacing: 16) {
                    HStack(alignment: .top) {
                        // Large Battery Percentage Display
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(viewModel.status.batterySoC)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            Text("%")
                                .font(.title.bold())
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // Power Flow Status Badge
                        PowerFlowBadgeView(
                            state: viewModel.status.state,
                            powerDescription: viewModel.status.formattedPowerDescription
                        )
                    }

                    // Visual Battery Gauge Bar
                    BatteryIndicatorView(
                        levelPercentage: viewModel.status.batterySoC,
                        state: viewModel.status.state
                    )
                }
            }


            // Secondary Power Metrics Row
            HStack(spacing: 10) {
                PowerMetricTileView(
                    iconName: "house.fill",
                    title: "Home Load",
                    valueKW: viewModel.status.homeLoadKW
                )
            }


            // Footer Bar
            HStack {
                // Refresh Button
                Button {
                    Task {
                        await viewModel.refreshData()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.body.bold())
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(
                            viewModel.isLoading
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                            value: viewModel.isLoading
                        )
                }
                .buttonStyle(.plain)
                .padding(8)
                .background(Circle().fill(.ultraThinMaterial))

                Spacer()

                // Last Synced Timestamp
                Text("Last synced: \(timeAgoString(from: viewModel.status.lastUpdated))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(18)
        .frame(width: 360)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
    }

    private func timeAgoString(from date: Date) -> String {
        let elapsed = Int(Date().timeIntervalSince(date))
        if elapsed < 5 {
            return "Just now"
        } else if elapsed < 60 {
            return "\(elapsed) seconds ago"
        } else {
            let minutes = elapsed / 60
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
        }
    }
}

struct GrowattPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GrowattPopoverView(viewModel: InverterViewModel())
        }
    }
}
