import Foundation

/// Extensible destination model for the settings sidebar. Currently only
/// Connection exists; new destinations (e.g. Notifications, About) would be
/// added as additional cases without touching the form views.
public enum SettingsSection: Hashable, Identifiable, CaseIterable, Sendable {
    case connection

    public var id: Self { self }

    public var title: String {
        switch self {
        case .connection: return "Connection"
        }
    }

    public var systemImage: String {
        switch self {
        case .connection: return "bolt.fill"
        }
    }
}
