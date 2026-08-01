import SwiftUI

/// The connection form: API key (masked), API URL, local validation
/// feedback, connection-test status, and Test/Save actions. Rendering is
/// driven entirely by `SettingsViewModel` state; no business logic lives here.
public struct ConnectionFormView: View {
    @Bindable public var viewModel: SettingsViewModel
    public let mode: SettingsMode

    public init(viewModel: SettingsViewModel, mode: SettingsMode) {
        self.viewModel = viewModel
        self.mode = mode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.md) {
            keyField
            urlField
            if let message = viewModel.urlValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel(message)
            }
            ConnectionStatusView(status: viewModel.testStatus)
            if let saveError = viewModel.saveError {
                Text(saveError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel(saveError)
            }
            actionRow
        }
    }

    // MARK: - Fields

    private var keyField: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.xs) {
            Text("API Key")
                .font(.caption)
                .foregroundStyle(.secondary)
            SecureField("Paste your API key", text: $viewModel.apiKey)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .accessibilityLabel("API Key")
                .accessibilityHint("The API key for your inverter's local API. Stored only in your Mac's Keychain and never shared.")
        }
    }

    private var urlField: some View {
        VStack(alignment: .leading, spacing: GlassTokens.Spacing.xs) {
            Text("API URL")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("https://…", text: $viewModel.apiURL)
                .textFieldStyle(.roundedBorder)
                .textContentType(.URL)
                .accessibilityLabel("API URL")
                .accessibilityHint("The base URL of your inverter's status endpoint, including http or https.")
        }
    }

    // MARK: - Actions

    private var actionRow: some View {
        HStack {
            Button {
                Task { await viewModel.testConnection() }
            } label: {
                if viewModel.isTesting {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Test Connection", systemImage: "checkmark.circle")
                }
            }
            .disabled(!viewModel.canTest)
            .accessibilityLabel("Test Connection")
            .accessibilityHint("Verifies your API URL and key against the inverter before saving.")

            Spacer()

            Button {
                viewModel.save()
            } label: {
                Text(saveTitle)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.canSave)
            .keyboardShortcut(.defaultAction)
            .accessibilityLabel(saveTitle)
            .accessibilityHint("Saves your connection details and starts monitoring.")
        }
    }

    private var saveTitle: String {
        switch mode {
        case .onboarding: return "Save & Start Monitoring"
        case .settings: return "Save Changes"
        }
    }
}
