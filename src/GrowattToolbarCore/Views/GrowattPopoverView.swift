import SwiftUI

/// Main popover view presenting Growatt inverter status inside a macOS Tahoe
/// Liquid Glass surface. Per Apple's HIG, glass is reserved for the
/// navigation layer (this popover background) and the small interactive
/// controls (the power-flow badge and the refresh button). The content sits
/// on `.regularMaterial` cards so the text stays legible — no glass-on-glass
/// stacking. On macOS 15 the same composition falls back to
/// `.ultraThinMaterial`. Honors `accessibilityReduceTransparency` throughout.
public struct GrowattPopoverView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Bindable public var viewModel: InverterViewModel

    public init(viewModel: InverterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 16) {
            header
            heroContent
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
                .glassEffect(.clear, in: shape)
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

    private var heroContent: some View {
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
        .padding(GlassTokens.Padding.card)
        .background { heroBackground }
    }

    @ViewBuilder
    private var heroBackground: some View {
        let shape = RoundedRectangle(cornerRadius: GlassTokens.Radius.card, style: .continuous)
        if reduceTransparency {
            shape.fill(Color(nsColor: .windowBackgroundColor))
        } else {
            shape.fill(.regularMaterial)
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
                .glassEffect(.clear.interactive(), in: shape)
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
