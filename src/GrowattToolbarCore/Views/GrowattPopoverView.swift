import SwiftUI

/// Main popover view presenting Growatt inverter status inside a macOS Tahoe
/// Liquid Glass surface. The popover shell is a single `.glassEffect(.regular,
/// in:)` background on the root view — no `GlassEffectContainer` wraps the
/// content tree (a container captures its content into the glass rendering
/// pass, which blurs interior content). The header title and freshness pill
/// sit directly on the Regular glass and receive the system's adaptive
/// legibility treatment; the hero card, metric tile, and error banner sit on
/// opaque `controlBackgroundColor` fills so their type stays sharp. On macOS 15
/// the popover background falls back to `.ultraThinMaterial`. Honors
/// `accessibilityReduceTransparency` throughout.
///
/// **Honesty layer.** The popover renders one of four `Freshness` states at
/// all times: `.awaiting` (composed placeholder), `.live` (full hero),
/// `.stale` (full hero with inline "Updated Nm ago"), `.error` (designed
/// banner that replaces the hero). The connection pill in the header is the
/// single source of truth for trust. The footer "Last synced" line was
/// deleted; its job is now in the hero.
public struct GrowattPopoverView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable public var viewModel: InverterViewModel

    public init(viewModel: InverterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.lg) {
            header
            heroSection
            if showsMetricsRow {
                metricsRow
            }
            footer
        }
        .padding(GlassTokens.Padding.popover)
        .frame(width: 360)  // canonical width — see StatusBarController.popover.contentSize
        .background { popoverBackground }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Growatt Inverter")
                .font(.title3.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.primary)

            Spacer()

            // TimelineView re-evaluates freshness once per second so the pill
            // transitions from "Live" to "Stale" without polling the view model.
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                FreshnessIndicatorView(freshness: viewModel.freshness)
            }
        }
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
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.lg) {
            HStack(alignment: .firstTextBaseline, spacing: GlassTokens.Spacing.xxs) {
                Text("···")
                    .font(GlassTokens.Numeric.hero)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                Text("%")
                    .font(.title.bold())
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: GlassTokens.Spacing.md) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.caption.bold())
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                Text("Awaiting first reading…")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
            }

            BatteryIndicatorPlaceholder()
                .frame(height: 38)
        }
        .padding(GlassTokens.Padding.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { heroBackground }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Awaiting first reading from inverter")
    }

    private var dataHero: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.lg) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: GlassTokens.Spacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: GlassTokens.Spacing.xxs) {
                        Text("\(viewModel.status.batterySoC)")
                            .font(GlassTokens.Numeric.hero)
                            .foregroundStyle(.primary)
                            .monospacedDigit()
                        Text("%")
                            .font(.title.bold())
                            .foregroundStyle(.secondary)
                    }

                    if let subtitle = staleSubtitle {
                        Text(subtitle)
                            .font(.footnote)
                            .fontDesign(.rounded)
                            .foregroundStyle(.orange)
                            .monospacedDigit()
                            .transition(staleSubtitleTransition)
                    }
                }

                Spacer(minLength: GlassTokens.Spacing.sm)

                PowerFlowBadgeView(
                    state: viewModel.status.state
                )
            }

            BatteryIndicatorView(
                levelPercentage: viewModel.status.batterySoC,
                state: viewModel.status.state
            )
        }
        .padding(GlassTokens.Padding.card)
        .background { heroBackground }
        .animation(staleSubtitleAnimation, value: staleSubtitle)
        // Combine so VoiceOver reads the percentage, stale subtitle, and
        // badge as a single utterance instead of descending into the
        // individual Texts. The custom label includes the stale subtitle
        // when present so Sam hears the freshness signal in the same
        // utterance as the reading.
        .accessibilityElement(children: .combine)
        .accessibilityLabel(dataHeroAccessibilityLabel)
    }

    /// One-sentence VoiceOver label for the data hero. Composed of the
    /// battery percentage, the battery state, and the optional stale
    /// subtitle. Excludes the battery bar (decorative, hidden) and the
    /// popover freshness pill (the pill's own label carries that info).
    private var dataHeroAccessibilityLabel: String {
        let base = "Battery at \(viewModel.status.batterySoC) percent, \(viewModel.status.state.title.lowercased())"
        if let subtitle = staleSubtitle {
            return base + ", " + subtitle
        }
        return base
    }

    private var errorHero: some View {
        ErrorBannerView(viewModel: viewModel)
    }

    // MARK: - Metrics

    /// Hide the metrics row in states that have no data to show. `.stale`
    /// still has the last known value, so it stays.
    private var showsMetricsRow: Bool {
        switch viewModel.freshness {
        case .awaiting:           return false
        case .error where !viewModel.hasReceivedFirstReading: return false
        default:                  return true
        }
    }

    private var metricsRow: some View {
        PowerMetricTileView(
            iconName: "house.fill",
            title: "Home Load",
            valueKW: viewModel.status.outputPowerKW
        )
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        // In the `.error` state the recovery affordance lives inside
        // `ErrorBannerView`. Hiding the footer refresh there avoids a
        // redundant second button and keeps the hero's banner the single
        // visual focus.
        if viewModel.freshness == .error {
            EmptyView()
        } else {
            // The HStack sits inside the popover's VStack; the parent
            // doesn't expand horizontally, so the button naturally
            // hugs the leading edge. A trailing `Spacer()` is decorative.
            refreshButton
        }
    }

    // MARK: - Refresh button

    private var refreshButton: some View {
        RefreshButton(isLoading: viewModel.isLoading) {
            Task { await viewModel.refreshData() }
        }
    }

    // MARK: - Backgrounds

    @ViewBuilder
    private var popoverBackground: some View {
        let shape = RoundedRectangle(cornerRadius: PopoverGeometry.cornerRadius, style: .continuous)
        if reduceTransparency {
            shape.fill(Color(nsColor: .windowBackgroundColor))
        } else if #available(macOS 26, *) {
            // Regular, not Clear: Clear is only for media-rich backdrops with a
            // dimming layer and bold/bright overlay content (WWDC25-219) and never
            // applies the adaptive legibility treatment — the header title sits
            // directly on this shell. Regular keeps every label sharp and vibrant.
            shape
                .fill(Color.clear)
                .glassEffect(.regular, in: shape)
        } else {
            shape.fill(.ultraThinMaterial)
        }
    }

    private var heroBackground: some View {
        // Opaque card on a glass popover shell. The popover shell is the only
        // translucency layer; the inner cards are opaque so the type stays
        // sharp (macOS 26 Tahoe popover pattern: glass shell, opaque content).
        RoundedRectangle(cornerRadius: GlassTokens.Radius.card, style: .continuous)
            .fill(Color(nsColor: .controlBackgroundColor))
    }

    // MARK: - Time-aware copy

    /// Inline subtitle under the percentage in the `.stale` state. `nil`
    /// in `.live` (the pill carries the trust signal, no caption needed).
    private var staleSubtitle: String? {
        guard viewModel.freshness == .stale,
              let seconds = viewModel.secondsSinceLastUpdate else { return nil }
        return "Updated \(ErrorBannerView.relativeString(for: seconds))"
    }

    /// Transition for the inline "Updated Nm ago" caption. `nil` under
    /// `accessibilityReduceMotion` so the text appears instantly.
    private var staleSubtitleTransition: AnyTransition {
        if reduceMotion {
            return .identity
        }
        return .opacity.combined(with: .move(edge: .top))
    }

    private var staleSubtitleAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.25)
    }
}

/// Geometric constants for the popover window. Kept local to this
/// file because the popover is the only surface that uses them.
///
/// On macOS 26+, the principled choice would be SwiftUI's
/// `.containerConcentric` static (applied via
/// `RoundedRectangle(...).corners(.containerConcentric())`) — it
/// resolves at runtime to the system window's corner radius, so the
/// popover's content edge is concentric with the window's bezel. That
/// API is macOS 26+ only and requires platform branching; the fixed
/// value below is a reasonable approximation that works on both
/// macOS 15 and macOS 26+.
private enum PopoverGeometry {
    static let cornerRadius: CGFloat = 24
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
