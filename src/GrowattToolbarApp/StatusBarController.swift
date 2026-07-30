import AppKit
import SwiftUI
import GrowattToolbarCore

/// Controller managing macOS NSStatusItem menu bar placement and NSPopover lifecycle.
@MainActor
public final class StatusBarController: NSObject {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let viewModel: InverterViewModel

    public init(viewModel: InverterViewModel = InverterViewModel()) {
        self.viewModel = viewModel
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        super.init()

        setupPopover()
        setupStatusItem()
        viewModel.startAutoRefresh()
        observeStatus()
    }

    private func setupPopover() {
        popover.contentSize = NSSize(width: 280, height: 180)  // canonical width (280pt) — matches GrowattPopoverView.frame(width: 280)
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
