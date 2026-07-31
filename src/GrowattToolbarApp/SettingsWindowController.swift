import AppKit
import SwiftUI
import GrowattToolbarCore

@MainActor
final class SettingsWindowController: NSObject, @unchecked Sendable {
    private var window: NSWindow?
    private let onSave: (String, String) async throws -> Void

    init(onSave: @escaping (String, String) async throws -> Void) {
        self.onSave = onSave
        super.init()
        setupWindow()
    }

    private func setupWindow() {
        let settingsView = SettingsView { [weak self] apiKey, apiURL in
            try await self?.onSave(apiKey, apiURL)
            self?.closeWindow()
        }

        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Growatt Settings"
        window.isOpaque = false
        window.backgroundColor = .clear
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
}
