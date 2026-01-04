import Foundation
import FirebaseFirestore

final class DonationService {

    static let shared = DonationService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Create Donation (Donor)
    func createDonation(
        donorId: String,                 // NEW: link to users/{uid}
        caseId: String? = nil,            // NEW: link to ngoCases/{docId} (optional)
        ngoId: String? = nil,             // NEW: link to NGOs by Auth UID (optional)

        foodName: String,
        quantity: Int,
        expiryDate: Date,
        description: String,
        donationType: String,
        imageURL: String,
        pickupTime: Date? = nil,
        serviceArea: String? = nil,
        buildingNumber: String? = nil,
        block: String? = nil,
        street: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        // Core donation payload
        var donationData: [String: Any] = [
            "foodName": foodName,
            "quantity": quantity,
            "expiryDate": Timestamp(date: expiryDate),
            "description": description,
            "donationType": donationType,
            "imageURL": imageURL,

            // ID linking
            "donorID": donorId,
            "donorId": donorId,

            // Initial status should be pending so collectors can see it
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]

        // Optional linking IDs
        if let caseId = caseId, !caseId.isEmpty {
            donationData["caseId"] = caseId
        }
        if let ngoId = ngoId, !ngoId.isEmpty {
            donationData["ngoID"] = ngoId
        }

        // Optional pickup/delivery fields
        if let pickupTime = pickupTime {
            donationData["pickupTime"] = Timestamp(date: pickupTime)
        }

        if let serviceArea = serviceArea { donationData["serviceArea"] = serviceArea }
        if let buildingNumber = buildingNumber { donationData["buildingNumber"] = buildingNumber }
        if let block = block { donationData["block"] = block }
        if let street = street { donationData["street"] = street }
        if let latitude = latitude { donationData["latitude"] = latitude }
        if let longitude = longitude { donationData["longitude"] = longitude }

        let ref = db.collection("donations").document()
        ref.setData(donationData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ref.documentID))
                Notification.shared.save(
                    title: "Thank You!",
                    body: "Your donation of \(foodName) was submitted successfully.",
                    userId: donorId,
                    makeLocalNotification: true
                )
                if let ngoId = ngoId, !ngoId.isEmpty {
                    Notification.shared.save(
                        title: "New Donation Available",
                        body: "A new donation (\(foodName)) is available for \(donationType).",
                        userId: ngoId,
                        makeLocalNotification: false
                    )
                }
            }
        }
    }


    // MARK: - Listen (Collector / NGO)
    func listenPendingDonations(
        ngoId: String,
        onChange: @escaping (Result<[Donation], Error>) -> Void
    ) -> ListenerRegistration {
        db.collection("donations")
            .whereField("ngoID", isEqualTo: ngoId)
            .whereField("status", isEqualTo: "pending")
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
            .whereField("ngoID", isEqualTo: ngoId)
            .whereField("status", isEqualTo: "accepted")
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

    // MARK: - Actions (Collector / NGO)
    func approveDonation(
        ngoId: String,
        donationId: String,
        caseId: String,
        quantity: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let donationRef = db.collection("donations").document(donationId)
        let caseRef = db.collection("ngoCases").document(caseId)

        db.runTransaction({ tx, _ -> Any? in
            tx.updateData([
                "status": "accepted",
                "ngoID": ngoId,
                "pickupStatus": "in_progress",
            ], forDocument: donationRef)
            tx.updateData(["Collected": FieldValue.increment(Int64(quantity))], forDocument: caseRef)
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
            .updateData(["status": "rejected", "pickupStatus": "rejected"]) { err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                completion(.success(()))
            }
    }

    func markPickupCompleted(donationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("donations").document(donationId)
            .updateData(["status": "collected", "pickupStatus": "completed"]) { err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                completion(.success(()))
            }
    }
}
