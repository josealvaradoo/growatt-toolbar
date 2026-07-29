import SwiftUI
import AppKit
import GrowattToolbarCore

@main
struct GrowattToolbarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize Status Bar Controller & Menu Bar Popover
        let viewModel = InverterViewModel()
        statusBarController = StatusBarController(viewModel: viewModel)

        // Hide main app dock icon since it's a menu bar toolbar app
        NSApp.setActivationPolicy(.accessory)
    }
}
