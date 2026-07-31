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
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        DotEnv.loadDotenv()

        let processInfo = ProcessInfo.processInfo
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: "hasCompletedOnboarding") {
            let apiKey = defaults.string(forKey: "apiKey") ?? processInfo.environment["API_KEY"] ?? ""
            let apiURL = defaults.string(forKey: "apiURL") ?? processInfo.environment["API_URL"] ?? ""
            finishSetup(apiKey: apiKey, apiURL: apiURL)
            NSApp.setActivationPolicy(.accessory)
        } else {
            let onboarding = SettingsWindowController { [weak self] apiKey, apiURL in
                defaults.set(true, forKey: "hasCompletedOnboarding")
                defaults.set(apiKey, forKey: "apiKey")
                defaults.set(apiURL, forKey: "apiURL")
                self?.finishSetup(apiKey: apiKey, apiURL: apiURL)
                NSApp.setActivationPolicy(.accessory)
            }
            self.settingsWindowController = onboarding
            onboarding.showWindow()
        }
    }

    private func finishSetup(apiKey: String, apiURL: String) {
        statusBarController?.viewModel.stopAutoRefresh()

        let service = GrowattOpenAPIService(
            baseURLString: apiURL,
            apiToken: apiKey
        )
        let viewModel = InverterViewModel(service: service)
        let controller = StatusBarController(viewModel: viewModel)
        controller.onSettingsRequested = { [weak self] in
            self?.reopenSettings()
        }
        self.statusBarController = controller
    }

    private func reopenSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController { [weak self] apiKey, apiURL in
                let defaults = UserDefaults.standard
                defaults.set(apiKey, forKey: "apiKey")
                defaults.set(apiURL, forKey: "apiURL")
                self?.finishSetup(apiKey: apiKey, apiURL: apiURL)
            }
        }
        settingsWindowController?.showWindow()
    }
}
