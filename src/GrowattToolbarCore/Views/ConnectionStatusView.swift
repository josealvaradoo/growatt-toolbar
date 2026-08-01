import SwiftUI

/// Inline feedback for the connection-test lifecycle: idle guidance,
/// in-flight progress, success, and safe failure messages. Reads only
/// `ConnectionTestStatus`, so it never sees credentials or technical errors.
public struct ConnectionStatusView: View {
    public let status: ConnectionTestStatus

    public init(status: ConnectionTestStatus) {
        self.status = status
    }

    public var body: some View {
        switch status {
        case .idle:
            feedback(
                systemImage: "info.circle",
                message: "Enter your API details, then test the connection.",
                tint: .secondary
            )
        case .testing:
            HStack(spacing: GlassTokens.Spacing.sm) {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityHidden(true)
                Text("Testing connection…")
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Testing connection")
        case .success:
            feedback(
                systemImage: "checkmark.circle.fill",
                message: "Connected. Your API URL and key are valid.",
                tint: .green
            )
        case .failure(let message):
            feedback(
                systemImage: "exclamationmark.triangle.fill",
                message: message,
                tint: .red
            )
        }
    }

    private func feedback(systemImage: String, message: String, tint: Color) -> some View {
        Label(message, systemImage: systemImage)
            .font(.callout)
            .foregroundStyle(tint)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message)
    }
}
