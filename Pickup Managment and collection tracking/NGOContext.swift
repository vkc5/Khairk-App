import Foundation
import FirebaseAuth
import FirebaseFirestore

final class NGOContext {
    static let shared = NGOContext()

    private let db = Firestore.firestore()

    // Change this to match your NGO doc field that stores the Auth UID
    // Examples: "uid", "ownerUid", "authUid"
    private let AUTH_UID_FIELD = "uid"

    private var cachedNgoId: String?

    func getNgoId(completion: @escaping (Result<String, Error>) -> Void) {
        if let cachedNgoId = cachedNgoId {
            completion(.success(cachedNgoId))
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NGOContext", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])))
            return
        }

        // 1) If you use Auth UID as the NGO doc id, this will work instantly.
        db.collection("ngos").document(uid).getDocument { [weak self] doc, err in
            if let err = err {
                completion(.failure(err)); return
            }
            if let doc = doc, doc.exists {
                self?.cachedNgoId = uid
                completion(.success(uid))
                return
            }

            // 2) Otherwise, query ngos where AUTH_UID_FIELD == current uid
            self?.db.collection("ngos")
                .whereField(self?.AUTH_UID_FIELD ?? "uid", isEqualTo: uid)
                .limit(to: 1)
                .getDocuments { snap, err in
                    if let err = err { completion(.failure(err)); return }
                    guard let ngoDoc = snap?.documents.first else {
                        completion(.failure(NSError(domain: "NGOContext", code: 404, userInfo: [NSLocalizedDescriptionKey: "No NGO document linked to this user. Add field \(self?.AUTH_UID_FIELD ?? "uid") to NGOs."])))
                        return
                    }
                    let ngoId = ngoDoc.documentID
                    self?.cachedNgoId = ngoId
                    completion(.success(ngoId))
                }
        }
    }
}
