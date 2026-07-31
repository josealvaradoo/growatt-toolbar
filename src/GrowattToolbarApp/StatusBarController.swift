import AppKit
import SwiftUI
import GrowattToolbarCore

/// Controller managing macOS NSStatusItem menu bar placement and NSPopover lifecycle.
/// Handles both left-click (popover toggle) and right-click (settings/quit menu).
@MainActor
public final class StatusBarController: NSObject {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private(set) var viewModel: InverterViewModel
    private var eventMonitor: SendableBox?

    public var onSettingsRequested: (() -> Void)?

    public init(viewModel: InverterViewModel) {
        self.viewModel = viewModel
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        super.init()

        setupPopover()
        setupStatusItem()
        setupRightClickMenu()
        viewModel.startAutoRefresh()
        observeStatus()
    }

    deinit {
        MainActor.assumeIsolated {
            NSStatusBar.system.removeStatusItem(statusItem)
            if let monitor = eventMonitor?.value {
                NSEvent.removeMonitor(monitor)
            }
        }
    }

    private func setupPopover() {
        popover.contentSize = NSSize(width: 280, height: 180)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: GrowattPopoverView(viewModel: viewModel)
        )
    }

    private var statusIconImage: NSImage? {
        let image: NSImage?
        if let assetImage = Bundle.module.image(forResource: "StatusIcon") ?? NSImage(named: "StatusIcon") {
            image = assetImage
        } else if let url = Bundle.module.url(forResource: "icon", withExtension: "svg"),
                  let svgImage = NSImage(contentsOf: url) {
            image = svgImage
        } else {
            image = nil
        }

        image?.isTemplate = true
        image?.size = NSSize(width: 18, height: 14)
        return image
    }

    private func setupStatusItem() {
        if let button = statusItem.button {
            if let icon = statusIconImage {
                button.image = icon
                button.imagePosition = .imageLeft
            }
            updateButtonTitle()
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    private func setupRightClickMenu() {
        eventMonitor = SendableBox(value: NSEvent.addLocalMonitorForEvents(matching: .rightMouseUp) { [weak self] event in
            guard let self,
                  let button = self.statusItem.button,
                  event.window == button.window else {
                return event
            }
            let point = button.convert(event.locationInWindow, from: nil)
            guard button.bounds.contains(point) else {
                return event
            }

            let menu = NSMenu()
            let settingsItem = NSMenuItem(
                title: "Settings…",
                action: #selector(self.openSettingsAction),
                keyEquivalent: ""
            )
            settingsItem.target = self
            menu.addItem(settingsItem)
            menu.addItem(NSMenuItem.separator())
            let quitItem = NSMenuItem(
                title: "Quit",
                action: #selector(self.quitAction),
                keyEquivalent: ""
            )
            quitItem.target = self
            menu.addItem(quitItem)

            NSMenu.popUpContextMenu(menu, with: event, for: button)
            return nil
        })
    }

    @objc private func openSettingsAction() {
        onSettingsRequested?()
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }

    public func updateButtonTitle() {
        guard let button = statusItem.button else { return }
        let soc = viewModel.status.batterySoC
        button.title = " \(soc)%"
    }

    private func observeStatus() {
        withObservationTracking { [weak self] in
            _ = self?.viewModel.status.batterySoC
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.updateButtonTitle()
                self.observeStatus()
            }
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            updateButtonTitle()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

/// Wraps the opaque token returned by
/// `NSEvent.addLocalMonitorForEvents` so it can be stored in a
/// `@MainActor` class without a strict-concurrency error.  Safe because
/// every access (creation, deinit removal) runs on the main actor.
private struct SendableBox: @unchecked Sendable {
    let value: Any?
}
