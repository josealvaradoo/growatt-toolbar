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
            if finishSetup(apiKey: prefs.apiKey, apiURL: prefs.apiURL) {
                NSApp.setActivationPolicy(.accessory)
            } else {
                presentOnboarding()
            }
        } else {
            presentOnboarding()
        }
    }

    // MARK: - Settings presentation

    private func presentOnboarding() {
        let controller = makeSettingsController(mode: .onboarding)
        settingsWindowController = controller
        controller.showWindow()
    }

    private func reopenSettings() {
        // Route through the same discard-confirmation as the close button so
        // unsaved edits are never discarded silently.
        guard settingsWindowController?.requestClose() ?? true else { return }
        let controller = makeSettingsController(mode: .settings)
        settingsWindowController = controller
        controller.showWindow()
    }

    private func makeSettingsController(mode: SettingsMode) -> SettingsWindowController {
        SettingsWindowController(
            mode: mode,
            initialApiKey: mode == .settings ? prefs.apiKey : nil,
            initialApiURL: mode == .settings ? prefs.apiURL : nil,
            tester: GrowattConnectionTester(),
            persist: { [prefs] apiKey, apiURL in
                try prefs.save(apiKey: apiKey, apiURL: apiURL)
            },
            onSaveCompleted: { [weak self] apiKey, apiURL in
                self?.completeSave(apiKey: apiKey, apiURL: apiURL, mode: mode)
            }
        )
    }

    // MARK: - Save lifecycle

    /// Runs after persistence succeeds. Marks onboarding complete (onboarding
    /// only), reconfigures the runtime service, and dismisses the window.
    /// A failed persistence never reaches this point, so onboarding stays
    /// incomplete and the runtime configuration stays unchanged.
    private func completeSave(apiKey: String, apiURL: String, mode: SettingsMode) {
        // Reconfigure the runtime service first; only mark onboarding complete
        // after both persistence and runtime setup succeed.
        guard finishSetup(apiKey: apiKey, apiURL: apiURL) else { return }
        if mode == .onboarding {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
        NSApp.setActivationPolicy(.accessory)
        settingsWindowController?.closeWindow()
        // Release the onboarding-mode controller so the next Settings reopen
        // creates a fresh settings-mode window (prefilled, no stale-edit
        // discard dialog from the onboarding draft).
        settingsWindowController = nil
    }

    // MARK: - Runtime service

    @discardableResult
    private func finishSetup(apiKey: String, apiURL: String) -> Bool {
        statusBarController?.viewModel.stopAutoRefresh()

        do {
            let service = try GrowattOpenAPIService(baseURLString: apiURL, apiToken: apiKey)
            let viewModel = InverterViewModel(service: service)
            let controller = StatusBarController(viewModel: viewModel)
            controller.onSettingsRequested = { [weak self] in
                self?.reopenSettings()
            }
            statusBarController = controller
            return true
        } catch {
            // Defensive: the URL already passed local validation and a
            // successful connection test, so construction cannot fail here.
            // Never log the error's description — it may echo the endpoint.
            NSLog("Growatt Toolbar: unable to start the status-bar service")
            return false
        }
    }
}
