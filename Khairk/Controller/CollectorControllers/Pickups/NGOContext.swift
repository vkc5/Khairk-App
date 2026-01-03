import Foundation
import FirebaseAuth
import FirebaseFirestore

final class NGOContext {
    static let shared = NGOContext()

    private let db = Firestore.firestore()

    // Change this to match your NGO doc field that stores the Auth UID.
    // Examples: "uid", "ownerUid", "authUid"
    private let authUidField = "uid"

    private var cachedNgoId: String?

    func getNgoId(completion: @escaping (Result<String, Error>) -> Void) {
        if let cachedNgoId = cachedNgoId {
            completion(.success(cachedNgoId))
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "NGOContext",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not logged in"]
            )))
            return
        }

        db.collection("ngos")
            .whereField(authUidField, isEqualTo: uid)
            .limit(to: 1)
            .getDocuments { [weak self] snap, err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard snap?.documents.first != nil else {
                    completion(.failure(NSError(
                        domain: "NGOContext",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "No NGO document linked to this user. Add field uid to NGOs."]
                    )))
                    return
                }
                self?.cachedNgoId = uid
                completion(.success(uid))
            }
    }
}
