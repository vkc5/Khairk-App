//
//  NotificationCenter.swift
//  Khairk
//
//  Created by BP-36-201-18 on 19/12/2025.
//
import FirebaseFirestore

class Notification {
    private let db = Firestore.firestore()
    struct AppNotification {
        let id: String
        let title: String
        let body: String
        var isRead: Bool
        let userID: String
        let timestamp: Date
        // Initialize from Firebase dictionary
        init?(id: String, dictionary: [String: Any]) {
            guard
                let title = dictionary["title"] as? String,
                let body = dictionary["body"] as? String,
                let isReadValue = dictionary["isRead"] as? Int, // convert 0/1 to Bool
                let userID = dictionary["userId"] as? String,
                let firestoreTimestamp = dictionary["createdAt"] as? Timestamp
            else {
                return nil
            }

            self.id = id
            self.title = title
            self.body = body
            self.isRead = isReadValue != 0  // 0 = false, 1 = true
            self.userID = userID
            self.timestamp = firestoreTimestamp.dateValue()
        }
    }

    func save(title: String, body: String, userId: String){
        let data: [String: Any] = [
            "title": title,
            "body": body,
            "userId": userId,
            "isRead": 0,
            "createdAt": Timestamp(date: Date())
        ]
        db.collection("notifications").addDocument(data: data) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added for userId: \(userId)")
            }
        }
    }
}
