import SwiftUI

/// Sidebar navigation for the settings window. A single Connection
/// destination today; the list is driven by `SettingsSection` so future
/// sections slot in without structural changes.
public struct SettingsSidebarView: View {
    public let mode: SettingsMode
    @Binding public var selection: SettingsSection

    public init(mode: SettingsMode, selection: Binding<SettingsSection>) {
        self.mode = mode
        self._selection = selection
    }

    public var body: some View {
        List(selection: $selection) {
            Section {
                Label(
                    SettingsSection.connection.title,
                    systemImage: SettingsSection.connection.systemImage
                )
                .tag(SettingsSection.connection)
            } header: {
                Text(sidebarHeader)
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 190, ideal: 200, max: 220)
        .accessibilityLabel("Settings sections")
    }

    private var sidebarHeader: String {
        switch mode {
        case .onboarding: return "Growatt Inverter"
        case .settings: return "Growatt Toolbar"
        }
    }
}
