import Foundation

/// Lifecycle of the connection test surfaced by the settings flow.
///
/// - `idle`: no test has run, or the draft has changed since the last test
///   (the prior test is invalidated).
/// - `testing`: a test is in flight; Test Connection and Save/Update are
///   disabled until it finishes.
/// - `success`: the last test succeeded against the exact current draft
///   values; Save/Update becomes available.
/// - `failure(message)`: the last test failed; `message` is the safe,
///   user-facing explanation (never a technical detail or credential).
public enum ConnectionTestStatus: Equatable, Sendable {
    case idle
    case testing
    case success
    case failure(String)
}
