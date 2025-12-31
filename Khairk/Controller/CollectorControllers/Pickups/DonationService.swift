import Foundation
import FirebaseFirestore

final class DonationService {
    private let db = Firestore.firestore()

    func listenPendingDonations(
        ngoId: String,
        onChange: @escaping (Result<[Donation], Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("donations")
            .whereField("ngoId", isEqualTo: ngoId)
            .whereField("status", isEqualTo: "pending")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err = err {
                    onChange(.failure(err))
                    return
                }
                let items = snap?.documents.compactMap { Donation(doc: $0) } ?? []
                onChange(.success(items))
            }
    }

    func listenActivePickups(
        ngoId: String,
        onChange: @escaping (Result<[Donation], Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("donations")
            .whereField("ngoId", isEqualTo: ngoId)
            .whereField("status", isEqualTo: "approved")
            .whereField("pickupStatus", in: ["in_progress", "completed"])
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err = err {
                    onChange(.failure(err))
                    return
                }
                let items = snap?.documents.compactMap { Donation(doc: $0) } ?? []
                onChange(.success(items))
            }
    }

    func listenDonation(
        donationId: String,
        onChange: @escaping (Result<Donation, Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("donations")
            .document(donationId)
            .addSnapshotListener { doc, err in
                if let err = err {
                    onChange(.failure(err))
                    return
                }
                guard let doc = doc, let d = Donation(doc: doc) else {
                    onChange(.failure(NSError(
                        domain: "DonationService",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Donation not found"]
                    )))
                    return
                }
                onChange(.success(d))
            }
    }

    func approveDonation(
        ngoId: String,
        donationId: String,
        caseId: String,
        quantity: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let donationRef = db.collection("donations").document(donationId)
        let caseRef = db.collection("ngos").document(ngoId).collection("cases").document(caseId)

        db.runTransaction({ tx, _ -> Any? in
            tx.updateData(["status": "approved", "pickupStatus": "in_progress"], forDocument: donationRef)
            tx.updateData(["collected": FieldValue.increment(Int64(quantity))], forDocument: caseRef)
            return nil
        }, completion: { _, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(()))
        })
    }

    func rejectDonation(donationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("donations").document(donationId)
            .updateData(["status": "rejected"]) { err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                completion(.success(()))
            }
    }

    func markPickupCompleted(donationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("donations").document(donationId)
            .updateData(["pickupStatus": "completed"]) { err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                completion(.success(()))
            }
    }
}
