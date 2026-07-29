import SwiftUI

/// Compact glass tile component for displaying individual energy metrics (Solar, Grid, Home Load).
public struct PowerMetricTileView: View {
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
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
        }
    }
}

struct PowerMetricTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            HStack(spacing: 10) {
                PowerMetricTileView(iconName: "sun.max.fill", title: "Solar Output", valueKW: 1.5)
                PowerMetricTileView(iconName: "transmission.tower", title: "Grid Import", valueKW: 3.5)
                PowerMetricTileView(iconName: "house.fill", title: "Home Load", valueKW: 1.8)
            }
            .padding()
        }
    }
}
