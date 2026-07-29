import SwiftUI

/// Main popover view presenting Growatt inverter status inside a macOS Tahoe
/// Liquid Glass surface. On macOS 26 the popover, hero card, badge and refresh
/// button read as a single cohesive material via `GlassEffectContainer`; on
/// macOS 15 the same composition falls back to `.ultraThinMaterial`. Honors
/// `accessibilityReduceTransparency` throughout.
public struct GrowattPopoverView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Bindable public var viewModel: InverterViewModel

    public init(viewModel: InverterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: 20) {
                popoverStack
            }
        } else {
            popoverStack
        }
    }

    @ViewBuilder
    private var popoverStack: some View {
        VStack(spacing: 16) {
            header
            heroCard
            metricsRow
            footer
        }
        .padding(GlassTokens.Padding.popover)
        .frame(width: 360)
        .background { popoverBackground }
    }

    @ViewBuilder
    private var popoverBackground: some View {
        let shape = RoundedRectangle(cornerRadius: GlassTokens.Radius.popover, style: .continuous)
        if reduceTransparency {
            shape.fill(Color(nsColor: .windowBackgroundColor))
        } else if #available(macOS 26, *) {
            shape
                .fill(Color.clear)
                .glassEffect(in: shape)
        } else {
            shape.fill(.ultraThinMaterial)
        }
    }

    private var header: some View {
        HStack {
            Text("Growatt Inverter")
                .font(.title3.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.primary)

            Spacer()

            connectionIndicator
        }
    }

    private var connectionIndicator: some View {
        let isOnline = viewModel.errorMessage == nil
        let color: Color = isOnline ? .green : .red

        return HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.8), radius: 4)

            Text(isOnline ? "Connected" : "Offline")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var heroCard: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(viewModel.status.batterySoC)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("%")
                            .font(.title.bold())
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    PowerFlowBadgeView(
                        state: viewModel.status.state,
                        powerDescription: viewModel.status.formattedPowerDescription
                    )
                }

                BatteryIndicatorView(
                    levelPercentage: viewModel.status.batterySoC,
                    state: viewModel.status.state
                )
            }
        }
    }

    private var metricsRow: some View {
        PowerMetricTileView(
            iconName: "house.fill",
            title: "Home Load",
            valueKW: viewModel.status.outputPowerKW
        )
    }

    private var footer: some View {
        HStack {
            refreshButton

            Spacer()

            Text("Last synced: \(timeAgoString(from: viewModel.status.lastUpdated))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder
    private var refreshButton: some View {
        Button {
            Task { await viewModel.refreshData() }
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.body.bold())
                .frame(width: GlassTokens.ControlSize.button, height: GlassTokens.ControlSize.button)
                .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                .animation(
                    viewModel.isLoading
                    ? .linear(duration: 1).repeatForever(autoreverses: false)
                    : .default,
                    value: viewModel.isLoading
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Refresh")
        .background { refreshBackground }
    }

    @ViewBuilder
    private var refreshBackground: some View {
        let shape = Circle()
        if reduceTransparency {
            shape.fill(Color(nsColor: .windowBackgroundColor))
        } else if #available(macOS 26, *) {
            shape
                .fill(Color.clear)
                .glassEffect(.regular.interactive(), in: shape)
        } else {
            shape.fill(.ultraThinMaterial)
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
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GrowattPopoverView(viewModel: InverterViewModel())
        }
    }
}
