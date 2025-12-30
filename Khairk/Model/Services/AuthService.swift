//
//  File.swift
//  Khairk
//
//  Created by vkc5 on 25/11/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService {

    static let shared = AuthService()
    private init() {}

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    /// Sign in and return the AppUser (with role) from Firestore
    func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let self = self,
                let user = result?.user
            else {
                completion(.failure(NSError(domain: "AuthService",
                                            code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "No user found"])))
                return
            }

            self.fetchUserDocument(uid: user.uid, completion: completion)
        }
    }

    private func fetchUserDocument(
        uid: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let snapshot = snapshot,
                let data = snapshot.data(),
                let appUser = AppUser(id: snapshot.documentID, data: data)
            else {
                completion(.failure(NSError(domain: "AuthService",
                                            code: -2,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                return
            }

            completion(.success(appUser))
        }
    }
    
    func sendPasswordReset(
        to email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Sign up (Donor)
    func signUpDonor(
        name: String,
        email: String,
        phone: String,
        password: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let self = self,
                let user = result?.user
            else {
                let err = NSError(
                    domain: "AuthService",
                    code: -10,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to create user."]
                )
                completion(.failure(err))
                return
            }

            // Create Firestore document for this user
            let docData: [String: Any] = [
                "name": name,
                "email": email,
                "phone": phone,
                "role": UserRole.donor.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ]

            let docRef = self.db.collection("users").document(user.uid)
            docRef.setData(docData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Build AppUser from what we just saved
                if let appUser = AppUser(id: user.uid, data: docData) {
                    completion(.success(appUser))
                } else {
                    let err = NSError(
                        domain: "AuthService",
                        code: -11,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse user data."]
                    )
                    completion(.failure(err))
                }
            }
        }
    }
    
    // MARK: - Create Collector with full details

    func createCollector(
        signupData: CollectorSignupData,
        extraDetails: NGOExtraDetails,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        auth.createUser(withEmail: signupData.email, password: signupData.password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let self = self,
                let user = result?.user
            else {
                let err = NSError(
                    domain: "AuthService",
                    code: -30,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to create collector user."]
                )
                completion(.failure(err))
                return
            }

            let uid = user.uid

            var doc: [String: Any] = [
                "name": signupData.ngoName,
                "email": signupData.email,
                "phone": signupData.phone,
                "role": UserRole.collector.rawValue,
                "serviceArea": extraDetails.serviceArea,
                "memberName": extraDetails.memberName,
                "memberEmail": extraDetails.memberEmail,
                "memberPhone": extraDetails.memberPhone,
                "applicationStatus": "pending",          // <- NEW
                "createdAt": FieldValue.serverTimestamp()
            ]

            if let logo = extraDetails.logoUrl {
                doc["logoUrl"] = logo
            }
            if let license = extraDetails.licenseUrl {
                doc["licenseUrl"] = license
            }

            self.db.collection("users").document(uid).setData(doc) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let appUser = AppUser(id: uid, data: doc) {
                    completion(.success(appUser))
                } else {
                    let err = NSError(
                        domain: "AuthService",
                        code: -31,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse collector user."]
                    )
                    completion(.failure(err))
                }
            }
        }
    }



}
