import Foundation

struct CLI {
    static func run() {
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
            default:
                break
            }
            i += 1
        }

        // Auto-detect from git if needed
        if user == nil || repo == nil {
            if let gitInfo = detectGitInfo() {
                if user == nil {
                    user = gitInfo.user
                }
                if repo == nil {
                    repo = gitInfo.repo
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

        let issueData = IssueData(
            user: finalUser,
            repository: finalRepo,
            issueNumber: finalIssue
        )

        IssueStore.shared.currentIssue = issueData
        print("Set issue: \(issueData.repositoryText) #\(finalIssue)")
    }

    static func detectGitInfo() -> (user: String, repo: String)? {
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

    static func parseGitURL(_ url: String) -> (user: String, repo: String)? {
        // Handle https://github.com/user/repo.git
        // Handle git@github.com:user/repo.git
        let patterns = [
            #"github\.com[:/]([^/]+)/([^/]+?)(\.git)?$"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
                if let userRange = Range(match.range(at: 1), in: url),
                   let repoRange = Range(match.range(at: 2), in: url) {
                    return (String(url[userRange]), String(url[repoRange]))
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

    static func printUsage() {
        print("""
        Usage:
          issueWidget --issue <number> [--repo <repo>] [--user <user>]
          issueWidget --status
          issueWidget --clear
          issueWidget --quit

        Options:
          --issue <number>  GitHub issue number
          --repo <repo>     Repository name (auto-detected from git if omitted)
          --user <user>     GitHub username (auto-detected from git if omitted)
          --status          Show current issue as JSON
          --clear           Clear the current issue
          --quit            Quit the IssueWidget app

        Examples:
          issueWidget --issue 266
          issueWidget --user microsoft --repo vscode --issue 12345
          issueWidget --status
          issueWidget --clear
          issueWidget --quit
        """)
    }
}

CLI.run()
