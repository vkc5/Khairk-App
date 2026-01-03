//
//  DonationNotificationService.swift
//  Khairk
//
//  Created by BP-36-213-17 on 03/01/2026.
//

import Foundation
import FirebaseFirestore
import UserNotifications

class DonationNotificationService {
    
    static let shared = DonationNotificationService()
    
    private let db = Firestore.firestore()
    private var donationListener: ListenerRegistration?
    
    private init() {}
    
    // MARK: - Start Monitoring Assignments
    
    func monitorExpiryForUser(userId: String, role: String) {
        print("Starting assignment monitoring for \(role): \(userId)")
        
        let collection = db.collection("donations")
        var query: Query
        if role == "admin" {
            // Admin watches all new donations
            query = collection.whereField("status", in: ["pending","in_progress","accepted"])
        } else if role == "collector" {
            // Collector watches donations assigned to their NGO
            query = collection.whereField("ngoId", isEqualTo: userId).whereField("status", in: ["in_progress","accepted"])
        } else {
            return
        }
        donationListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error monitoring: \(error.localizedDescription)")
                return
            }
            snapshot?.documents.forEach { doc in
                if let donation = Donation(doc: doc) {
                    // This sets the local UNCalendarNotificationTrigger
                    Notification.shared.scheduleExpiryCheck(
                        donationId: donation.id,
                        foodName: donation.foodName,
                        expiryDate: donation.expiryDate
                    )
                    print(donation)
                }
            }
        }
    }
    
    /// Stop monitoring assignments
    func stopMonitoring() {
        donationListener?.remove()
        donationListener = nil
        print("Stopped monitoring donations.")
    }
    
}
