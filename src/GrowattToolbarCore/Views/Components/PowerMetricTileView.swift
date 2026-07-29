import SwiftUI

/// Compact glass tile for individual energy metrics (Solar, Grid, Home Load).
/// Uses the real `.glassEffect(...)` API on macOS 26 with a `.ultraThinMaterial`
/// fallback on macOS 15, and respects `accessibilityReduceTransparency`.
public struct PowerMetricTileView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    public let iconName: String
    public let title: String
    public let valueKW: Double

    public init(iconName: String, title: String, valueKW: Double) {
        self.iconName = iconName
        self.title = title
        self.valueKW = valueKW
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(String(format: "%.1f", valueKW))
                    .font(.title2.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                Text("kW")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(GlassTokens.Padding.tile)
        .background { background }
    }

    @ViewBuilder
    private var background: some View {
        let shape = RoundedRectangle(cornerRadius: GlassTokens.Radius.tile, style: .continuous)
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
}

struct PowerMetricTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HStack(spacing: 10) {
                PowerMetricTileView(iconName: "sun.max.fill", title: "Solar Output", valueKW: 1.5)
                PowerMetricTileView(iconName: "transmission.tower", title: "Grid Import", valueKW: 3.5)
                PowerMetricTileView(iconName: "house.fill", title: "Home Load", valueKW: 1.8)
            }
            .padding()
        }
    }
}
