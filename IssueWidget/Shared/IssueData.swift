import Foundation

struct IssueData: Codable {
    let user: String
    let repository: String
    let issueNumber: Int
    let host: String?

    var url: URL {
        let effectiveHost = host ?? "github.com"
        let urlString: String

        // Different providers use different URL patterns
        if effectiveHost.contains("gitlab") {
            // GitLab uses /-/issues/ format
            urlString = "https://\(effectiveHost)/\(user)/\(repository)/-/issues/\(issueNumber)"
        } else if effectiveHost.contains("trello") {
            // Trello: user=board_id, repository=card_shortlink or search term
            // If issueNumber looks like it could be a card number, search for it
            // Format: https://trello.com/b/BOARD_ID then search for card
            urlString = "https://trello.com/b/\(user)"
        } else {
            // GitHub, Bitbucket, and others use /issues/ format
            urlString = "https://\(effectiveHost)/\(user)/\(repository)/issues/\(issueNumber)"
        }

        return URL(string: urlString)!
    }

    var displayText: String {
        "#\(issueNumber)"
    }

    var repositoryText: String {
        "\(user)/\(repository)"
    }

    var hostName: String {
        host ?? "github.com"
    }
}

class IssueStore {
    static let shared = IssueStore()
    private let suiteName = "group.com.issuewidget.shared"
    private let key = "currentIssue"

    private init() {}

    var currentIssue: IssueData? {
        get {
            guard let defaults = UserDefaults(suiteName: suiteName),
                  let data = defaults.data(forKey: key) else {
                return nil
            }
            return try? JSONDecoder().decode(IssueData.self, from: data)
        }
        set {
            let defaults = UserDefaults(suiteName: suiteName)
            if let issue = newValue {
                let data = try? JSONEncoder().encode(issue)
                defaults?.set(data, forKey: key)
            } else {
                defaults?.removeObject(forKey: key)
            }

            // Post notification for app to update
            DistributedNotificationCenter.default().post(
                name: NSNotification.Name("IssueDataChanged"),
                object: nil
            )
        }
    }

    func clear() {
        currentIssue = nil
    }
}
