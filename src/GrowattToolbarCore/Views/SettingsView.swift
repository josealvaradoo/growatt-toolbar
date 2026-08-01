import SwiftUI

/// Mode-aware settings shell: a native macOS `NavigationSplitView` with a
/// Connection sidebar and a solid adaptive system background. Onboarding mode
/// layers `OnboardingContentView` above the connection form; settings mode
/// shows the form directly with current values prefilled.
public struct SettingsView: View {
    @Bindable public var viewModel: SettingsViewModel
    public let mode: SettingsMode

    @State private var selection: SettingsSection = .connection

    public init(viewModel: SettingsViewModel, mode: SettingsMode) {
        self.viewModel = viewModel
        self.mode = mode
    }

    public var body: some View {
        NavigationSplitView {
            SettingsSidebarView(mode: mode, selection: $selection)
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 560, idealWidth: 620, minHeight: 380, idealHeight: 460)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var detailContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GlassTokens.Spacing.xl) {
                switch mode {
                case .onboarding:
                    OnboardingContentView()
                    Divider()
                case .settings:
                    EmptyView()
                }
                ConnectionFormView(viewModel: viewModel, mode: mode)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(GlassTokens.Spacing.xl)
        }
        .accessibilityLabel("Connection settings")
    }
}
