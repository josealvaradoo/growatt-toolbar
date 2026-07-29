import SwiftUI

/// Reusable Liquid Glass card container. Uses the real `.glassEffect(...)` API
/// on macOS 26 (Tahoe) and falls back to `.ultraThinMaterial` on macOS 15
/// (Sequoia). Honors `accessibilityReduceTransparency` per the platform
/// guidance — when the user opts out of translucency the card paints with a
/// solid `windowBackgroundColor` so the typography stays legible.
public struct LiquidGlassCard<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    private let content: Content
    private let cornerRadius: CGFloat

    public init(
        cornerRadius: CGFloat = GlassTokens.Radius.card,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(GlassTokens.Padding.card)
            .background { background }
    }

    @ViewBuilder
    private var background: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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

struct LiquidGlassCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            LiquidGlassCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Liquid Glass Preview")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Translucent material in macOS Tahoe style.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 300)
        }
    }
}
