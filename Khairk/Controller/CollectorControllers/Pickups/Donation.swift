import Foundation
import FirebaseFirestore

struct Donation {
    let id: String
    let ngoId: String
    let caseId: String

    let donorName: String
    let donorEmail: String
    let donorPhone: String

    let foodType: String
    let foodName: String
    let quantity: Int
    let expiryDate: Date?
    let details: String
    let pickupMethod: String

    let status: String           // pending | approved | rejected
    let pickupStatus: String     // none | in_progress | completed

    let caseTitle: String
    let caseDescription: String
    let caseTarget: Int
    let caseCollected: Int

    init?(doc: DocumentSnapshot) {
        guard let d = doc.data() else { return nil }
        id = doc.documentID
        ngoId = d["ngoId"] as? String ?? ""
        caseId = d["caseId"] as? String ?? ""

        donorName = d["donorName"] as? String ?? "Unknown"
        donorEmail = d["donorEmail"] as? String ?? ""
        donorPhone = d["donorPhone"] as? String ?? ""

        foodType = d["foodType"] as? String ?? ""
        foodName = d["foodName"] as? String ?? foodType
        quantity = d["quantity"] as? Int ?? 0

        if let timestamp = d["expiryDate"] as? Timestamp {
            expiryDate = timestamp.dateValue()
        } else {
            expiryDate = nil
        }

        details = d["description"] as? String ?? ""
        pickupMethod = d["pickupMethod"] as? String ?? "Pickup"

        status = d["status"] as? String ?? "pending"
        pickupStatus = d["pickupStatus"] as? String ?? "none"

        caseTitle = d["caseTitle"] as? String ?? ""
        caseDescription = d["caseDescription"] as? String ?? ""
        caseTarget = d["caseTarget"] as? Int ?? 0
        caseCollected = d["caseCollected"] as? Int ?? 0
    }
}
