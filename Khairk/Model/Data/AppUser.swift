//
//  AppUser.swift
//  Khairk
//
//  Created by FM on 17/12/2025.
//

import Foundation

struct AppUser: Hashable {
    let uid: String
    let name: String
    let email: String
    let role: String

    init?(uid: String, data: [String: Any]) {
        guard
            let name = data["name"] as? String,
            let email = data["email"] as? String,
            let role = data["role"] as? String
        else { return nil }

        self.uid = uid
        self.name = name
        self.email = email
        self.role = role
    }
}
