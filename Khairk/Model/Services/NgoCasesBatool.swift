//
//  NotificationCenter.swift
//  Khairk
//
//  Created by BP-36-201-18 on 19/12/2025.
//
import Foundation
import FirebaseFirestore

struct NgoCases {
    let id: String
    let title: String
    let description: String
    let goal: Int
    let imageUrl: String
    let measurements: String
    let ngoId: String
    let createdAt: Date
    let startDate: Date?
    let endDate: Date?

    // Initialize from Firebase dictionary
    init?(id: String, dictionary: [String: Any]) {
        guard
            let title = dictionary["title"] as? String,
            let description = dictionary["description"] as? String,
            let goal = dictionary["Goal"] as? Int,
            let imageUrl = dictionary["imageURL"] as? String,
            let measurements = dictionary["measurements"] as? String,
            let ngoId = dictionary["ngoID"] as? String
        else {
            print("Failed to initialize NgoCases due to missing or invalid required fields: \(dictionary)")
            return nil
        }
        
        guard let createdAtTimestamp = dictionary["createdAt"] as? Timestamp else {
                print("Missing 'createdAt' timestamp")
                return nil
        }
        
        let startTimestamp = dictionary["startDate"] as? Timestamp
        let endTimestamp = dictionary["endDate"] as? Timestamp

        let createdAt = createdAtTimestamp.dateValue()
        self.createdAt = createdAt

        let startDate = startTimestamp?.dateValue()
        let endDate = endTimestamp?.dateValue()
        
        self.startDate = startDate
        self.endDate = endDate

        self.id = id
        self.title = title
        self.description = description
        self.goal = goal
        self.imageUrl = imageUrl
        self.measurements = measurements
        self.ngoId = ngoId

    }
}
