//
//  UserService.swift
//  Khairk
//
//  Created by FM on 17/12/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UsersService {

    private let db = Firestore.firestore()

    /// Fetch all users from Firestore/users, excluding current logged-in user.
    /// Optional: filter by role (e.g., "donor") by uncommenting the line below.
    func fetchUsers(completion: @escaping (Result<[AppUser], Error>) -> Void) {

        let currentUID = Auth.auth().currentUser?.uid

        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let users: [AppUser] = snapshot?.documents.compactMap { doc in
                let data = doc.data()

                guard let user = AppUser(uid: doc.documentID, data: data) else {
                    return nil
                }

                // Exclude current user
                if user.uid == currentUID { return nil }

                // ✅ لو تبين بس donors فعّلي هذا السطر:
                if user.role != "donor" { return nil }

                return user
            } ?? []

            completion(.success(users))
        }
    }
}
