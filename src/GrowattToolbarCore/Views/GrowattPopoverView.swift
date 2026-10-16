import SwiftUI

/// 280pt flat two-column Control Center tile rendered directly inside NSPopover's
/// native liquid glass shell. Flat content (no inner cards or nested glass backgrounds).
/// Two-column hero: battery % left, home load kW right. Thin neutral battery bar.
/// State/freshness row with accent state signal and inline trust indicator.
///
/// **Honesty layer.** The popover renders one of four `Freshness` states at
/// all times: `.awaiting` (placeholder columns + "Connecting…"), `.live` /
/// `.stale` (two-column hero + bar + state row with inline freshness), `.error`
/// (compact banner replacing the hero; battery bar, divider, and state row
/// are suppressed). Hero transitions use a 250ms ease-in-out crossfade
/// for a calm state change. The state row's `FreshnessIndicatorView`
/// is the single source of truth for trust.
public struct GrowattPopoverView: View {
    @Bindable public var viewModel: InverterViewModel

    public init(viewModel: InverterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.md) {
            heroSection
            if viewModel.freshness != .error {
                batteryBarSection
            }
            if viewModel.freshness != .awaiting && viewModel.freshness != .error {
                Divider()
                stateRow
            }
        }
        .padding(GlassTokens.Padding.popover)
        .frame(width: 280)
        .animation(.easeInOut(duration: 0.25), value: viewModel.freshness)
    }

    private var formattedHomeLoad: String {
        let kw = viewModel.status.outputPowerKW
        if kw < 1.0 {
            return "\(Int(kw * 1000)) W"
        }
        return String(format: "%.1f kW", kw)
    }

    // MARK: - Hero

    @ViewBuilder
    private var heroSection: some View {
        switch viewModel.freshness {
        case .awaiting:
            awaitingHero
        case .live, .stale:
            dataHero
        case .error:
            errorHero
        }
    }

    private var awaitingHero: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: GlassTokens.Spacing.xxs) {
                    Text("Battery")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(verbatim: "···")
                        .font(GlassTokens.Numeric.hero)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer(minLength: GlassTokens.Spacing.sm)

                VStack(alignment: .trailing, spacing: GlassTokens.Spacing.xxs) {
                    Text("Home Load")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(verbatim: "···")
                        .font(GlassTokens.Numeric.hero)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            Text("Connecting…")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var dataHero: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: GlassTokens.Spacing.xxs) {
                Text("Battery")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: GlassTokens.Spacing.xxs) {
                    Text("\(viewModel.status.batterySoC)")
                        .font(GlassTokens.Numeric.hero)
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                    Text("%")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: GlassTokens.Spacing.sm)

            VStack(alignment: .trailing, spacing: GlassTokens.Spacing.xxs) {
                Text("Home Load")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formattedHomeLoad)
                    .font(GlassTokens.Numeric.hero)
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Battery \(viewModel.status.batterySoC) percent, \(viewModel.status.state.title). Home Load \(formattedHomeLoad).")
    }

    private var errorHero: some View {
        ErrorBannerView(viewModel: viewModel)
    }

    // MARK: - Battery bar

    @ViewBuilder
    private var batteryBarSection: some View {
        switch viewModel.freshness {
        case .awaiting:
            BatteryIndicatorPlaceholder()
        case .error:
            EmptyView()
        default:
            BatteryIndicatorView(
                levelPercentage: viewModel.status.batterySoC,
                state: viewModel.status.state
            )
        }
    }

    // MARK: - State row

    @ViewBuilder
    private var stateRow: some View {
        if viewModel.freshness != .awaiting && viewModel.freshness != .error {
            HStack {
                PowerFlowBadgeView(state: viewModel.status.state)

                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    FreshnessIndicatorView(freshness: viewModel.freshness)
                }

                Spacer()

                RefreshButton(isLoading: viewModel.isLoading) {
                    Task { await viewModel.refreshData(bypassCache: true) }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.status.state.title). \(viewModel.freshness.accessibilityLabel()). Refresh button.")
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

            GrowattPopoverView(viewModel: InverterViewModel(service: MockGrowattAPIService()))
        }
    }
}
