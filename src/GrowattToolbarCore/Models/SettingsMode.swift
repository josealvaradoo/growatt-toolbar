import Foundation

/// Which presentation of the settings window is active.
///
/// - `onboarding`: first-launch flow shown before credentials exist. Includes
///   welcome copy, value proposition, and a prominent setup CTA.
/// - `settings`: returning-user flow shown from the status bar menu. Focuses
///   on the connection form with current values prefilled.
public enum SettingsMode: Equatable, Sendable {
    case onboarding
    case settings
}
