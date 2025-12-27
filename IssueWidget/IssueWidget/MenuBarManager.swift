import Cocoa

class StatusBarView: NSView {
    var onLeftClick: (() -> Void)?
    var onRightClick: ((NSEvent) -> Void)?
    var displayText: String = "○" {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.menuBarFont(ofSize: 0),
            .foregroundColor: NSColor.controlTextColor
        ]

        let textSize = (displayText as NSString).size(withAttributes: attributes)
        let textRect = NSRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        (displayText as NSString).draw(in: textRect, withAttributes: attributes)
    }

    override func mouseDown(with event: NSEvent) {
        onLeftClick?()
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick?(event)
    }
}

class MenuBarManager: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let issueStore = IssueStore.shared
    private var customView: StatusBarView?

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        super.init()
        setupStatusItem()
        updateDisplay()

        // Listen for changes from CLI
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleIssueDataChanged),
            name: NSNotification.Name("IssueDataChanged"),
            object: nil
        )

        // Listen for quit command from CLI
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleQuitCommand),
            name: NSNotification.Name("IssueWidgetQuit"),
            object: nil
        )
    }

    private func setupStatusItem() {
        // Create custom view with a reasonable initial width
        let view = StatusBarView(frame: NSRect(x: 0, y: 0, width: 40, height: 22))

        view.onLeftClick = { [weak self] in
            self?.handleLeftClick()
        }

        view.onRightClick = { [weak self] event in
            self?.handleRightClick(event: event)
        }

        statusItem.view = view
        customView = view
    }

    @objc private func handleIssueDataChanged() {
        DispatchQueue.main.async {
            self.updateDisplay()
        }
    }

    @objc private func handleQuitCommand() {
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
    }

    private func updateDisplay() {
        if let issue = issueStore.currentIssue {
            customView?.displayText = issue.displayText
            customView?.toolTip = issue.repositoryText
        } else {
            customView?.displayText = "○"
            customView?.toolTip = "No active issue"
        }
    }

    private func handleLeftClick() {
        if let issue = issueStore.currentIssue {
            NSWorkspace.shared.open(issue.url)
        }
    }

    private func handleRightClick(event: NSEvent) {
        showContextMenu(event: event)
    }

    private func showContextMenu(event: NSEvent) {
        let menu = NSMenu()
        menu.autoenablesItems = false

        if issueStore.currentIssue != nil {
            let clearItem = NSMenuItem(title: "Clear", action: #selector(clearIssue), keyEquivalent: "")
            clearItem.target = self
            clearItem.isEnabled = true
            menu.addItem(clearItem)
        } else {
            let noIssueItem = NSMenuItem(title: "No active issue", action: nil, keyEquivalent: "")
            noIssueItem.isEnabled = false
            menu.addItem(noIssueItem)
        }

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        quitItem.isEnabled = true
        menu.addItem(quitItem)

        if let view = customView {
            NSMenu.popUpContextMenu(menu, with: event, for: view)
        }
    }

    @objc private func clearIssue() {
        issueStore.clear()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
