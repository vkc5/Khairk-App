//
//  User.swift
//  Khairk
//
//  Created by BP-19-130-16 on 31/12/2025.
//

import Foundation
import FirebaseFirestore

struct User {
    let id: String
    let name: String
    let email: String
    let phone: String
    let role: String
    let createdAt: Date
    
    let profileImageUrl: String?
    
    var applicationStatus: String?
    let activeCases: Int?
    let donationsCollected: Int?
    let familiesSupported: Int?
    let licenseUrl: String?
    let logoUrl: String?
    let mealsDelivered: Int?
    let memberEmail: String?
    let memberName: String?
    let memberPhone: String?
    let ngoLocation: GeoPoint?
    let peopleReached: Int?
    let serviceArea: String?
    let weeklyActivity: [Int]?

    // Initialize from Firebase dictionary
    init?(id: String, dictionary: [String: Any]) {
        guard
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let phone = dictionary["phone"] as? String,
            let role = dictionary["role"] as? String,
            let createdAtTimestamp = dictionary["createdAt"] as? Timestamp
        else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.role = role
        self.createdAt = createdAtTimestamp.dateValue()

        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.applicationStatus = dictionary["applicationStatus"] as? String
        self.activeCases = dictionary["activeCases"] as? Int
        self.donationsCollected = dictionary["donationsCollected"] as? Int
        self.familiesSupported = dictionary["familiesSupported"] as? Int
        self.licenseUrl = dictionary["licenseUrl"] as? String
        self.logoUrl = dictionary["logoUrl"] as? String
        self.mealsDelivered = dictionary["mealsDelivered"] as? Int
        self.memberEmail = dictionary["memberEmail"] as? String
        self.memberName = dictionary["memberName"] as? String
        self.memberPhone = dictionary["memberPhone"] as? String
        self.ngoLocation = dictionary["ngoLocation"] as? GeoPoint
        self.peopleReached = dictionary["peopleReached"] as? Int
        self.serviceArea = dictionary["serviceArea"] as? String
        self.weeklyActivity = dictionary["weeklyActivity"] as? [Int]
    }
}
