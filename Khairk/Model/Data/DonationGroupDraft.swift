//
//  DonationGroupDraft.swift
//  Khairk
//
//  Created by FM on 16/12/2025.
//

import Foundation

struct DonationGroupDraft {
    var groupName: String = ""
    var groupDescription: String = ""

    // "Weekly" or "Monthly"
    var frequencyType: String = "Weekly"

    // For weekly: "MON" / monthly: "10"
    var frequencySelection: String = ""

    var startDate: Date = Date()
    var endDate: Date = Date()
}
