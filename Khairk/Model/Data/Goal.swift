//
//  Goal.swift
//  Khairk
//
//  Created by vkc5 on 19/12/2025.
//

import Foundation
import FirebaseFirestore

struct Goal {
    let id: String
    let startDate: Date
    let endDate: Date
    let targetAmount: Int
    let status: String
    let imageUrl: String?

    // you don't store raised yet -> always 0 for now
    let raised: Int = 0

    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        guard
            let startTS = data["startDate"] as? Timestamp,
            let endTS = data["endDate"] as? Timestamp,
            let targetAmount = data["targetAmount"] as? Int,
            let status = data["status"] as? String
        else { return nil }

        self.id = doc.documentID
        self.startDate = startTS.dateValue()
        self.endDate = endTS.dateValue()
        self.targetAmount = targetAmount
        self.status = status
        self.imageUrl = data["imageUrl"] as? String
    }
}
