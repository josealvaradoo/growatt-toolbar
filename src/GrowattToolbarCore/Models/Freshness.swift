import Foundation

/// Trust state surfaced in the popover's freshness pill and hero banner.
///
/// The popover renders one of four states at all times:
///
/// - `awaiting`: the very first poll has not yet completed. The hero shows a
///   composed placeholder; the connection dot is neutral, not green.
/// - `live`: the most recent poll succeeded and the data is within the
///   freshness window (1.5× the polling interval).
/// - `stale`: the most recent poll succeeded but the data is older than the
///   freshness window. The hero still shows the last value, with an inline
///   "Updated Nm ago" caption underneath.
/// - `error`: the most recent poll failed. The hero is replaced by a designed
///   error banner; the connection dot is red.
///
/// `Freshness` is the *category* of trust, not the time-since-last-update
/// itself — that is a derived value the view recomputes each second.
public enum Freshness: Equatable, Sendable {
    case awaiting
    case live
    case stale
    case error
}

extension Freshness {
    /// Short, sentence-case title for the header pill.
    public var displayTitle: String {
        switch self {
        case .awaiting: return "Connecting"
        case .live:     return "Live"
        case .stale:    return "Stale"
        case .error:    return "Offline"
        }
    }

    /// SF Symbol name for the leading dot glyph. The freshness pill renders
    /// the dot as a tinted `Circle()` and the SF Symbol is reserved for the
    /// error banner and accessibility labels.
    public var leadingSymbol: String {
        switch self {
        case .awaiting: return "antenna.radiowaves.left.and.right"
        case .live:     return "dot.radiowaves.left.and.right"
        case .stale:    return "clock.arrow.circlepath"
        case .error:    return "wifi.exclamationmark"
        }
    }

    /// Compact VoiceOver label for the freshness category.
    public func accessibilityLabel() -> String {
        switch self {
        case .awaiting: return "Connecting to inverter"
        case .live:     return "Live data"
        case .stale:    return "Stale data"
        case .error:    return "Offline"
        }
    }
}
