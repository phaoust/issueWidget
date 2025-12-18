import Cocoa

class MenuBarManager {
    private let statusItem: NSStatusItem
    private let issueStore = IssueStore.shared

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
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
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleClick)
        }
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
        guard let button = statusItem.button else { return }

        if let issue = issueStore.currentIssue {
            button.title = issue.displayText
            button.toolTip = issue.repositoryText
        } else {
            button.title = "○"
            button.toolTip = "No active issue"
        }
    }

    @objc private func handleClick() {
        if let issue = issueStore.currentIssue {
            NSWorkspace.shared.open(issue.url)
        } else {
            // Show a simple menu when no issue is set
            showMenu()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "No active issue", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
