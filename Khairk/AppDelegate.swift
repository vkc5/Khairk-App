//
//  AppDelegate.swift
//  Khairk
//
//  Created by vkc5 on 22/11/2025.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    private var didRunUnreadCheck = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //for notifocation delegate
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        Notification.shared.requestAuthorization { _ in }
        
        //ask for permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            print("Permission granted: \(granted)")
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard
                let self = self,
                let user = user,
                !self.didRunUnreadCheck
            else { return }
            
            self.didRunUnreadCheck = true
            
            print("👤 User logged in:", user.uid)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Notification.shared.showUnreadNotificationsOnAppOpen(userId: user.uid)
            }
        }
        return true
    }
    
    // MARK: FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM token: \(token)")
        // TODO: save token to firestore for this user
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("🟢 App became active")

        // CLEAR BADGE
        UNUserNotificationCenter.current().setBadgeCount(0)

        Notification.shared.clearBadge()
    }
    
    // MARK: -
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let title = (userInfo["notification"] as? [String: Any])?["title"] as? String ?? ""
        let body  = (userInfo["notification"] as? [String: Any])?["body"]  as? String ?? ""

        print("Push received:", title, body)

        completionHandler(.newData)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

