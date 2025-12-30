//
//  User.swift
//  Khairk
//
//  Created by vkc5 on 24/11/2025.
//

import Foundation

enum UserRole: String {
    case donor
    case collector
    case admin
}

struct AppUser {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let phone: String?       // <- new
    let applicationStatus: String?   // <- NEW

    init?(id: String, data: [String: Any]) {
        guard
            let name = data["name"] as? String,
            let email = data["email"] as? String,
            let roleString = data["role"] as? String,
            let role = UserRole(rawValue: roleString)
        else {
            return nil
        }

        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.phone = data["phone"] as? String
        self.applicationStatus = data["applicationStatus"] as? String  // <- NEW
    }
}
