//
//  DonationgroupModels.swift
//  Khairk
//
//  Created by FM on 15/12/2025.
//
import Foundation
import FirebaseFirestore

enum GroupStatus: String {
    case active
    case paused
}

struct DonationGroupItem {
    let id: String
    let name: String
    let frequency: String
    let status: GroupStatus
    let createdAt: Date?

    init(id: String,
         name: String,
         frequency: String,
         status: GroupStatus,
         createdAt: Date?) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.status = status
        self.createdAt = createdAt
    }

    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()

        guard
            let name = data["name"] as? String,
            let frequency = data["frequency"] as? String
        else { return nil }

        let statusRaw = (data["status"] as? String) ?? "active"
        let status = GroupStatus(rawValue: statusRaw) ?? .active

        let ts = data["createdAt"] as? Timestamp
        let createdAt = ts?.dateValue()

        self.init(id: doc.documentID,
                  name: name,
                  frequency: frequency,
                  status: status,
                  createdAt: createdAt)
    }
}
