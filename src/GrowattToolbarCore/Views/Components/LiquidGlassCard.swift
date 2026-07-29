import SwiftUI

/// Reusable Liquid Glass card container view providing modern macOS Tahoe glass translucency.
public struct LiquidGlassCard<Content: View>: View {
    private let content: Content
    private let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
            }
    }
}

struct LiquidGlassCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LiquidGlassCard {
                VStack(alignment: .leading) {
                    Text("Liquid Glass Preview")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Translucent materials in macOS Tahoe style.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 300)
        }
    }
}
