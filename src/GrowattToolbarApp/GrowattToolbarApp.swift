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
        DotEnv.loadDotenv()

        let processInfo = ProcessInfo.processInfo
        let apiToken = processInfo.environment["API_KEY"] ?? ""
        let baseURL  = processInfo.environment["API_URL"] ?? ""

        let service = GrowattOpenAPIService(
            baseURLString: baseURL,
            apiToken: apiToken
        )
        let viewModel = InverterViewModel(service: service)
        statusBarController = StatusBarController(viewModel: viewModel)

        // Hide main app dock icon since it's a menu bar toolbar app
        NSApp.setActivationPolicy(.accessory)
    }
}
