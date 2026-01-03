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
        guard
            let foodName = dictionary["foodName"] as? String,
            let description = dictionary["description"] as? String,
            let donationType = dictionary["donationType"] as? String,
            let quantity = dictionary["quantity"] as? Int,
            let status = dictionary["status"] as? String,
            let imageURL = dictionary["imageURL"] as? String,
            let donorId = (dictionary["donorID"] as? String) ?? (dictionary["donorId"] as? String),
            let caseId = dictionary["caseId"] as? String,
            let createdAtTimestamp = dictionary["createdAt"] as? Timestamp,
            let expiryTimestamp = dictionary["expiryDate"] as? Timestamp
        else {
            return nil
        }

        self.id = id
        self.foodName = foodName
        self.description = description
        self.donationType = donationType
        self.quantity = quantity
        self.status = status
        self.imageURL = imageURL
        self.donorId = donorId
        self.caseId = caseId
        self.createdAt = createdAtTimestamp.dateValue()
        self.expiryDate = expiryTimestamp.dateValue()

        self.serviceArea = dictionary["serviceArea"] as? String
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double

        if let pickupTimestamp = dictionary["pickupTime"] as? Timestamp {
            self.pickupTime = pickupTimestamp.dateValue()
        } else {
            self.pickupTime = nil
        }

        // Optional collector fields
        self.ngoId = (dictionary["ngoID"] as? String) ?? (dictionary["ngoId"] as? String)
        self.pickupStatus = dictionary["pickupStatus"] as? String

        self.donorName = dictionary["donorName"] as? String
        self.donorEmail = dictionary["donorEmail"] as? String
        self.donorPhone = dictionary["donorPhone"] as? String

        self.foodType = dictionary["foodType"] as? String
        self.pickupMethod = dictionary["pickupMethod"] as? String

        self.caseTitle = dictionary["caseTitle"] as? String
        self.caseDescription = dictionary["caseDescription"] as? String
        self.caseTarget = dictionary["caseTarget"] as? Int
        self.caseCollected = dictionary["caseCollected"] as? Int
    }

    // ✅ Collector initializer (DocumentSnapshot)
    init?(doc: DocumentSnapshot) {
        guard let d = doc.data() else { return nil }
        self.init(id: doc.documentID, dictionary: d)
    }
}
