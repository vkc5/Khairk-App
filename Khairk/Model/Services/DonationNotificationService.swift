//
//  DonationNotificationService.swift
//  Khairk
//
//  Created by BP-36-213-17 on 04/01/2026.
//

import Foundation
import FirebaseFirestore
import UserNotifications

final class DonationNotificationService {

    static let shared = DonationNotificationService()

    private let db = Firestore.firestore()
    private var donationListener: ListenerRegistration?

    /// Track already scheduled notifications (avoid duplicates)
    private var scheduledDonationIds = Set<String>()

    private init() {}


    func monitorExpiryForUser(userId: String, role: String) {
        print("👀 Monitoring expiry for role:", role, "user:", userId)

        let collection = db.collection("donations")
        let query: Query

        if role == "admin" {
            query = collection
                .whereField("pickupStatus", in: ["pending", "in_progress", "accepted"])
        } else if role == "collector" {
            query = collection
                .whereField("ngoId", isEqualTo: userId)
                .whereField("pickupStatus", in: ["in_progress", "accepted"])
        } else {
            return
        }

        donationListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Donation monitor error:", error.localizedDescription)
                return
            }

            guard let documents = snapshot?.documents else { return }

            let now = Date()

            for doc in documents {

                if self.scheduledDonationIds.contains(doc.documentID) {
                    continue
                }

                guard let donation = Donation(doc: doc) else { continue }

                guard donation.expiryDate > now else { continue }

                Notification.shared.scheduleExpiryCheck(
                    donationId: donation.id,
                    foodName: donation.foodName,
                    expiryDate: donation.expiryDate
                )

                self.scheduledDonationIds.insert(donation.id)

                print("⏰ Expiry notification scheduled for:", donation.foodName)
            }
        }
    }
    
    func listenDonationStatusChanges(donationsId: String) {
        
        db.collection("donations").document(donationsId).addSnapshotListener { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            let data = snapshot.data() ?? [:]
            guard
                let status = data["status"] as? String,
                let foodName = data["foodName"] as? String,
                let donorId = data["donorId"] as? String
            else {
                return
            }
            print("Donation status changed:", status)
            switch status {
                
            case "approved":
                Notification.shared.save(
                    title: "Donation Approved ✅",
                    body: "Your donation of \(foodName) has been approved.",
                    userId: donorId,
                    makeLocalNotification: true
                )
                
            case "rejected":
                Notification.shared.save(
                    title: "Donation Rejected ❌",
                    body: "Your donation of \(foodName) was rejected.",
                    userId: donorId,
                    makeLocalNotification: true
                )
                
            default:
                break
            }
        }
    }


    // MARK: - Stop Monitoring

    func stopMonitoring() {
        donationListener?.remove()
        donationListener = nil
        scheduledDonationIds.removeAll()
        print("🛑 Stopped monitoring donations.")
    }
}
