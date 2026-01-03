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
    private var listener: ListenerRegistration?
    
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
    
    // MARK: - Request Permission
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error)")
            }
            print(granted ? "✅ Notification permission GRANTED" : "❌ Notification permission DENIED")
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Check Permission Status
    
    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            print("📱 Notification status: \(settings.authorizationStatus.rawValue)")
            print("   0=notDetermined, 1=denied, 2=authorized, 3=provisional, 4=ephemeral")
            completion(isAuthorized)
        }
    }
    
    // MARK: - Show Unread Notifications on App Open
    
    /// Automatically fetch and show all unread notifications when app opens
    func showUnreadNotificationsOnAppOpen(userId: String) {
        print("🔔 ============================================")
        print("🔔 Checking for unread notifications")
        print("🔔 User ID: \(userId)")
        print("🔔 ============================================")
        
        // First check if we have permission
        checkPermissionStatus { [weak self] isAuthorized in
            guard isAuthorized else {
                print("❌ No notification permission! Requesting now...")
                self?.requestAuthorization { granted in
                    if granted {
                        self?.fetchAndShowNotifications(userId: userId)
                    } else {
                        print("❌ User denied notification permission")
                    }
                }
                return
            }
            
            print("✅ Notification permission is authorized")
            self?.fetchAndShowNotifications(userId: userId)
        }
    }
    
    private func fetchAndShowNotifications(userId: String) {
        db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: 0)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching notifications: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("❌ No documents found")
                    return
                }
                
                print("📬 Fetched notifications count: \(documents.count)")
                
                let unreadDocs = documents.filter { doc in
                    let data = doc.data()
                    let isRead = data["isRead"] as? Int ?? 1
                    return isRead == 0
                }
                
                print("📭 Unread notifications: \(unreadDocs.count)")
                
                guard !unreadDocs.isEmpty else {
                    print("📭 No unread notifications")
                    DispatchQueue.main.async {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
                    return
                }
                
                print("✅ Found \(unreadDocs.count) unread notification(s)")
                print("🔔 Starting to schedule notifications...")

                // Show each notification with a slight delay
                for (index, doc) in unreadDocs.enumerated() {
                    let data = doc.data()
                    
                    guard
                        let title = data["title"] as? String,
                        let body = data["body"] as? String
                    else {
                        print("⚠️ Skipping notification \(doc.documentID) - missing title or body")
                        continue
                    }
                    
                    print("📝 Notification \(index + 1): \(title)")
                    
                    let delay = Double(index) * 1.0 // 1 second apart
                    
                    self?.scheduleLocalNotificationList(
                        title: title,
                        body: body,
                        delay: delay,
                        identifier: "unread_\(doc.documentID)",
                        notificationNumber: index + 1,
                        totalNotifications: unreadDocs.count
                    )
                }
                
                // Update badge count
                DispatchQueue.main.async {
                    UNUserNotificationCenter.current().setBadgeCount(unreadDocs.count)
                    print("🔢 Badge count set to: \(unreadDocs.count)")
                }
                
                print("🔔 ============================================")
                print("🔔 Finished scheduling \(unreadDocs.count) notifications")
                print("🔔 ============================================")
            }
    }
    
    // MARK: - Schedule Local Notification
    private func scheduleLocalNotificationList(
        title: String,
        body: String,
        delay: TimeInterval,
        identifier: String,
        notificationNumber: Int,
        totalNotifications: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: totalNotifications - notificationNumber + 1)
        
        // Use time interval trigger
        let actualDelay = max(delay, 0.1) // Minimum 0.1 seconds
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: actualDelay,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        print("⏰ Scheduling notification '\(title)' in \(actualDelay)s")
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Successfully scheduled: \(title)")
            }
        }
    }
    
    func markAsRead(notificationId: String) {
        print("✓ Marking notification as read: \(notificationId)")
        
        db.collection("notifications").document(notificationId)
            .updateData(["isRead": 1]) { error in
                if let error = error {
                    print("❌ Error marking as read: \(error.localizedDescription)")
                } else {
                    print("✅ Marked notification as read: \(notificationId)")
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
    
    // MARK: - Clear Badge
    
    func clearBadge() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }
}
