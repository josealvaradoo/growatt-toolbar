import SwiftUI

/// Compact flat error indicator shown in the popover hero when the most
/// recent poll failed. Renders directly on the parent popover's glass
/// surface (no card background). Replaces the hero's percentage / state /
/// battery bar with a single, composed affordance:
///
///   - Energy-specific icon (`bolt.slash.fill`)
///   - "Can't reach inverter" headline
///   - "Last reading Nm ago" subtitle (or "No previous reading" if the
///     first poll has not yet succeeded)
///   - Inline `RefreshButton`, the single recovery affordance
///
/// The banner reads as a designed state, not an alert, and gives the user
/// both the *what* (couldn't reach the inverter) and the *when* (last
/// reading Nm ago) so they can decide whether the data is still useful
/// or already a fossil.
public struct ErrorBannerView: View {
    @Bindable public var viewModel: InverterViewModel

    public init(viewModel: InverterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(alignment: .top, spacing: GlassTokens.Spacing.md) {
            Image(systemName: "bolt.slash.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.orange)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: GlassTokens.Spacing.xs) {
                Text("Can't reach inverter")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer(minLength: GlassTokens.Spacing.sm)

            RefreshButton(isLoading: viewModel.isLoading) {
                Task { await viewModel.refreshData() }
            }
        }
        .padding(GlassTokens.Padding.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Can't reach inverter. \(subtitle). Refresh button.")
    }

    private var subtitle: String {
        if let seconds = viewModel.secondsSinceLastUpdate {
            return "Last reading \(Self.relativeString(for: seconds))"
        }
        return "No previous reading"
    }

    // MARK: - Time helper

    private static func relativeString(for seconds: TimeInterval) -> String {
        if seconds < 5 { return "just now" }
        if seconds < 60 { return "\(Int(seconds))s ago" }
        if seconds < 3600 { return "\(Int(seconds / 60))m ago" }
        if seconds < 86400 { return "\(Int(seconds / 3600))h ago" }
        return "\(Int(seconds / 86400))d ago"
    }
}

struct ErrorBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: GlassTokens.Spacing.xl) {
            ErrorBannerView(viewModel: InverterViewModel(service: MockGrowattAPIService()))
                .frame(width: 280)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
