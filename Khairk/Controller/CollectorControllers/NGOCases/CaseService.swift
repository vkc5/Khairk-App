import Foundation
import FirebaseFirestore

final class CaseService {
    private let db = Firestore.firestore()

    private func casesRef(ngoId: String) -> CollectionReference {
        db.collection("ngos").document(ngoId).collection("cases")
    }

    func createCase(
        ngoId: String,
        newCase: NgoCase,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let ref = casesRef(ngoId: ngoId).document()
        var data = newCase.asFirestoreData
        data["createdAt"] = FieldValue.serverTimestamp()

        ref.setData(data) { err in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(ref.documentID))
        }
    }

    func listenCases(
        ngoId: String,
        onChange: @escaping (Result<[NgoCase], Error>) -> Void
    ) -> ListenerRegistration {
        casesRef(ngoId: ngoId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err = err {
                    onChange(.failure(err))
                    return
                }
                let items = snap?.documents.compactMap { NgoCase(doc: $0) } ?? []
                onChange(.success(items))
            }
    }

    func deleteCase(
        ngoId: String,
        caseId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        casesRef(ngoId: ngoId).document(caseId).delete { err in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(()))
        }
    }
}
