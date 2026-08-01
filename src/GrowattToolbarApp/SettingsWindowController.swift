import AppKit
import SwiftUI
import GrowattToolbarCore

/// Presents the settings window for a given mode with a fixed native size
/// and normal titlebar, and owns the close/Escape rules:
///
/// - Onboarding: closing or pressing Escape explains that setup is required
///   and keeps the setup flow active (the window stays open).
/// - Settings: closing with unsaved edits requests confirmation before
///   discarding them.
@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let viewModel: SettingsViewModel
    private let mode: SettingsMode

    init(
        mode: SettingsMode,
        initialApiKey: String?,
        initialApiURL: String?,
        tester: GrowattConnectionTesterProtocol,
        persist: @escaping @MainActor (String, String) throws -> Void,
        onSaveCompleted: @escaping @MainActor (String, String) -> Void
    ) {
        self.mode = mode
        self.viewModel = SettingsViewModel(
            apiKey: initialApiKey ?? "",
            apiURL: initialApiURL ?? "",
            tester: tester,
            persist: persist
        )
        super.init()
        viewModel.onSaveCompleted = onSaveCompleted
        setupWindow()
    }

    private func setupWindow() {
        let settingsView = SettingsView(viewModel: viewModel, mode: mode)
        let hostingController = NSHostingController(rootView: settingsView)

        let window = SettingsWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 460),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = mode == .onboarding ? "Connect Your Inverter" : "Growatt Settings"
        window.isOpaque = true
        window.backgroundColor = .windowBackgroundColor
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.onCancel = { [weak self] in
            self?.handleCancel()
        }
        window.contentViewController = hostingController
        window.center()
        self.window = window
    }

    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow() {
        window?.close()
    }

    /// Closes the window immediately if there are no unsaved edits; otherwise
    /// asks for confirmation first. Returns `true` only when the window was
    /// actually closed. Used by `reopenSettings` so the status-bar menu path
    /// honors the same discard-confirmation rule as the close button.
    func requestClose() -> Bool {
        if viewModel.hasUnsavedEdits {
            return confirmDiscard()
        }
        window?.close()
        return true
    }

    // MARK: - Close / Escape handling

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        switch mode {
        case .onboarding:
            presentOnboardingAlert()
            return false
        case .settings:
            if viewModel.hasUnsavedEdits {
                return confirmDiscard()
            }
            return true
        }
    }

    private func handleCancel() {
        switch mode {
        case .onboarding:
            presentOnboardingAlert()
        case .settings:
            if viewModel.hasUnsavedEdits {
                _ = confirmDiscard()
            } else {
                window?.close()
            }
        }
    }

    private func presentOnboardingAlert() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Setup Required"
        alert.informativeText = "Growatt Toolbar needs a connection to your inverter before it can show its status in the menu bar. Continue setting up, or quit the app."
        alert.addButton(withTitle: "Continue Setup")
        alert.addButton(withTitle: "Quit Growatt Toolbar")
        if alert.runModal() == .alertSecondButtonReturn {
            NSApp.terminate(nil)
        }
    }

    /// Presents the discard confirmation. Returns `true` when the user chose
    /// to discard and the window has been closed.
    private func confirmDiscard() -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Discard Changes?"
        alert.informativeText = "Your connection details have unsaved changes. If you close now, those changes will be lost."
        alert.addButton(withTitle: "Discard Changes")
        alert.addButton(withTitle: "Cancel")
        let shouldDiscard = alert.runModal() == .alertFirstButtonReturn
        if shouldDiscard {
            window?.close()
        }
        return shouldDiscard
    }
}

/// NSWindow subclass that routes the Escape key (cancelOperation) to the
/// controller so both the close button and Esc follow the mode-aware rules.
@MainActor
private final class SettingsWindow: NSWindow {
    var onCancel: (() -> Void)?

    override func cancelOperation(_ sender: Any?) {
        onCancel?()
    }
}
