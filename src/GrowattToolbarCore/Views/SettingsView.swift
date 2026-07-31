import SwiftUI

public struct SettingsView: View {
    @State private var apiKey: String
    @State private var apiURL: String
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let onSave: (String, String) async throws -> Void

    public init(
        initialApiKey: String? = nil,
        initialApiURL: String? = nil,
        onSave: @escaping (String, String) async throws -> Void
    ) {
        self._apiKey = State(initialValue: initialApiKey ?? "")
        self._apiURL = State(initialValue: initialApiURL ?? "")
        self.onSave = onSave
    }

    private var isFormValid: Bool {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = apiURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedKey.isEmpty && URL(string: trimmedURL) != nil
    }

    public var body: some View {
        VStack(spacing: GlassTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: GlassTokens.Spacing.sm) {
                Text("API Key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                SecureField("Enter your API key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .accessibilityLabel("API Key")
                    .accessibilityHint("Enter your Growatt API key for authentication")
            }

            VStack(alignment: .leading, spacing: GlassTokens.Spacing.sm) {
                Text("API URL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("https://...", text: $apiURL)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .accessibilityLabel("API URL")
                    .accessibilityHint("Enter the base URL of the Growatt API endpoint")
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel(errorMessage)
            }

            Button(action: save) {
                if isSaving {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Save")
                }
            }
            .disabled(!isFormValid || isSaving)
            .accessibilityLabel("Save settings")
            .accessibilityHint("Saves your API key and URL to connect to the Growatt inverter")
        }
        .padding(GlassTokens.Padding.popover)
        .frame(idealWidth: 400, idealHeight: 300)
        .fixedSize()
        .background { settingsBackground }
    }

    @ViewBuilder
    private var settingsBackground: some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        if reduceTransparency {
            shape.fill(Color(nsColor: .windowBackgroundColor))
        } else if #available(macOS 26, *) {
            shape
                .fill(Color.clear)
                .glassEffect(.regular, in: shape)
        } else {
            shape.fill(.ultraThinMaterial)
        }
    }

    private func save() {
        guard isFormValid else { return }
        isSaving = true
        errorMessage = nil
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = apiURL.trimmingCharacters(in: .whitespacesAndNewlines)
        Task { @MainActor in
            defer { isSaving = false }
            do {
                try await onSave(key, url)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
