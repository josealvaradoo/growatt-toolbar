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
    private let prefs = AppPreferences()

    func applicationDidFinishLaunching(_ notification: Notification) {
#if DEBUG
        DotEnv.loadDotenv()
#endif

        let defaults = UserDefaults.standard

        if defaults.bool(forKey: "hasCompletedOnboarding"), prefs.hasCredentials {
            finishSetup(apiKey: prefs.apiKey, apiURL: prefs.apiURL)
            NSApp.setActivationPolicy(.accessory)
        } else {
            let onboarding = SettingsWindowController { [weak self] apiKey, apiURL in
                guard let self else { return }
                try self.prefs.save(apiKey: apiKey, apiURL: apiURL)
                defaults.set(true, forKey: "hasCompletedOnboarding")
                self.finishSetup(apiKey: apiKey, apiURL: apiURL)
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
        settingsWindowController?.closeWindow()
        settingsWindowController = SettingsWindowController(
            initialApiKey: prefs.apiKey,
            initialApiURL: prefs.apiURL
        ) { [weak self] apiKey, apiURL in
            guard let self else { return }
            try self.prefs.save(apiKey: apiKey, apiURL: apiURL)
            self.finishSetup(apiKey: apiKey, apiURL: apiURL)
        }
        settingsWindowController?.showWindow()
    }
}
