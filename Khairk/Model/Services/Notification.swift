//
//  NotificationCenter.swift
//  Khairk
//
//  Created by BP-36-201-18 on 19/12/2025.
//
import FirebaseFirestore
import UserNotifications

class Notification {
    static let shared = Notification()
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
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleExpiryCheck(donationId: String, foodName: String, expiryDate: Date) {
        let now = Date()
        let twoDaysInSeconds: TimeInterval = 172800
        let onDaysInSeconds: TimeInterval = 86400
        let oneHourInSeconds: TimeInterval = 3600
        let notifyDate2Days = expiryDate.addingTimeInterval(-twoDaysInSeconds)
        let notifyDate1Days = expiryDate.addingTimeInterval(-onDaysInSeconds)
        
        var finalNotifyDate: Date
        var timeRemainingLabel: String
        
        if notifyDate2Days > now {
            finalNotifyDate = notifyDate2Days
            timeRemainingLabel = "2 days"
        } else if notifyDate1Days > now {
            finalNotifyDate = notifyDate1Days
            timeRemainingLabel = "1 days"
        } else {
            finalNotifyDate = expiryDate.addingTimeInterval(-oneHourInSeconds)
            timeRemainingLabel = "1 hour"
        }
        
        guard finalNotifyDate > now else {
            print("Expiry for \(foodName) is too close to schedule a warning.")
            return
        }
                
        let content = UNMutableNotificationContent()
        content.title = "Donation Expiring Soon!"
        content.body = "The donation '\(foodName)' will expire in exactly \(timeRemainingLabel). Please take action now!"
        content.sound = .default
        content.badge = 1
                
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: finalNotifyDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
        let request = UNNotificationRequest(identifier: "expiry_\(donationId)", content: content, trigger: trigger)
                
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleLocalNotification(title: String, body: String, delay: TimeInterval? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
            
        let interval = delay ?? 1.0
        let finalInterval = interval > 0 ? interval : 1.0
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: finalInterval, repeats: false)
            
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }

    func save(title: String, body: String, userId: String, adminDelay: TimeInterval? = nil, makeLocalNotification: Bool){
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
                if makeLocalNotification {
                    self.scheduleLocalNotification(title: title, body: body, delay: adminDelay)
                }
            }
        }
    }
}
