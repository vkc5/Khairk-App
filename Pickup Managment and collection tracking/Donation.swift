import Foundation
import FirebaseFirestore

struct Donation {
    let id: String
    let ngoId: String
    let caseId: String

    let donorName: String
    let foodType: String
    let quantity: Int

    let status: String           // "pending" | "approved" | "rejected"
    let pickupStatus: String     // "none" | "in_progress" | "completed"

    init?(doc: DocumentSnapshot) {
        guard let d = doc.data() else { return nil }
        self.id = doc.documentID
        self.ngoId = d["ngoId"] as? String ?? ""
        self.caseId = d["caseId"] as? String ?? ""

        self.donorName = d["donorName"] as? String ?? "Unknown"
        self.foodType = d["foodType"] as? String ?? ""
        self.quantity = d["quantity"] as? Int ?? 0

        self.status = d["status"] as? String ?? "pending"
        self.pickupStatus = d["pickupStatus"] as? String ?? "none"
    }
}
