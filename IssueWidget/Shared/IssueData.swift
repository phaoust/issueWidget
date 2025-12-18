import Foundation

struct IssueData: Codable {
    let user: String
    let repository: String
    let issueNumber: Int

    var url: URL {
        URL(string: "https://github.com/\(user)/\(repository)/issues/\(issueNumber)")!
    }

    var displayText: String {
        "#\(issueNumber)"
    }

    var repositoryText: String {
        "\(user)/\(repository)"
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
