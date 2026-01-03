//
//  Donation.swift
//  Khairk
//
//  Created by BP-19-130-16 on 27/12/2025.
//

import Foundation
import FirebaseFirestore

struct Donation {
    // ✅ Core fields (Batool)
    let id: String
    let foodName: String
    let description: String
    let donationType: String
    let quantity: Int
    let status: String
    let imageURL: String
    let createdAt: Date
    let expiryDate: Date
    let donorId: String
    let caseId: String

    let serviceArea: String?
    let pickupTime: Date?
    let latitude: Double?
    let longitude: Double?

    // ✅ Extra fields used by Collector screens (optional)
    let ngoId: String?
    let pickupStatus: String?

    let donorName: String?
    let donorEmail: String?
    let donorPhone: String?

    let foodType: String?
    let pickupMethod: String?

    let caseTitle: String?
    let caseDescription: String?
    let caseTarget: Int?
    let caseCollected: Int?

    // ✅ Batool initializer (dictionary)
    init?(id: String, dictionary: [String: Any]) {
        // 🔴 REQUIRED (MINIMAL)
            guard
                let foodName = dictionary["foodName"] as? String,
                let expiryTS = dictionary["expiryDate"] as? Timestamp,
                let createdTS = dictionary["createdAt"] as? Timestamp,
                let status = dictionary["status"] as? String
            else {
                print("❌ Missing required fields:", dictionary)
                return nil
            }

            self.id = id
            self.foodName = foodName
            self.expiryDate = expiryTS.dateValue()
            self.createdAt = createdTS.dateValue()
            self.status = status

            // 🟢 OPTIONAL SAFE PARSING
            self.description = dictionary["description"] as? String ?? ""
            self.donationType =
                dictionary["donationType"] as? String ??
                dictionary[" donationType"] as? String ?? "unknown"

            self.quantity =
                dictionary["quantity"] as? Int ??
                Int(dictionary["quantity"] as? String ?? "") ?? 0

            self.imageURL = dictionary["imageURL"] as? String ?? ""
            self.donorId = dictionary["donorId"] as? String ?? ""
            self.caseId = dictionary["caseId"] as? String ?? ""

            self.serviceArea = dictionary["serviceArea"] as? String
            self.latitude = dictionary["latitude"] as? Double
            self.longitude = dictionary["longitude"] as? Double

            if let pickupTS = dictionary["pickupTime"] as? Timestamp {
                self.pickupTime = pickupTS.dateValue()
            } else {
                self.pickupTime = nil
            }

            self.ngoId =
                dictionary["ngoId"] as? String ??
                dictionary["ngoID"] as? String

            self.pickupStatus = dictionary["pickupStatus"] as? String

            self.donorName = nil
            self.donorEmail = nil
            self.donorPhone = nil
            self.foodType = nil
            self.pickupMethod = nil
            self.caseTitle = nil
            self.caseDescription = nil
            self.caseTarget = nil
            self.caseCollected = nil
    }

    // ✅ Collector initializer (DocumentSnapshot)
    init?(doc: DocumentSnapshot) {
        guard let d = doc.data() else { return nil }
        self.init(id: doc.documentID, dictionary: d)
    }
}
