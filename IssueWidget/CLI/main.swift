import Foundation
import AppKit

struct CLI {
    static func run() {
        // Ensure app is running for commands that need it
        let needsApp = !CommandLine.arguments.contains("--status") &&
                      !CommandLine.arguments.contains("--help")

        if needsApp {
            ensureAppIsRunning()
        }
        let args = CommandLine.arguments

        if args.contains("--status") {
            printStatus()
            return
        }

        if args.contains("--quit") {
            quitApp()
            return
        }

        if args.contains("--clear") {
            IssueStore.shared.clear()
            print("Issue cleared")
            return
        }

        // Parse arguments
        var user: String?
        var repo: String?
        var issue: Int?
        var host: String?
        var project: String?

        var i = 1
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--user":
                if i + 1 < args.count {
                    user = args[i + 1]
                    i += 1
                }
            case "--repo":
                if i + 1 < args.count {
                    repo = args[i + 1]
                    i += 1
                }
            case "--issue":
                if i + 1 < args.count {
                    issue = Int(args[i + 1])
                    i += 1
                }
            case "--host":
                if i + 1 < args.count {
                    host = args[i + 1]
                    i += 1
                }
            case "--project":
                if i + 1 < args.count {
                    project = args[i + 1]
                    i += 1
                }
            default:
                break
            }
            i += 1
        }

        // Auto-detect from git if needed
        if user == nil || repo == nil || host == nil {
            if let gitInfo = detectGitInfo() {
                if user == nil {
                    user = gitInfo.user
                }
                if repo == nil {
                    repo = gitInfo.repo
                }
                if host == nil {
                    host = gitInfo.host
                }
            }
        }

        // Handle --project parameter for non-git hosts
        if let projectValue = project {
            let effectiveHost = host ?? "github.com"

            // For non-git hosts (Trello, Asana, etc.), --project maps to the project/board ID
            if effectiveHost.contains("trello") || effectiveHost.contains("asana") {
                user = projectValue
                // Always set repo to a placeholder for non-git hosts
                repo = "project"
            } else {
                // For git hosts, --project could be "user/repo" format
                let parts = projectValue.split(separator: "/")
                if parts.count == 2 {
                    user = String(parts[0])
                    repo = String(parts[1])
                } else {
                    // Single value, treat as repo if user is already set, otherwise as user
                    if user != nil {
                        repo = projectValue
                    } else {
                        user = projectValue
                    }
                }
            }
        }

        // Validate we have all required info
        guard let finalUser = user,
              let finalRepo = repo,
              let finalIssue = issue else {
            printUsage()
            exit(1)
        }

        // host is optional, defaults to github.com in IssueData
        let issueData = IssueData(
            user: finalUser,
            repository: finalRepo,
            issueNumber: finalIssue,
            host: host
        )

        IssueStore.shared.currentIssue = issueData
        let hostInfo = host.map { " (\($0))" } ?? ""
        print("Set issue: \(issueData.repositoryText) #\(finalIssue)\(hostInfo)")
    }

    static func detectGitInfo() -> (user: String, repo: String, host: String)? {
        // Try to get git remote URL
        let task = Process()
        task.launchPath = "/usr/bin/git"
        task.arguments = ["remote", "get-url", "origin"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()

            guard task.terminationStatus == 0 else { return nil }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return nil }

            return parseGitURL(output.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            return nil
        }
    }

    static func parseGitURL(_ url: String) -> (user: String, repo: String, host: String)? {
        // Handle https://host.com/user/repo.git
        // Handle git@host.com:user/repo.git
        // Support GitHub, GitLab, Bitbucket, and other git hosts
        let patterns = [
            #"([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})[:/]([^/]+)/([^/]+?)(\.git)?$"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
                if let hostRange = Range(match.range(at: 1), in: url),
                   let userRange = Range(match.range(at: 2), in: url),
                   let repoRange = Range(match.range(at: 3), in: url) {
                    return (
                        user: String(url[userRange]),
                        repo: String(url[repoRange]),
                        host: String(url[hostRange])
                    )
                }
            }
        }

        return nil
    }

    static func printStatus() {
        if let issue = IssueStore.shared.currentIssue {
            let json: [String: Any] = [
                "user": issue.user,
                "repository": issue.repository,
                "issue": issue.issueNumber,
                "host": issue.hostName,
                "url": issue.url.absoluteString
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            print("{}")
        }
    }

    static func quitApp() {
        DistributedNotificationCenter.default().post(
            name: NSNotification.Name("IssueWidgetQuit"),
            object: nil
        )
        print("Quit signal sent to IssueWidget app")
    }

    static func ensureAppIsRunning() {
        let bundleID = "com.issuewidget.IssueWidget"

        // Check if app is already running
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains { app in
            app.bundleIdentifier == bundleID
        }

        if !isRunning {
            // Try to find and launch the app
            let appPath = findAppPath()

            if let path = appPath {
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = [path]

                do {
                    try task.run()
                    // Give the app time to start up
                    Thread.sleep(forTimeInterval: 1.5)
                } catch {
                    print("Warning: Could not launch IssueWidget app")
                }
            }
        }
    }

    static func findAppPath() -> String? {
        // Check common locations
        let possiblePaths = [
            "/Applications/IssueWidget.app",
            "\(FileManager.default.homeDirectoryForCurrentUser.path)/Applications/IssueWidget.app",
            // Relative to CLI binary in build directory
            "\(CommandLine.arguments[0])/../../IssueWidget.app",
            // Build directory
            "build/IssueWidget.app"
        ]

        for path in possiblePaths {
            let expandedPath = (path as NSString).expandingTildeInPath
            let resolvedPath = (expandedPath as NSString).standardizingPath

            if FileManager.default.fileExists(atPath: resolvedPath) {
                return resolvedPath
            }
        }

        return nil
    }

    static func printUsage() {
        print("""
        Usage:
          issueWidget --issue <number> [--repo <repo>] [--user <user>] [--host <host>]
          issueWidget --issue <number> --project <project> [--host <host>]
          issueWidget --status
          issueWidget --clear
          issueWidget --quit

        Options:
          --issue <number>    Issue number
          --repo <repo>       Repository name (auto-detected from git if omitted)
          --user <user>       Username (auto-detected from git if omitted)
          --host <host>       Git host (auto-detected from git, defaults to github.com)
          --project <project> Project/board ID (for Trello, Asana, etc.) or user/repo format
          --status            Show current issue as JSON
          --clear             Clear the current issue
          --quit              Quit the IssueWidget app

        Supported hosts:
          GitHub, GitLab, Bitbucket, and other standard git hosts
          Trello, Asana (use --project for board/project ID)

        Examples:
          issueWidget --issue 1
          issueWidget --user phaoust --repo issueWidget --issue 1
          issueWidget --project phaoust/issueWidget --issue 1
          issueWidget --host gitlab.com --user myuser --repo myrepo --issue 42
          issueWidget --host trello.com --project abc123XYZ --issue 42
          issueWidget --status
          issueWidget --clear
          issueWidget --quit
        """)
    }
}

CLI.run()
