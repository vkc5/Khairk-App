//
//  Donation.swift
//  Khairk
//
//  Created by BP-19-130-16 on 27/12/2025.
//

import Foundation
import FirebaseFirestore

struct Donation {
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
    // Initialize from Firebase dictionary
    init?(id: String, dictionary: [String: Any]) {
        guard
            let foodName = dictionary["foodName"] as? String,
            let description = dictionary["description"] as? String,
            let donationType = dictionary["donationType"] as? String,
            let quantity = dictionary["quantity"] as? Int,
            let status = dictionary["status"] as? String,
            let imageURL = dictionary["imageURL"] as? String,
            let donorId = dictionary["donorId"] as? String,
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
    }
}
