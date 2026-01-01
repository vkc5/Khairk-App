import Foundation

struct SystemLog {
    let timestamp: Date
    let userName: String
    let userRole: String
    let type: String
    let action: String
    let description: String
    let severity: String
    let metadata: [String: Any]

    init(
        timestamp: Date,
        userName: String,
        userRole: String,
        type: String,
        action: String,
        description: String,
        severity: String,
        metadata: [String: Any] = [:]
    ) {
        self.timestamp = timestamp
        self.userName = userName
        self.userRole = userRole
        self.type = type
        self.action = action
        self.description = description
        self.severity = severity
        self.metadata = metadata
    }
}
