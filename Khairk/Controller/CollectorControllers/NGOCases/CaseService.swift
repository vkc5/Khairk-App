import Foundation
import FirebaseFirestore

final class CaseService {
    private let db = Firestore.firestore()

    private func casesRef() -> CollectionReference {
        db.collection("ngoCases")
    }

    func createCase(
        newCase: NgoCase,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let ref = casesRef().document()
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
        casesRef()
            .whereField("ngoID", isEqualTo: ngoId)
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
        caseId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        casesRef().document(caseId).delete { err in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(()))
        }
    }
}
