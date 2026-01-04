//
//  DonationGroupDraftStore.swift
//  Khairk
//
//  Created by FM on 17/12/2025.
//

import Foundation

final class DonationGroupDraftStore {
    static let shared = DonationGroupDraftStore()
    private init() {}

    var draft = DonationGroupDraft()
}
